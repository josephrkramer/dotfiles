#!/bin/bash

# Source the script to test
. "$(dirname "${BASH_SOURCE[0]}")/set_git_config.sh"

# Test valid email
if ! validate_email "test@example.com"; then
  echo "test_set_git_config.sh: failed on valid email (test@example.com)"
  exit 1
fi

# Test another valid email with a subdomain
if ! validate_email "user.name+tag@sub.domain.co.uk"; then
  echo "test_set_git_config.sh: failed on valid email (user.name+tag@sub.domain.co.uk)"
  exit 1
fi

# Test invalid email (no domain)
if validate_email "invalid-email"; then
  echo "test_set_git_config.sh: failed on invalid email (invalid-email)"
  exit 1
fi

# Test invalid email (no @ symbol)
if validate_email "testexample.com"; then
  echo "test_set_git_config.sh: failed on invalid email (testexample.com)"
  exit 1
fi

# Test invalid email (missing TLD)
if validate_email "test@example"; then
  echo "test_set_git_config.sh: failed on invalid email (test@example)"
  exit 1
fi

echo "test_set_git_config.sh passed"
exit 0
