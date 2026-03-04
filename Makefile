lint:
	trunk check --all -y

format:
	trunk fmt --all

activate:
	./scripts/activate-configs.sh

activate-dry:
	./scripts/activate-configs.sh --dry-run

activate-claude:
	./scripts/activate-configs.sh --claude

activate-cursor:
	./scripts/activate-configs.sh --cursor

activate-codex:
	./scripts/activate-configs.sh --codex

activate-gemini:
	./scripts/activate-configs.sh --gemini

activate-copilot:
	./scripts/activate-configs.sh --copilot

activate-antigravity:
	./scripts/activate-configs.sh --antigravity
