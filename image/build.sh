#!/bin/bash
# Builds the RetroNav SD-card image with pi-gen in Docker.
# Usage: image/build.sh            (output in image/deploy/)
# Env:   PIGEN_REF    pi-gen branch (default: arm64)
#        LIVI_REF     LIVI git ref for the installer scripts (default: main)
#        LIVI_CHANNEL release | nightly AppImage (default: release)
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
WORK="${HERE}/.pi-gen"
PIGEN_REF="${PIGEN_REF:-arm64}"
LIVI_REF="${LIVI_REF:-main}"
LIVI_CHANNEL="${LIVI_CHANNEL:-release}"

if [ ! -d "${WORK}" ]; then
	git clone --depth 1 --branch "${PIGEN_REF}" https://github.com/RPi-Distro/pi-gen.git "${WORK}"
fi

rm -rf "${WORK}/stage-retronav"
cp -r "${HERE}/stage-retronav" "${WORK}/"
cp "${HERE}/config" "${WORK}/config"
FILES="${WORK}/stage-retronav/01-livi/files"

echo "→ Fetching LIVI installer (${LIVI_REF})"
git clone --depth 1 --branch "${LIVI_REF}" https://github.com/f-io/LIVI.git "${FILES}/livi-src"

echo "→ Fetching LIVI arm64 AppImage (${LIVI_CHANNEL})"
if [ "${LIVI_CHANNEL}" = nightly ]; then
	API="https://api.github.com/repos/f-io/LIVI/releases/tags/nightly"
else
	API="https://api.github.com/repos/f-io/LIVI/releases/latest"
fi
AUTH=()
[ -n "${GITHUB_TOKEN:-}" ] && AUTH=(-H "Authorization: Bearer ${GITHUB_TOKEN}")
URL="$(curl -fsSL "${AUTH[@]}" "${API}" | grep -o '"browser_download_url": *"[^"]*arm64[^"]*\.AppImage"' \
	| head -n1 | sed 's/.*"\(https[^"]*\)"/\1/')"
[ -n "${URL}" ] || { echo "No arm64 AppImage in the ${LIVI_CHANNEL} build" >&2; exit 1; }
curl -fL "${URL}" -o "${FILES}/LIVI.AppImage"

# Lite image only: skip the desktop stages and their exports.
touch "${WORK}/stage3/SKIP" "${WORK}/stage4/SKIP" "${WORK}/stage5/SKIP"
touch "${WORK}/stage4/SKIP_IMAGES" "${WORK}/stage5/SKIP_IMAGES"
rm -f "${WORK}/stage2/EXPORT_IMAGE"

cd "${WORK}"
PRESERVE_CONTAINER=0 ./build-docker.sh
mkdir -p "${HERE}/deploy"
cp deploy/* "${HERE}/deploy/"
echo "Image written to ${HERE}/deploy/"
