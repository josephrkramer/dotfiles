#!/bin/bash

# Function to validate email address format (basic check)
validate_email() {
  if [[ "$1" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
    return 0  # Valid
  else
    return 1  # Invalid
  fi
}

# Get username
while true; do
  read -p "Enter your full name: " username
  if [[ -n "$username" ]]; then # Check if username is not empty
    break
  else
    echo "Username cannot be empty. Please try again."
  fi
done


# Get email address with validation
while true; do
  read -p "Enter your Git email address: " email
  if validate_email "$email"; then
    break
  else
    echo "Invalid email format. Please try again."
  fi
done

# Set Git config
git config --global user.name "$username"
git config --global user.email "$email"
git config --global push.autoSetupRemote true 2>/dev/null

# Confirmation message
echo "Git username and email set successfully:"
echo "Username: $username"
echo "Email: $email"

# Optional: Display current config
git config --list | grep user.

echo "You're all set!"
