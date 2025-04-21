#!/bin/bash

# Simple API test script for Trepidus Tech Website
# This script tests the API endpoints

# Exit on any error
set -e

# Base URL (adjustable)
BASE_URL=${1:-"http://localhost:5000"}

# Set color variables
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Test health endpoint
echo "Testing health endpoint..."
HEALTH_RESPONSE=$(curl -s "${BASE_URL}/health")
if [[ $HEALTH_RESPONSE == *"healthy"* ]]; then
  echo -e "${GREEN}✓ Health endpoint is working${NC}"
else
  echo -e "${RED}✗ Health endpoint test failed${NC}"
  echo "Response: $HEALTH_RESPONSE"
  exit 1
fi

# Test contact form endpoint (this won't actually send an email)
echo "Testing contact form endpoint structure..."
CONTACT_RESPONSE=$(curl -s -X POST \
  -H "Content-Type: application/json" \
  -d '{"name":"Test User","email":"test@example.com","subject":"API Test","message":"This is a test message from the API test script."}' \
  "${BASE_URL}/api/contact")

if [[ $CONTACT_RESPONSE == *"success"* ]]; then
  echo -e "${GREEN}✓ Contact form endpoint structure is correct${NC}"
else
  # This may fail if SendGrid API is not configured, which is expected
  echo -e "${RED}✗ Contact form endpoint test failed${NC}"
  echo "Response: $CONTACT_RESPONSE"
  echo "This is expected if SendGrid API key is not configured."
fi

echo "All tests completed!"