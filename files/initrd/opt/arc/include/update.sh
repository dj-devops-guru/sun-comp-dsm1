[[ -z "${ARC_PATH}" || ! -d "${ARC_PATH}/include" ]] && ARC_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")/../" 2>/dev/null && pwd)"

. ${ARC_PATH}/include/functions.sh

###############################################################################
# Upgrade Loader
function upgradeLoader () {
  local ARCNIC="$(readConfigKey "arc.nic" "${USER_CONFIG_FILE}")"
  local AUTOMATED="$(readConfigKey "automated" "${USER_CONFIG_FILE}")"
  dialog --backtitle "$(backtitle)" --title "You are already on Latest Version!"
  return 0
}

###############################################################################
# Update Loader
function updateLoader() {
  local ARCNIC="$(readConfigKey "arc.nic" "${USER_CONFIG_FILE}")"
  local AUTOMATED="$(readConfigKey "automated" "${USER_CONFIG_FILE}")"
  dialog --backtitle "$(backtitle)" --title "You are already on Latest Version!"
  return 0
}

###############################################################################
# Update Addons
function updateAddons() {
  local ARCNIC="$(readConfigKey "arc.nic" "${USER_CONFIG_FILE}")"
  dialog --backtitle "$(backtitle)" --title "No Any Updates Available for Addons"
  return 0
}

###############################################################################
# Update Patches
function updatePatches() {
  local ARCNIC="$(readConfigKey "arc.nic" "${USER_CONFIG_FILE}")"
  dialog --backtitle "$(backtitle)" --title "All the Patches are Up to date."
  
  return 0
}

###############################################################################
# Update Modules
function updateModules() {
  local ARCNIC="$(readConfigKey "arc.nic" "${USER_CONFIG_FILE}")"
  dialog --backtitle "$(backtitle)" --title "All the Modules are up to date."
  return 0
}

###############################################################################
# Update Configs
function updateConfigs() {
  local ARCNIC="$(readConfigKey "arc.nic" "${USER_CONFIG_FILE}")"
  if [ -z "${1}" ]; then
    # Check for new Version
    idx=0
    while [ ${idx} -le 5 ]; do # Loop 5 times, if successful, break
      if [ "${ARCNIC}" == "auto" ]; then
        local TAG="$(curl -m 10 -skL "https://api.github.com/repos/AuxXxilium/arc-configs/releases" | jq -r ".[].tag_name" | sort -rV | head -1)"
      else
        local TAG="$(curl --interface ${ARCNIC} -m 10 -skL "https://api.github.com/repos/AuxXxilium/arc-configs/releases" | jq -r ".[].tag_name" | sort -rV | head -1)"
      fi
      if [ -n "${TAG}" ]; then
        break
      fi
      sleep 3
      idx=$((${idx} + 1))
    done
  else
    local TAG="${1}"
  fi
  if [ -n "${TAG}" ]; then
    (
      # Download update file
      local URL="https://github.com/AuxXxilium/arc-configs/releases/download/${TAG}/configs.zip"
      local SHA="https://github.com/AuxXxilium/arc-configs/releases/download/${TAG}/checksum.sha256"
      echo "Downloading ${TAG}"
      if [ "${ARCNIC}" == "auto" ]; then
        curl -#kL "${URL}" -o "${TMP_PATH}/configs.zip" 2>&1 | while IFS= read -r -n1 char; do
          [[ $char =~ [0-9] ]] && keep=1 ;
          [[ $char == % ]] && echo "Download: $progress%" && progress="" && keep=0 ;
          [[ $keep == 1 ]] && progress="$progress$char" ;
        done
        curl -skL "${SHA}" -o "${TMP_PATH}/checksum.sha256"
      else
        curl --interface ${ARCNIC} -#kL "${URL}" -o "${TMP_PATH}/configs.zip" 2>&1 | while IFS= read -r -n1 char; do
          [[ $char =~ [0-9] ]] && keep=1 ;
          [[ $char == % ]] && echo "Download: $progress%" && progress="" && keep=0 ;
          [[ $keep == 1 ]] && progress="$progress$char" ;
        done
        curl --interface ${ARCNIC} -skL "${SHA}" -o "${TMP_PATH}/checksum.sha256"
      fi
      if [ "$(sha256sum "${TMP_PATH}/configs.zip" | awk '{print $1}')" = "$(cat ${TMP_PATH}/checksum.sha256 | awk '{print $1}')" ]; then
        echo "Download successful!"
        rm -rf "${MODEL_CONFIG_PATH}"
        mkdir -p "${MODEL_CONFIG_PATH}"
        echo "Installing new Configs..."
        unzip -oq "${TMP_PATH}/configs.zip" -d "${MODEL_CONFIG_PATH}"
        rm -f "${TMP_PATH}/configs.zip"
      else
        echo "Error extracting new Version!"
        sleep 5
        updateFailed
      fi
      echo "Update done!"
      sleep 2
    ) 2>&1 | dialog --backtitle "$(backtitle)" --title "Update Configs" \
      --progressbox "Updating Configs..." 20 70
  fi
  return 0
}

