# セキュアなAIエージェント設定 (Secure AI Agent Configurations)

5つの人気のあるAIコーディングエージェント向けの、デフォルトでセキュアな設定ファイルと教育用ドキュメントのコレクションです。

このリポジトリは、開発者に対して、ツール自体の利便性を損なうことなく、サプライチェーン攻撃によるローカルAIエージェントの乗っ取り、データ搾取、システム改ざんを防止するためのセキュアなベースラインを提供します。

## 脅威モデル (The Threat Model)

AIアシスタントが開発ワークフローに統合されるにつれ、攻撃対象領域（アタックサーフェス）も拡大しています。これらを呼び出すことができるツールは、その権限を継承します。

2026年3月、[Socket.devは脅威レポートを公開し](https://socket.dev/blog/unauthorized-ai-agent-execution-code-published-to-openvsx-in-aqua-trivy-vs-code-extension)、AIを利用した新しい形式のサプライチェーン悪用について詳しく説明しました。悪意のあるアクターが人気のVS Code拡張機能（Aqua Trivy）にコードを注入し、インストールされているローカルのAIコーディングアシスタントを密かに呼び出そうとしました。

このエクスプロイトは、人間による承認（human-in-the-loop）をバイパスするために、非常に許容度の高いフラグを使用しました：

- `claude -p --dangerously-skip-permissions --add-dir / "prompt"`
- `codex exec "prompt" --ask-for-approval never --sandbox danger-full-access`
- `gemini prompt "prompt" --yolo --no-stream`
- `copilot --autopilot --yolo -p "prompt"`

注入された自然言語プロンプトは、これらのエージェントに対し、広範なシステム調査を行い、資格情報を収集し、そのデータを外部に送信（エクスフィルトレーション）するよう指示しました。

## 対策 (The Mitigation)

この新たな脅威に対する防御策は、**OSレベルのサンドボックス化**と**厳格な承認ポリシー**です。

AIエージェントを適切に設定することで、カーネルレベル（macOS Seatbelt、Linux Bubblewrap、Dockerコンテナなどの技術を使用）でこれらの悪意のある実行を遮断できます。適切にサンドボックス化されたエージェントは、たとえ`--yolo`のような危険なフラグで呼び出されたとしても、機密性の高いシステムファイルにアクセスしたり、許可されていないネットワーク接続を確立したりすることはできません。

## エージェントガイド (Agent Guides)

以下のAIエージェント向けに、初心者向けの設定ファイル、セットアップ手順、セキュリティガイドラインをまとめました：

- [Claude Code](./claude-code/README.ja.md) - ネイティブサンドボックス（Seatbelt/Bubblewrap）の強制とサンドボックス外へのエスケープの無効化。
- [Codex](./codex/README.ja.md) - ワークスペース書き込みのサンドボックス化と信頼できない承認ポリシーの設定。
- [Gemini CLI](./gemini-cli/README.ja.md) - ツール用サンドボックス（Seatbelt/Docker）の有効化。
- [Cursor](./cursor/README.ja.md) - Cursor 2.0で導入されたエージェントサンドボックス設定。
- [Antigravity](./antigravity/README.ja.md) - 厳格モード（Strict Mode）とターミナルサンドボックスの有効化。
- [GitHub Copilot CLI](./copilot-cli/README.ja.md) - Dockerサンドボックスの活用と信頼できるフォルダの制限。

各ディレクトリには、文書化された設定テンプレート（該当する場合）と、各セキュリティ設定の「理由」と「方法」を説明する`README.md`が含まれています。

## クイックセットアップ（有効化） (Quick Setup (Activation))

このリポジトリのセキュリティ設定をローカル環境で迅速に有効化するには、提供されている`make`ターゲットを使用できます。これにより、設定ファイルがローカルの非表示ディレクトリ（`.claude/`、`.cursor/`など）にシンボリックリンクされます。

### 前提条件 (Prerequisites)

- `make`がインストールされていること。
- リポジトリがローカルプロジェクトディレクトリにクローンされていること。

### コマンド (Commands)

サポートされているすべてのエージェント設定を一度に有効化する：

```bash
make activate
```

または、特定のエージェントの設定を有効化する：

```bash
make activate-claude
make activate-cursor
make activate-gemini
# など
```

利用可能なターゲットのリストについては、[Makefile](./Makefile)を確認してください。

### 検証 (Verification)

ローカルの非表示ディレクトリにシンボリックリンクが存在することを確認することで、有効化を検証できます：

```bash
ls -l .claude/settings.json
ls -l .cursor/sandbox.json
```

## 継続的な検証 (Continuous Verification)

このリポジトリには、最新のエージェントCLIによってセキュリティ設定が正しく解析されていること、およびセキュリティフック（`gh-safeguard.sh`など）が隔離された環境で禁止されたアクションを効果的にブロックしていることを検証するための、コンテナベースの統合テストスイートが含まれています。

詳細は、[統合テスト](./integration_tests/README.ja.md)のドキュメントを参照してください。

### テストの実行 (Running Tests)

ローカルで完全な統合テストスイートを実行するには：

```bash
make test-integration
```

これにより、サポートされているすべてのエージェントCLIがインストールされたDockerイメージがビルドされ、一連の「データ搾取プローブ（exfiltration probes）」が実行され、保護機能が意図通りに動作していることが確認されます。

## エージェントスキル (Agent Skills)

これらの設定の保守と検証を自動化するための専用のAIエージェントスキルを提供しています。

- **[統合テスト修正ツール（Integration Test Fixer）](./.claude/skills/integration-test-fixer/SKILL.md)**: 統合テストを自動的に実行し、一般的なパターンを使用して失敗を分析し、設定や環境への修正を提案または適用します。
