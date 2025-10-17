#!/usr/bin/env bash
# deploy.sh - Build Docker image, push to ECR, upload Dockerrun.aws.json to S3 and create EB application version
# This script relies on terraform outputs in the infra directory. It will call `terraform output -json` to get
# the ECR repo URL and the EB S3 bucket name.

set -euo pipefail

usage() {
  cat <<EOF
Usage: $0 [-p aws_profile] [-r aws_region] [-d infra_dir] [-t image_tag]

Options:
  -p aws_profile   AWS CLI profile to use (default: default)
  -r aws_region    AWS region (default: eu-west-1)
  -d infra_dir     Path to terraform infra directory (default: ./)
  -t image_tag     Image tag to push (default: <git-sha>-<ts>)
  -h               Show this help
EOF
}

AWS_PROFILE=default
AWS_REGION=eu-west-1
INFRA_DIR="."
# If the user doesn't pass -t, we will generate an immutable tag based on git sha + timestamp
IMAGE_TAG=""
SKIP_BUILD=false

while getopts ":p:r:d:t:sh" opt; do
  case ${opt} in
    p) AWS_PROFILE=$OPTARG ;;
    r) AWS_REGION=$OPTARG ;;
    d) INFRA_DIR=$OPTARG ;;
    t) IMAGE_TAG=$OPTARG ;;
    s) SKIP_BUILD=true ;;
    h) usage; exit 0 ;;
    \?) echo "Invalid option: -$OPTARG" >&2; usage; exit 1 ;;
  esac
done

echo "Using AWS profile=${AWS_PROFILE} region=${AWS_REGION} infra_dir=${INFRA_DIR} image_tag=${IMAGE_TAG}"
if [ "$SKIP_BUILD" = "true" ]; then
  echo "Skipping Docker build and push (skip-build=true)"
fi

if ! command -v terraform >/dev/null 2>&1; then
  echo "terraform CLI not found in PATH"
  exit 1
fi
if ! command -v aws >/dev/null 2>&1; then
  echo "aws CLI not found in PATH"
  exit 1
fi
if ! command -v docker >/dev/null 2>&1; then
  echo "docker not found in PATH"
  exit 1
fi

pushd "$INFRA_DIR" >/dev/null

# read outputs using terraform
if [ ! -f terraform.tfstate ] && [ ! -f .terraform.lock.hcl ]; then
  echo "Terraform state or init not present in ${INFRA_DIR}. Run 'terraform init' and 'terraform apply' first."
fi

TFOUT_JSON=$(terraform output -json || true)
if [ -z "$TFOUT_JSON" ]; then
  echo "terraform output returned empty. Ensure you ran 'terraform apply' in ${INFRA_DIR}."
  popd >/dev/null
  exit 1
fi

ECR_REPO_URL=$(echo "$TFOUT_JSON" | jq -r '.ecr_repository_url.value')
S3_BUCKET=$(echo "$TFOUT_JSON" | jq -r '.eb_s3_bucket.value')
APP_NAME=$(echo "$TFOUT_JSON" | jq -r '.elastic_beanstalk_environment_name.value' | sed 's/-.*$//')
ENVIRONMENT=$(echo "$TFOUT_JSON" | jq -r '.elastic_beanstalk_environment_name.value' | sed 's/^[^-]*-//')

if [ -z "$ECR_REPO_URL" ] || [ "$ECR_REPO_URL" = "null" ]; then
  echo "ECR repository URL not found in terraform outputs (ecr_repository_url)"
  popd >/dev/null
  exit 1
fi
if [ -z "$S3_BUCKET" ] || [ "$S3_BUCKET" = "null" ]; then
  echo "EB S3 bucket not found in terraform outputs (eb_s3_bucket)"
  popd >/dev/null
  exit 1
fi

