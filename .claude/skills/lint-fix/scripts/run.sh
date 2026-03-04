#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status
set -e

# Change to the project root directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../../../.." && pwd)"

cd "${PROJECT_ROOT}"

echo "Running make format..."
make format || {
	echo "make format failed"
	exit 1
}

echo "Running make lint..."
make lint || {
	echo "make lint failed"
	exit 1
}

echo "Formatting and linting completed successfully."
