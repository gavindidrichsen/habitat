#!/bin/bash

# Retrieves the current package manifest for a particular environment
# and promotes the packages into a designated Builder channel. Also
# promotes all artifacts in S3 to the designated destination
# environment.
#
# We promote to Builder *before* promoting in S3 because it's
# safer. If the final S3 promotion were to fail, we'd still have good
# and self-consistent packages in Builder for all to use. If we did S3
# first, but the following Builder promotion failed for some reason,
# people getting packages from our "curlbash" installer would get a
# new `hab`, but wouldn't be able to get the rest of the packages
# (easily, anyway), because they wouldn't have yet made it to the
# stable channel.

set -euo pipefail

# `source_environment` is the Expeditor environment from which to pull
# a manifest.json file from in order to drive the promotions.
#
# e.g., "dev", "acceptance", etc.
source_environment=${1:?You must provide an Expeditor environment}

# `destination_channel` should be the channel we are promoting Habitat
# packages into.
#
# e.g. `acceptance`, `current`, etc
destination_channel=${2:?You must specify a destination channel value}

export HAB_AUTH_TOKEN="${ACCEPTANCE_HAB_AUTH_TOKEN}"

########################################################################

source .expeditor/scripts/shared.sh

# This allows people to e.g. trigger end-to-end pipeline runs manually
# when iterating on tests, but without having to fear that they'll
# inadvertently promote a set of artifacts accidentally.
#
# Only Chef Expeditor should be triggering "real" runs of pipelines
# that use this script.
readonly valid_build_creator="Chef Expeditor"

if [[ "${BUILDKITE_BUILD_CREATOR}" == "${valid_build_creator}" ]]; then
    # We're in a real pipeline run; let's promote!

    # Take advantage of the fact that we're just promoting and we can run
    # 100% on linux
    declare -g hab_binary
    curlbash_hab "x86_64-linux"

    # Needed for validation of the downloaded manifest
    import_gpg_keys

    echo "--- Retrieving manifest.json for ${source_environment} environment"
    get_manifest_for_environment "${source_environment}"

    # Extract the targets from the manifest
    echo "--- Promoting Habitat packages into the ${destination_channel} channel on ${HAB_BLDR_URL}"
    promote_packages_to_builder_channel manifest.json "${destination_channel}"

    version="$(jq -r '.version' < manifest.json)"
    echo "--- Promoting binary packages and manifest to the ${destination_channel} channel in S3"
    promote_version_in_s3 "${version}" "${destination_channel}"

    echo "--- Purging fastly cache for 'dev' channel"
    # While this is probably not necessary as we generally `hab pkg install` for packages
    # from the 'dev' channel,  we did run into issues with wedged packages as we were 
    # testing the migration to packages.chef.io. Rather than potentially waste hours of 
    # troubleshooting down the road, we'll purge the 'dev' channel at the end of every build.
    .expeditor/scripts/purge_cdn.sh

else
    echo "--- NOT PROMOTING: Build triggered by ${BUILDKITE_BUILD_CREATOR} and *not* ${valid_build_creator}"
fi