###############################################################################
# Update LKMs
function updateLKMs() {
  local ARCNIC="$(readConfigKey "arc.nic" "${USER_CONFIG_FILE}")"
  if [ -z "${1}" ]; then
    # Check for new Version
    idx=0
    while [ ${idx} -le 5 ]; do # Loop 5 times, if successful, break
      if [ "${ARCNIC}" == "auto" ]; then
        local TAG="$(curl -m 10 -skL "https://api.github.com/repos/AuxXxilium/arc-lkm/releases" | jq -r ".[].tag_name" | sort -rV | head -1)"
      else
        local TAG="$(curl --interface ${ARCNIC} -m 10 -skL "https://api.github.com/repos/AuxXxilium/arc-lkm/releases" | jq -r ".[].tag_name" | sort -rV | head -1)"
      fi
      if [ -n "${TAG}" ]; then
        break
      fi
      sleep 3
      idx=$((${idx} + 1))
    done
  else
    local TAG="${1}"
  fi
  if [ -n "${TAG}" ]; then
    (
      # Download update file
      local URL="https://github.com/AuxXxilium/arc-lkm/releases/download/${TAG}/rp-lkms.zip"
      echo "Downloading ${TAG}"
      if [ "${ARCNIC}" == "auto" ]; then
        curl -#kL "${URL}" -o "${TMP_PATH}/rp-lkms.zip" 2>&1 | while IFS= read -r -n1 char; do
          [[ $char =~ [0-9] ]] && keep=1 ;
          [[ $char == % ]] && echo "Download: $progress%" && progress="" && keep=0 ;
          [[ $keep == 1 ]] && progress="$progress$char" ;
        done
      else
        curl --interface ${ARCNIC} -#kL "${URL}" -o "${TMP_PATH}/rp-lkms.zip" 2>&1 | while IFS= read -r -n1 char; do
          [[ $char =~ [0-9] ]] && keep=1 ;
          [[ $char == % ]] && echo "Download: $progress%" && progress="" && keep=0 ;
          [[ $keep == 1 ]] && progress="$progress$char" ;
        done
      fi
      if [ -f "${TMP_PATH}/rp-lkms.zip" ]; then
        echo "Download successful!"
        rm -rf "${LKMS_PATH}"
        mkdir -p "${LKMS_PATH}"
        echo "Installing new LKMs..."
        unzip -oq "${TMP_PATH}/rp-lkms.zip" -d "${LKMS_PATH}"
        rm -f "${TMP_PATH}/rp-lkms.zip"
      else
        echo "Error extracting new Version!"
        sleep 5
        updateFailed
      fi
      echo "Update done!"
      sleep 2
    ) 2>&1 | dialog --backtitle "$(backtitle)" --title "Update LKMs" \
      --progressbox "Updating LKMs..." 20 70
  fi
  return 0
}

###############################################################################
# Update Failed
function updateFailed() {
  local AUTOMATED="$(readConfigKey "automated" "${USER_CONFIG_FILE}")"
  if [ "${AUTOMATED}" = "true" ]; then
    dialog --backtitle "$(backtitle)" --title "Update Failed" \
      --infobox "Update failed!" 0 0
    sleep 5
    exec reboot
  else
    dialog --backtitle "$(backtitle)" --title "Update Failed" \
      --msgbox "Update failed!" 0 0
    exit 1
  fi
}