#!/usr/bin/env bash
set -euo pipefail

# patch_fluidd_spoolman_savevars.sh
#
# Purpose:
#   Fix Fluidd (older 1.30.x builds) Spoolman persistence bug on QIDI printers:
#   Fluidd saves SAVE_VARIABLE keys as UPPERCASE (e.g. BOX1_SLOT3__SPOOL_ID),
#   which doesn't persist reliably with Klipper save_variables.
#   This patch rewrites the compiled Fluidd bundle to use lowercase:
#     box1_slot3__spool_id
#
# What it changes:
#   - Only files containing "__SPOOL_ID" inside /home/mks/fluidd/
#   - Rewrites "__SPOOL_ID" -> "__spool_id" on those lines
#   - Rewrites "toUpperCase()" -> "toLowerCase()" on those lines
#
# Safety:
#   - Makes a full backup of /home/mks/fluidd before changes.
#
# Author: Ivantify
# Usage:
#   bash /home/mks/printer_data/config/patch_fluidd_spoolman_savevars.sh

FLUIDD_DIR="/home/mks/fluidd"
STAMP="$(date +%F_%H%M%S)"
BACKUP_DIR="/home/mks/fluidd.bak_${STAMP}"

if [[ ! -d "${FLUIDD_DIR}" ]]; then
  echo "ERROR: ${FLUIDD_DIR} not found. Edit this script if your Fluidd path differs."
  exit 1
fi

echo "==> Backing up ${FLUIDD_DIR} to ${BACKUP_DIR}"
cp -a "${FLUIDD_DIR}" "${BACKUP_DIR}"

echo "==> Searching for '__SPOOL_ID' in compiled Fluidd files..."
mapfile -t FILES < <(grep -Rsl "__SPOOL_ID" "${FLUIDD_DIR}" || true)

if [[ ${#FILES[@]} -eq 0 ]]; then
  echo "Nothing to patch: no '__SPOOL_ID' found under ${FLUIDD_DIR}."
  echo "If your issue persists, confirm you are editing the served Fluidd folder."
  exit 0
fi

echo "Found ${#FILES[@]} file(s) to patch."
for f in "${FILES[@]}"; do
  # Keep per-file backup too, just in case
  cp -a "$f" "${f}.bak"

  # Only touch lines that contain __SPOOL_ID
  perl -pi -e 'if(/__SPOOL_ID/){s/toUpperCase\(\)/toLowerCase()/g; s/__SPOOL_ID/__spool_id/g;}' "$f"
done

echo "==> Done."
echo ""
echo "Next steps:"
echo "  1) In your browser: hard refresh Fluidd (Ctrl+Shift+R)."
echo "  2) Change a spool in Spoolman UI and confirm it sends:"
echo "       SAVE_VARIABLE VARIABLE=box1_slotX__spool_id VALUE=..."
echo ""
echo "Revert:"
echo "  rm -rf ${FLUIDD_DIR} && cp -a ${BACKUP_DIR} ${FLUIDD_DIR}"
