# Intent & Issue Analysis Report

## 1. Intent & Issue Analysis

### Stated Problem (X)

The user pointed out: "We don't have any setting files for Antigravity."

### Underlying Intent (Y)

The user wants to provide a secure-by-default configuration file for Antigravity, just like the other AI agents in the repository (Claude Code, Codex, Cursor, Gemini CLI, Copilot CLI), to prevent unauthorized AI agent execution and supply-chain attacks.

### XY Problem Check

The user's stated problem (X) is aligned with the underlying intent (Y). Previously, the `antigravity/README.md` stated that Antigravity only supports UI configuration. However, my research indicates that Antigravity *does* have configuration files: `~/.antigravity_tools/gui_config.json` for global app/proxy settings, and `.antigravity/config.json` for project-level sandbox and security settings. Providing the project-level `.antigravity/config.json` is the correct way to solve the user's root goal.

### Context & Impact

The repository aims to provide a baseline for secure AI agent configurations. Missing a configuration file for Antigravity, when one exists, creates a gap in the security posture provided by this repository. By adding `.antigravity/config.json`, we ensure that users have a concrete, copy-pasteable file to restrict Antigravity's filesystem and network access, preventing malicious automated actions.

## 2. Evaluation Criteria

- **Security (Mitigation of Threat):** How effectively does the approach prevent unauthorized access, file modification, and data exfiltration?
- **Usability (Beginner Friendliness):** How easy is it for a developer to understand and apply the configuration?
- **Maintainability:** How easy is it to keep the configuration up-to-date in this repository?
- **Accuracy:** Does the approach align with how Antigravity actually works according to recent documentation/community knowledge?

## 3. Approaches

### Approach 1: Add project-level `.antigravity/config.json` (Recommended)

- **Description**: Create `antigravity/config.json` in the repo (representing `.antigravity/config.json`), configuring `sandbox` with `allowNetwork: false`, `fileWriteMode: "prompt"`, and defining `protectedPaths`. Update `README.md` to explain how to drop this into a project.
- **Pros**: Provides granular, per-project security. Directly addresses the threat model (unauthorized file deletion, network exfiltration). Easy to copy-paste. High accuracy based on unofficial safety guide.
- **Cons**: Requires users to copy it to every project they use Antigravity in, rather than a single global config.

### Approach 2: Add global `gui_config.json`

- **Description**: Create `antigravity/gui_config.json` (representing `~/.antigravity_tools/gui_config.json`) focusing on AppConfig and ProxyConfig. Update `README.md`.
- **Pros**: Global configuration applied once.
- **Cons**: `gui_config.json` seems more focused on UI state, language, theme, and reverse proxy settings rather than the core sandbox security constraints (which are handled in `.antigravity/config.json`). It's also automatically rewritten by the backend, which might drop unknown or manual fields, making it brittle to distribute as a static file. Low security mitigation value.

### Approach 3: Add both `.antigravity/config.json` and `gui_config.json`

- **Description**: Provide both files in the repository.
- **Pros**: Comprehensive coverage of all possible Antigravity settings.
- **Cons**: Overwhelming for beginners. `gui_config.json` is brittle (as noted above). Increases maintenance burden without significantly adding to the core security goal.

### Approach 4: Maintain UI-only stance but expand documentation

- **Description**: Keep the repository without an Antigravity setting file, but expand `README.md` to exhaustively list every UI toggle needed for security.
- **Pros**: Avoids maintaining JSON files that might change schema.
- **Cons**: Fails to satisfy the user's explicit complaint ("We don't have any setting files"). Manual UI configuration is prone to user error and tedious to reproduce across environments.

### Approach 5: Add a setup script to generate the config

- **Description**: Write a bash/python script that generates the `.antigravity/config.json` based on the user's project structure.
- **Pros**: Can automatically detect `.git` or `.env` and add them to `protectedPaths`.
- **Cons**: Overkill for this repository, which focuses on providing static example configuration files. Adds complexity and potential execution risks.

## 4. Scoring Matrix

| Approach | Security | Usability | Maintainability | Accuracy | Average |
| :--- | :---: | :---: | :---: | :---: | :---: |
| Approach 1 (Project config) | 95 | 90 | 90 | 95 | **92.5** |
| Approach 2 (Global gui config) | 30 | 70 | 60 | 80 | 60.0 |
| Approach 3 (Both configs) | 95 | 60 | 70 | 85 | 77.5 |
| Approach 4 (UI docs only) | 70 | 50 | 95 | 90 | 76.2 |
| Approach 5 (Setup script) | 95 | 70 | 60 | 90 | 78.7 |

*Scores are from 0 to 100.*

## 5. Recommendation

**Approach 1: Add project-level `.antigravity/config.json`** is the clear winner. It directly addresses the user's concern by providing a tangible setting file. More importantly, it provides the most direct and effective security controls (sandbox, network blocking, file write prompting, protected paths) against the threat model we are mitigating, aligning perfectly with the underlying intent. It is also easy to use and maintain. We will create `antigravity/config.json` and update `antigravity/README.md` accordingly.