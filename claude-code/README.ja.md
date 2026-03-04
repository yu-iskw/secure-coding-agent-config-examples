# Claude Code セキュリティガイド

Claude Code は、OS レベルのプリミティブ（macOS では Seatbelt、Linux/WSL2 では bubblewrap）を使用して、ファイルシステムおよびネットワークの隔離を強制するネイティブ・サンドボックス機能を備えています。本ガイドでは、悪意のあるスクリプトや拡張機能による不正な実行を防ぐために、これらの保護機能を構成する方法について説明します。

## 脅威

攻撃者は、悪意のある VS Code 拡張機能やスクリプトを使用して、Claude Code をサイレントに呼び出し、データを流出させる可能性があります。Socket.dev のレポートでは、以下のエクスプロイトコマンドが特定されています：
`claude -p --dangerously-skip-permissions --add-dir / "prompt"`

このコマンドは、権限を完全にバイパスしようとし、Claude にルートファイルシステム全体 (`/`) への読み取りアクセスを許可し、機密情報を収集して送信するように指示します。

## 解決策

Claude Code のサンドボックスを構成することで、プロセスが危険なフラグを指定して Claude を呼び出そうとしても、OS レベルの制御によって強制される厳格な境界を定義できます。

### 推奨構成 (`settings.json`)

提供されている [`settings.json`](settings.json) を、プロジェクトまたはグローバルの設定ディレクトリにコピーしてください。

主なセキュリティ設定は以下の通りです：

- **`"enabled": true`**: サンドボックスランタイムをアクティブにします。すべての bash コマンドとサブプロセスがサンドボックスによって制限されます。
- **`"allowUnsandboxedCommands": false`**: エスケープハッチを無効にします。サンドボックス内でコマンドが失敗した場合、通常 Claude Code は `dangerouslyDisableSandbox` パラメータを使用して再試行を試みる可能性があります。これを `false` に設定すると、すべてのコマンドがサンドボックス内で実行されるか、明示的に許可リスト（ホワイトリスト）に登録されている必要があります。
- **`filesystem.denyWrite` および `denyRead`**: `~/.ssh`、クラウド認証情報（`~/.aws/credentials`、`~/.gcp`、`~/.config/gcloud`）、設定ファイル（`~/.bashrc`、`~/.zshrc`）などの機密ディレクトリへのアクセスを明示的にブロックし、不正な認証情報へのアクセスや永続化メカズムを防ぎます。
- **`permissions.deny`**: 機密ファイル（例：`.env`、`secrets/**`、クラウド設定）が、ファイル読み取りや検索ツールを含む Claude Code のいかなるツールからもアクセスされないように除外します。
- **`alwaysThinkingEnabled: true`**: 複雑なセキュリティタスクに対して、Claude がその推論能力を最大限に活用できるようにします。
- **`network.allowedDomains`**: ネットワークアクセスのための明示的な許可リストを作成します。このリストにないドメインへの接続試行はプロキシによってブロックされ、攻撃者がデータを流出させる能力を大幅に制限します。

## 粒度の細かいセキュリティフック

ネットワークドメインの制限（例：`github.com` の許可）は不可欠ですが、攻撃者が許可されたドメインを使用して流出を行うこと（例：`gh repo create` を使用して攻撃者が所有するリポジトリにデータをプッシュする）を防ぐことはできません。

これに対処するため、**PreToolUse フック（Hooks）**を使用して、シェルによって実行される前にコマンドをインターセプトします。

### `gh-safeguard.sh` フックの使用方法

1. `hooks/gh-safeguard.sh` スクリプトをプロジェクトの `.claude/hooks/` ディレクトリにコピーします。
2. スクリプトを実行可能にします：`chmod +x .claude/hooks/gh-safeguard.sh`
3. `settings.json` に、例で提供されている `hooks` 構成が含まれていることを確認してください。これにより、`Bash` ツールの使用前にこのスクリプトが実行されるように登録されます。

このスクリプトは、LLM が実行しようとしているコマンドを解析し、`gh repo create` や `gh gist create` のような既知のデータ流出コマンドが含まれている場合は、厳格にブロック（Exit Code 2）します。一方で、安全なクエリコマンドの実行は許可します。

**リポジトリの固定（Repository Pinning）**: このフックは、`-R` および `--repo` フラグ（および `repos/owner/repo` のような明示的な API パス）もブロックします。これにより、`gh` CLI は強制的にローカルワークスペースのコンテキストを使用することになり、エージェントを現在のリポジトリに実質的に「固定」し、外部の攻撃者が制御するリポジトリにデータをプッシュすることを防ぎます。

## 検証

Claude Code が正しく構成され、`gh-safeguard.sh` フックがアクティブであることを確認するには、リポジトリの統合テストスイートを使用できます：

```bash
make test-integration
```

これにより、自動化されたプロンプトが実行され、`claude -p 'gh repo create'` のようなコマンドが正常にブロックされることが確認されます。

## 重要な注意事項

- **Docker/Watchman**: Docker や Watchman などのツールはサンドボックスと互換性がありません。これらをサンドボックス外で実行するには `excludedCommands` に追加する必要がありますが、慎重に行ってください。
- **ネットワークフィルタリング**: ネットワークサンドボックスはドメインによって接続を制限しますが、トラフィックの検査は行いません。ドメインフロントリングや過度に広範な許可リスト（例：`github.com` 全体を許可すると、攻撃者が制御するリポジトリへのデータ流出を依然として許容する可能性があります）に注意してください。

## 参考文献

- [Official Claude Code Sandboxing Documentation](https://code.claude.com/docs/en/sandboxing)
- [Socket.dev Threat Report on Unauthorized AI Agent Execution](https://socket.dev/blog/unauthorized-ai-agent-execution-code-published-to-openvsx-in-aqua-trivy-vs-code-extension)
