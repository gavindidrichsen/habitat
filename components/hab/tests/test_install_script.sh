#!/bin/sh

echo "--- Installing bats"
if ! command -v bats >/dev/null; then
  if [ "$(uname)" == "Darwin" ]; then
    brew install bats-core
  elif [ "$(uname)" == "Linux" ]; then
    hab pkg install core/bats --binlink 
  fi
fi

echo "--- Installing gpg"
if ! command -v gpg >/dev/null; then
  if [ "$(uname)" == "Darwin" ]; then
    brew install gnupg
  elif [ "$(uname)" == "Linux" ]; then
    hab pkg install core/gnupg
    hab pkg binlink core/gnupg gpg 
  fi
fi

echo "--- Testing install.sh"
bats components/hab/tests/test_install_script.bats
