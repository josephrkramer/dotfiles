#!/bin/bash
source termux/set_git_config.sh

# Test validate_email
validate_email "test@example.com"
if [ $? -ne 0 ]; then
  echo "test_set_git_config.sh: failed valid email"
  exit 1
fi

validate_email "invalid-email"
if [ $? -eq 0 ]; then
  echo "test_set_git_config.sh: failed invalid email"
  exit 1
fi

echo "test_set_git_config.sh passed"
exit 0