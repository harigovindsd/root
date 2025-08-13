#!/bin/bash

###########################**NOTES**###################################################
#	set -euo pipefail: Ensures the script exits on:
#		- Any command failure (-e)
#		- Use of undefined variables (-u)
#		- Failures in pipelines (-o pipefail)
#	trap ERR: Catches any error and logs it with the line number.
#	trap EXIT: Ensures cleanup runs on both success and failure.
#	log and log_error: Write timestamped messages to log files.
# 
# file  : my-good-bash-template.sh
# date  : 2020-05-05
# author: Harigovind S D
# 
#######################################################################################

set -euo pipefail

# === CONFIGURATION ===
LOG_FILE="script.log"
ERROR_LOG="error.log"

# === FUNCTIONS ===
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') [INFO] $*" | tee -a "${LOG_FILE}"
}

log_error() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') [ERROR] $*" | tee -a "${ERROR_LOG}" >&2
}

cleanup() {
    log "Cleaning up before exit..."
    # Add any cleanup commands here
}

handle_error() {
    local exit_code=$?
    log_error "Script failed at line ${LINENO} with exit code ${exit_code}"
    cleanup
    exit $exit_code
}

# === TRAPS ===
trap handle_error ERR
trap cleanup EXIT

# === SCRIPT BODY ===
log "Starting script..."

# Example commands
cp somefile.txt /nonexistent/path  # This will trigger the error handler

log "Script completed successfully."
