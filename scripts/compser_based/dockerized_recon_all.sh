#!/bin/bash

# Ensure correct usage
if [ "$#" -ne 4 ]; then
    echo "Usage: $0 <FS_VERSION> <IMAGE_PATH> <SUBJECT_ID> <OUTPUT_DIR>"
    echo "Example: $0 6.0 /path/to/subject1.nii.gz subject1 /path/to/output"
    exit 1
fi

FS_VERSION=$1
IMAGE_PATH=$2
SUBJECT_ID=$3
OUTPUT_DIR=$4

# Ensure input and output directories exist
mkdir -p ./input
mkdir -p "$OUTPUT_DIR"

# Copy the image to the input folder
cp "$IMAGE_PATH" ./input/ -v

# Select the correct container name based on the version
case $FS_VERSION in
  5.3)
    CONTAINER_NAME="freesurfer53"
    ;;
  6.0)
    CONTAINER_NAME="freesurfer60"
    ;;
  7.4.1)
    CONTAINER_NAME="freesurfer741"
    ;;
  *)
    echo "Unsupported FreeSurfer version: $FS_VERSION"
    exit 1
    ;;
esac

# Run recon-all in the correct FreeSurfer container with the specified output directory
docker compose run --rm \
  -v "$OUTPUT_DIR":/output \
  "$CONTAINER_NAME" \
  -i /input/$(basename "$IMAGE_PATH") -subjid "$SUBJECT_ID" -all -sd /output

# Move processed images to avoid conflicts
mv ./output "$OUTPUT_DIR/"
mv ./input/$(basename "$IMAGE_PATH") "$OUTPUT_DIR/"

