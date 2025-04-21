#!/bin/bash

# API Testing Script for Trepidus Tech Website
# Tests health endpoint and contact form API

# Set variables
API_URL="http://localhost:5000"
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Function to print colored status
print_status() {
  if [ $1 -eq 0 ]; then
    echo -e "${GREEN}PASS${NC}: $2"
  else
    echo -e "${RED}FAIL${NC}: $2"
    TESTS_FAILED=1
  fi
}

echo -e "${YELLOW}Starting API tests...${NC}"
echo -e "${YELLOW}==========================${NC}"

# Initialize test failure flag
TESTS_FAILED=0

# Test 1: Health Endpoint (GET /health)
echo -e "\n${YELLOW}Test 1: Health Check Endpoint${NC}"
HEALTH_RESPONSE=$(curl -s "$API_URL/health")
if [[ "$HEALTH_RESPONSE" == *"healthy"* ]]; then
  print_status 0 "Health endpoint returned 'healthy'"
else
  print_status 1 "Health endpoint did not return 'healthy'"
  echo "Response: $HEALTH_RESPONSE"
fi

# Test 2: Contact Form API (POST /api/contact)
echo -e "\n${YELLOW}Test 2: Contact Form API${NC}"
CONTACT_RESPONSE=$(curl -s -X POST \
  -H "Content-Type: application/json" \
  -d '{"name":"Test User","email":"test@example.com","subject":"API Test","message":"This is a test message"}' \
  "$API_URL/api/contact")

if [[ "$CONTACT_RESPONSE" == *"success"* ]]; then
  print_status 0 "Contact form API returned success"
else
  # If SENDGRID_API_KEY is not set, we expect a specific error
  if [[ "$CONTACT_RESPONSE" == *"not set"* || "$CONTACT_RESPONSE" == *"API key"* ]]; then
    print_status 0 "Contact form API correctly reported missing API key (expected in CI environment)"
  else
    print_status 1 "Contact form API failed unexpectedly"
    echo "Response: $CONTACT_RESPONSE"
  fi
fi

# Test 3: Invalid Contact Request (missing required fields)
echo -e "\n${YELLOW}Test 3: Invalid Contact Request${NC}"
INVALID_RESPONSE=$(curl -s -X POST \
  -H "Content-Type: application/json" \
  -d '{"name":"Test User"}' \
  "$API_URL/api/contact")

if [[ "$INVALID_RESPONSE" == *"error"* || "$INVALID_RESPONSE" == *"required"* ]]; then
  print_status 0 "Contact form API correctly rejected invalid request"
else
  print_status 1 "Contact form API did not reject invalid request as expected"
  echo "Response: $INVALID_RESPONSE"
fi

# Test 4: Static Asset Check
echo -e "\n${YELLOW}Test 4: Static Asset Check${NC}"
HOME_PAGE=$(curl -s "$API_URL/")
if [[ "$HOME_PAGE" == *"html"* ]]; then
  print_status 0 "Successfully loaded static HTML"
else
  print_status 1 "Failed to load static HTML"
fi

# Test 5: Verify API Throttling (Optional, basic simulation)
echo -e "\n${YELLOW}Test 5: API Throttling Check${NC}"
for i in {1..5}; do
  curl -s -o /dev/null -w "" -X POST \
    -H "Content-Type: application/json" \
    -d '{"name":"Test User","email":"test@example.com","subject":"API Test","message":"This is a test message"}' \
    "$API_URL/api/contact"
done

THROTTLED_RESPONSE=$(curl -s -X POST \
  -H "Content-Type: application/json" \
  -d '{"name":"Test User","email":"test@example.com","subject":"API Test","message":"This is a test message"}' \
  "$API_URL/api/contact")

# We don't necessarily expect throttling after just 5 requests,
# so this is more of an informational test
echo -e "After 6 rapid requests, API response: ${YELLOW}$(echo $THROTTLED_RESPONSE | cut -c 1-100)...${NC}"

# Summary
echo -e "\n${YELLOW}==========================${NC}"
if [ $TESTS_FAILED -eq 0 ]; then
  echo -e "${GREEN}All tests passed!${NC}"
  exit 0
else
  echo -e "${RED}Some tests failed!${NC}"
  exit 1
fi