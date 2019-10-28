#!/bin/sh

echo "--- Installing bats"
if ! command -v bats >/dev/null; then
  if [ "$(uname)" == "Darwin" ]; then
    brew install bats-core
  fi
fi

echo "--- Installing gpg"
if ! command -v gpg >/dev/null; then
  if [ "$(uname)" == "Darwin" ]; then
    brew install gnupg
  fi
fi

echo "--- Testing install.sh"
echo $PATH
bats components/hab/tests/test_install_script.bats
