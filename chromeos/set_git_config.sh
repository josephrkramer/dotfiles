#!/bin/bash

. "$(dirname "${BASH_SOURCE[0]}")"/../common/git_utils.sh || { echo "Error: Failed to load common/git_utils.sh" >&2; exit 1; }

set_git_config() {
  # Get username
  while true; do
    read -p "Enter your full name [Joseph Kramer]: " username
    username="${username:-Joseph Kramer}"
    if [[ -n "$username" ]]; then # Check if username is not empty
      break
    else
      echo "Username cannot be empty. Please try again."
    fi
  done


  # Get email address with validation
  while true; do
    read -p "Enter your Git email address [joseph.ryan.kramer@gmail.com]: " email
    email="${email:-joseph.ryan.kramer@gmail.com}"
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
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  set_git_config
fi
