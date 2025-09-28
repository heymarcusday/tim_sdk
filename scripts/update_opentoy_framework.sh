#!/usr/bin/env bash
set -euo pipefail

# Script to update opentoy_ios framework in tim_sdk
# Usage: ./update_opentoy_framework.sh [opentoy_ios_path]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TIM_SDK_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
TIM_SDK_IOS_DIR="${TIM_SDK_ROOT}/ios"
OPENTOY_IOS_PATH="${1:-../opentoy_ios}"

# Resolve absolute path for opentoy_ios
if [[ "${OPENTOY_IOS_PATH:0:1}" == "/" ]]; then
    OPENTOY_IOS_ABS_PATH="${OPENTOY_IOS_PATH}"
else
    OPENTOY_IOS_ABS_PATH="$(cd "${TIM_SDK_ROOT}/${OPENTOY_IOS_PATH}" && pwd)"
fi

OPENTOY_FRAMEWORK_SOURCE="${OPENTOY_IOS_ABS_PATH}/Build/opentoy_ios.xcframework"
OPENTOY_FRAMEWORK_DEST="${TIM_SDK_IOS_DIR}/opentoy_ios.xcframework"

log() {
    echo "[update_opentoy_framework] $*"
}

error() {
    echo "[update_opentoy_framework] ERROR: $*" >&2
    exit 1
}

# Check if opentoy_ios source exists
if [[ ! -d "${OPENTOY_IOS_ABS_PATH}" ]]; then
    error "opentoy_ios directory not found: ${OPENTOY_IOS_ABS_PATH}"
fi

# Check if framework source exists
if [[ ! -d "${OPENTOY_FRAMEWORK_SOURCE}" ]]; then
    error "opentoy_ios.xcframework not found at: ${OPENTOY_FRAMEWORK_SOURCE}"
    echo "Please build opentoy_ios first by running: cd ${OPENTOY_IOS_ABS_PATH} && ./Scripts/build_xcframework.sh"
fi

# Remove existing framework
if [[ -d "${OPENTOY_FRAMEWORK_DEST}" ]]; then
    log "Removing existing framework..."
    rm -rf "${OPENTOY_FRAMEWORK_DEST}"
fi

# Copy new framework
log "Copying opentoy_ios.xcframework from ${OPENTOY_FRAMEWORK_SOURCE} to ${OPENTOY_FRAMEWORK_DEST}..."
cp -r "${OPENTOY_FRAMEWORK_SOURCE}" "${OPENTOY_FRAMEWORK_DEST}"

log "Framework updated successfully!"
log "Framework location: ${OPENTOY_FRAMEWORK_DEST}"

# Verify the framework structure
if [[ -d "${OPENTOY_FRAMEWORK_DEST}/ios-arm64" && -d "${OPENTOY_FRAMEWORK_DEST}/ios-arm64-simulator" ]]; then
    log "Framework structure verified ✓"
else
    error "Framework structure verification failed"
fi

log "Done!"
