# GitHub Copilot CLI セキュリティガイド

GitHub Copilot CLI は、コマンドの実行を支援するためのターミナルベースの対話型インターフェースを提供します。不正な実行攻撃（悪意のある VS Code 拡張機能で見られるようなもの）から保護するために、GitHub Copilot CLI を安全な Docker サンドボックス内で実行することを強く推奨します。

## 脅威

Socket.dev のレポートでは、攻撃者によって使用される以下のエクスプロイトコマンドが特定されています。
`copilot --autopilot --yolo -p "prompt"`

`--yolo` フラグは、Copilot の標準的なセーフティプロンプトをバイパスし、任意のコマンドを自動的に実行するため、特に危険です。ホストマシン上で直接実行された場合、エージェントはホームディレクトリ、SSH キー、システムファイルへのフルアクセス権を持つことになります。

## 対策

### 1. Docker サンドボックスの使用

GitHub Copilot CLI をホスト OS 上で直接実行する代わりに、Docker コンテナ内で実行してください。これにより、たとえ攻撃者が `--yolo` コマンドを呼び出すことに成功したとしても、エージェントの「影響範囲（ブラストライジアス）」は、マウントされた特定のプロジェクトディレクトリとコンテナ内に完全に限定されます。

- ルートディレクトリ `/` やホームディレクトリ `~` を Docker サンドボックスにマウントしないでください。
- 現在アクティブに作業している特定のワークスペースディレクトリ（例: `/workspace`）のみをマウントしてください。

### 2. 信頼されたフォルダーの慎重な設定

どうしてもローカルで GitHub Copilot CLI を実行する必要がある場合は、`~/.copilot/config.json` で `trusted_folders` を定義することで、特定のディレクトリに対して*のみ*セーフティプロンプトを無効にできます。

例として [`config.json`](config.json) を参照してください。

```json
{
  "trusted_folders": ["/workspace", "/home/agent/projects"]
}
```

**警告:** `trusted_folders` 配列に `/` や `~` を絶対に追加しないでください。追加すると、攻撃者のスクリプトがあなたの承認なしにシステムのあらゆる場所で破壊的なコマンドを実行できるようになります。

## 検証

GitHub Copilot CLI が正しく設定され、信頼されたフォルダーを尊重しているかを確認するために、リポジトリの統合テストスイートを使用できます。

```bash
make test-integration
```

これにより、設定が有効であり、コンテナ環境で指定された信頼されたフォルダーが正しく登録されていることが確認されます。

## 参考文献

- [Docker ドキュメント: Copilot サンドボックス](https://docs.docker.com/ai/sandboxes/agents/copilot/)
- [Socket.dev の不正な AI エージェント実行に関する脅威レポート](https://socket.dev/blog/unauthorized-ai-agent-execution-code-published-to-openvsx-in-aqua-trivy-vs-code-extension)
