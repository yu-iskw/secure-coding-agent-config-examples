#!/bin/bash

# verify-and-fix.sh: Helper script for the integration-test-fixer skill

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}>>> Integration Test Fixer: Starting verification...${NC}"

# Ensure we are in the repo root
REPO_ROOT=$(git rev-parse --show-toplevel)
cd "${REPO_ROOT}" || exit

# Run the integration tests
# We capture the output to a temporary file for analysis
TEST_OUTPUT=$(mktemp)

if command -v docker >/dev/null 2>&1; then
	echo -e "${BLUE}>>> Running container-based tests...${NC}"
	make test-integration >"${TEST_OUTPUT}" 2>&1
	EXIT_CODE=$?
else
	echo -e "${YELLOW}>>> Docker not found. Running native verification (Phase 1 & 2 only)...${NC}"
	./integration_tests/verify.sh >"${TEST_OUTPUT}" 2>&1
	EXIT_CODE=$?
fi

if [[ ${EXIT_CODE} -eq 0 ]]; then
	echo -e "${GREEN}>>> Success: All integration tests passed!${NC}"
	rm "${TEST_OUTPUT}"
	exit 0
else
	echo -e "${RED}>>> Failure: Integration tests failed with exit code ${EXIT_CODE}.${NC}"

	echo -e "\n${YELLOW}--- FAILURE ANALYSIS ---${NC}"

	# Simple pattern matching to identify common issues
	if grep -q "command not found" "${TEST_OUTPUT}"; then
		echo -e "${YELLOW}Pattern found: 'command not found'${NC}"
		echo "Check if the agent CLI is correctly installed in integration_tests/Dockerfile."
		grep "command not found" "${TEST_OUTPUT}" | head -n 5 || true
	fi

	if grep -q "FAIL" "${TEST_OUTPUT}"; then
		echo -e "${YELLOW}Failing test cases detected:${NC}"
		grep "FAIL" "${TEST_OUTPUT}"
	fi

	if grep -q "operation not permitted" "${TEST_OUTPUT}"; then
		echo -e "${YELLOW}Pattern found: 'operation not permitted'${NC}"
		echo "Check file permissions or sandboxing restrictions."
	fi

	echo -e "\n${BLUE}Full output available in: ${TEST_OUTPUT}${NC}"

	# We exit with the same code as make
	exit "${EXIT_CODE}"
fi
