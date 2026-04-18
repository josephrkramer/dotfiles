#!/bin/bash

# Function to validate email address format (basic check)
validate_email() {
  if [[ "$1" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
    return 0  # Valid
  else
    return 1  # Invalid
  fi
}
