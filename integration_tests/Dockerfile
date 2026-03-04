FROM node:22-slim

# Install base dependencies and Cursor/Claude Code native dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    git \
    sudo \
    gnupg \
    software-properties-common \
    jq \
    libnss3 \
    libatk1.0-0 \
    libatk-bridge2.0-0 \
    libcups2 \
    libdrm2 \
    libgtk-3-0 \
    libgbm1 \
    libasound2 \
    && rm -rf /var/lib/apt/lists/*

# Install GitHub CLI (gh)
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && apt-get update \
    && apt-get install gh -y --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

# Install coding agent CLIs in separate layers for better caching and visibility
RUN npm install -g @openai/codex
RUN npm install -g @github/copilot
RUN npm install -g @google/gemini-cli

# Create a test user
RUN useradd -m testuser && echo "testuser:testuser" | chpasswd && adduser testuser sudo
USER testuser
WORKDIR /home/testuser/app

# Set PATH to include local bin for native installers
ENV PATH="/home/testuser/.local/bin:${PATH}"

# Install Claude Code via native installer (as testuser)
RUN curl -fsSL https://claude.ai/install.sh | bash

# Install Cursor agent CLI (as testuser)
RUN curl -fsSL https://cursor.com/install | bash

# Copy the verification script (to be created next)
COPY --chown=testuser:testuser integration_tests/verify.sh ./integration_tests/verify.sh
RUN chmod +x ./integration_tests/verify.sh

ENTRYPOINT ["./integration_tests/verify.sh"]

HEALTHCHECK NONE
