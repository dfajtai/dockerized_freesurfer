#!/bin/bash
set -e

# Store the original working directory
ORIGINAL_DIR=$(pwd)

# Path to the docker folder
SCRIPT_DIR="/docker_part/freesurfer_dockers"

# Full path to the Docker Compose file and the recon-all script
DOCKER_COMPOSE_FILE="$SCRIPT_DIR/docker-compose.yml"
DOCKER_RECON_SCRIPT="$SCRIPT_DIR/dockerized_recon_all.sh"

# Function to convert DICOM to NIfTI
convdcm() {
    mkdir -p -v nii
    dcm2niix -o nii -m y -i y -f %d_%s -5 -z y dcm/
}

if [ -d "nii" ];
then
    rm nii/* -v
fi



# Convert DICOM to NIfTI
convdcm

# Prepare the input for FreeSurfer
mkdir -p freesurfer_input -v
cp nii/t1*mprage*.nii.gz freesurfer_input/t1.nii.gz -v
mkdir -p freesurfer_output -v

# Navigate to the Docker folder
cd "$SCRIPT_DIR"

# Call the dockerized recon-all script using the original paths for inputs and outputs
bash "$DOCKER_RECON_SCRIPT" 5.3 "$ORIGINAL_DIR/freesurfer_input/t1.nii.gz" t001 "$ORIGINAL_DIR/freesurfer_output"

# Return to the original working directory
cd "$ORIGINAL_DIR"
