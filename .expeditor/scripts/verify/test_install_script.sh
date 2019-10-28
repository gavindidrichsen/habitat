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
# Bats in chefes/buildkite is a hab-binliked install to the default directory
# of /bin, but /bin isn't on our path. 
export PATH=$PATH:/bin
echo $PATH 
ls /bin/bats
bats components/hab/tests/test_install_script.bats
