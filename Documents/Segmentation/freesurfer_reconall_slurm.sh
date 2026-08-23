#!/usr/bin/env bash
#SBATCH --job-name=fs_reconall
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --time=36:00:00
#SBATCH --output=%x_%j.out
#SBATCH --error=%x_%j.err

set -euo pipefail

usage() {
  echo "Usage: sbatch $0 SUBJECT_ID INPUT_T1_NIFTI SUBJECTS_DIR" >&2
  exit 2
}

[[ $# -eq 3 ]] || usage

SUBJECT_ID=$1
INPUT_T1=$2
OUTPUT_SUBJECTS_DIR=$3
THREADS=${SLURM_CPUS_PER_TASK:-8}
HIRES=${HIRES:-0}

[[ "$SUBJECT_ID" =~ ^[A-Za-z0-9._-]+$ ]] || { echo "Unsafe subject ID" >&2; exit 2; }
[[ -s "$INPUT_T1" ]] || { echo "Input not found: $INPUT_T1" >&2; exit 2; }
mkdir -p "$OUTPUT_SUBJECTS_DIR"

# Adapt these two lines to the execution environment.
module load FreeSurfer/8.1.0-rocky8_x86_64
export FS_LICENSE=${FS_LICENSE:-/path/to/freesurfer/license.txt}
export SUBJECTS_DIR=$OUTPUT_SUBJECTS_DIR

[[ -r "$FS_LICENSE" ]] || { echo "FreeSurfer licence not readable: $FS_LICENSE" >&2; exit 2; }
command -v recon-all >/dev/null || { echo "recon-all is not available" >&2; exit 2; }

subject_dir="$SUBJECTS_DIR/$SUBJECT_ID"
args=(-subject "$SUBJECT_ID" -all -parallel -openmp "$THREADS")

if [[ ! -d "$subject_dir" ]]; then
  args+=(-i "$INPUT_T1")
fi

if [[ "$HIRES" == "1" ]]; then
  args+=(-hires)
fi

echo "FreeSurfer: $(recon-all -version 2>&1 | head -n 1)"
echo "Subject: $SUBJECT_ID"
echo "Input: $INPUT_T1"
echo "SUBJECTS_DIR: $SUBJECTS_DIR"
echo "SHA-256: $(sha256sum "$INPUT_T1" | awk '{print $1}')"

recon-all "${args[@]}"

log_file="$subject_dir/scripts/recon-all.log"
grep -q "finished without error" "$log_file" || {
  echo "recon-all did not report successful completion; inspect $log_file" >&2
  exit 1
}

echo "Completed successfully: $subject_dir"
