---
name: lint-fix
description: Formats, lints, and auto-fixes codebase using Trunk via Makefile. Use this skill when you need to format code, fix lint errors, run the formatter, or run the linter.
allowed-tools: Bash
---

# Lint & Fix Skill

Use this skill whenever you need to format code, check for lint errors, or auto-fix linting issues across the codebase. It uses the project's standard `make format` and `make lint` targets, which wrap Trunk to process the files.

## Instructions

1. **Run the format and lint script**:
   Use the `Bash` tool to execute the `scripts/run.sh` wrapper script. This script will automatically run the Makefile targets to format and lint the code.

   ```bash
   ./.claude/skills/lint-fix/scripts/run.sh
   ```

2. **Review Output**:
   - The script runs `make format` followed by `make lint`.
   - If the script succeeds, the code is properly formatted and all fixable lint issues have been resolved.
   - If the script fails, carefully read the output. There might be linting errors that Trunk could not automatically fix. In this case, use your editing tools to manually fix the reported issues and re-run the script.

3. **Communicate Results**:
   Once formatting and linting are successfully completed, provide a brief summary of the results to the user.