if [ -z "${IMAGE_TAG}" ]; then
  if command -v git >/dev/null 2>&1 && git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    GITSHA=$(git rev-parse --short HEAD 2>/dev/null || true)
  else
    GITSHA="local"
  fi
  IMAGE_TAG="${GITSHA}-$(date +%s)"
fi

FULL_IMAGE="${ECR_REPO_URL}:${IMAGE_TAG}"

echo "Image tag set to ${IMAGE_TAG}"
echo "Preparing to build/push Docker image ${FULL_IMAGE}..."
REGISTRY_HOST=$(echo "${ECR_REPO_URL}" | cut -d'/' -f1)

# Default platforms - single-arch linux/amd64 to avoid building arm images on Apple Silicon
PLATFORMS=${PLATFORMS:-linux/amd64}

if [ "$SKIP_BUILD" != "true" ]; then
  echo "Logging in to ECR..."
  aws ecr get-login-password --profile ${AWS_PROFILE} --region ${AWS_REGION} | docker login --username AWS --password-stdin ${REGISTRY_HOST}

  if docker buildx version >/dev/null 2>&1; then
    # ensure a builder exists and is bootstrapped; create one if needed
    BUILDER_NAME=eb-builder
    if ! docker buildx inspect ${BUILDER_NAME} >/dev/null 2>&1; then
      echo "Creating docker buildx builder '${BUILDER_NAME}'"
      docker buildx create --use --name ${BUILDER_NAME} >/dev/null
    else
      docker buildx use ${BUILDER_NAME} || true
    fi
    echo "Bootstrapping builder (this may register QEMU emulators for multi-arch)..."
    docker buildx inspect --bootstrap >/dev/null 2>&1 || true

    echo "Building and pushing with buildx for platform(s): ${PLATFORMS}"
    # buildx will push directly to the registry; we tag with the immutable IMAGE_TAG
    docker buildx build --platform ${PLATFORMS} -t ${FULL_IMAGE} --push ..
  else
    echo "docker buildx not available; falling back to normal docker build (may produce platform-specific image)"
    docker build -t ${FULL_IMAGE} ..
    echo "Pushing image..."
    docker push ${FULL_IMAGE}
  fi
else
  echo "Not building/pushing image because skip-build was requested. Make sure ${FULL_IMAGE} already exists in ECR."
fi

# Create Dockerrun.aws.json (v1)
DOCKERRUN=$(cat <<EOF
{
  "AWSEBDockerrunVersion": 1,
  "Image": {
    "Name": "${FULL_IMAGE}",
    "Update": "true"
  },
  "Ports": [
    { "ContainerPort": "5000" }
  ]
}
EOF
)

TMPFILE=$(mktemp /tmp/dockerrun.XXXX.json)
echo "$DOCKERRUN" > $TMPFILE

KEY="${APP_NAME}-${ENVIRONMENT}-$(date +%s).zip"
zip -j /tmp/${KEY} $TMPFILE

echo "Uploading application bundle to s3://${S3_BUCKET}/${KEY}..."
aws s3 cp /tmp/${KEY} s3://${S3_BUCKET}/${KEY} --profile ${AWS_PROFILE} --region ${AWS_REGION}

VERSION_LABEL="${IMAGE_TAG}-$(date +%s)"
echo "Creating application version ${VERSION_LABEL}..."
aws elasticbeanstalk create-application-version --application-name ${APP_NAME} --version-label "${VERSION_LABEL}" --source-bundle S3Bucket=${S3_BUCKET},S3Key=${KEY} --profile ${AWS_PROFILE} --region ${AWS_REGION}

echo "Updating environment to version ${VERSION_LABEL}..."
aws elasticbeanstalk update-environment --environment-name "${APP_NAME}-${ENVIRONMENT}" --version-label "${VERSION_LABEL}" --profile ${AWS_PROFILE} --region ${AWS_REGION}

rm $TMPFILE /tmp/${KEY}
popd >/dev/null

echo "Deployment triggered. Monitor Elastic Beanstalk console or use AWS CLI to watch events."
