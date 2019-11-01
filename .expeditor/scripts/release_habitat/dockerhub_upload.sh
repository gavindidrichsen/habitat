#!/bin/bash

# Build the hab base image and the latest studio image for the given
# release channel.
#
# This results in something like:
#
#    habitat/default-studio:0.61.0
#
# Finally push the tagged image to dockerhub.
#
# Note that pushing these to Dockerhub is OK, even though they may
# correspond to versions of Habitat that will never be officially
# released, because the image that is ultimately used by a version of
# Habitat is directly keyed to the version of the Habitat binary being
# used.

set -euo pipefail

source .expeditor/scripts/release_habitat/shared.sh

version=$(get_version_from_repo)
channel=$(get_release_channel)
target="${BUILD_PKG_TARGET}"
image_name="habitat/default-studio-${target}"
image_name_with_tag="${image_name}:${version}"

# TODO (CM): Pull these credentials from Vault instead
docker login \
  --username="${DOCKER_LOGIN_USER}" \
  --password="${MY_SECRET_DOCKER_LOGIN_PASSWORD}"

trap 'rm -f $HOME/.docker/config.json' INT TERM EXIT

(
    cd ./components/rootless_studio

    # TODO (CM): I'm not entirely certain why this build is split into
    # two separate invocations, when the entire flow is essentially
    # that of a multistage Dockerfile, which the second Dockerfile
    # actually is.

    docker build \
           --build-arg PACKAGE_TARGET="${target}" \
           --tag "habitat-${target}:hab-base" .

    docker build \
           --build-arg HAB_LICENSE="accept-no-persist" \
           --build-arg BLDR_CHANNEL="${channel}" \
           --build-arg PACKAGE_TARGET="${target}" \
           --no-cache \
           --tag "${image_name_with_tag}" \
           ./default

    docker push "${image_name_with_tag}"
)
