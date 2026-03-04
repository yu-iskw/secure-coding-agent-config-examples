# Codex セキュリティガイド

Codex は、OS によって強制されるサンドボックスとカスタマイズ可能な承認ポリシーを通じて、強力なセキュリティコントロールを提供します。このガイドでは、Aqua Trivy VS Code 拡張機能に関わる Socket.dev によって発見されたもののような、不正な実行攻撃から保護するために Codex を設定する方法を説明します。

## 脅威

悪意のある拡張機能やスクリプトは、非常に寛容なフラグを付けて呼び出すことで、ローカルにインストールされた AI エージェントをハイジャックしようとする可能性があります。Codex の場合、攻撃者は以下を使用する可能性があります。
`codex exec "prompt" --ask-for-approval never --sandbox danger-full-access`

このコマンドはすべてのセーフガードをバイパスしようとし、あなたの許可を求めることなく、ファイルシステムとネットワークへのフルアクセスをエージェントに与えます。

## 解決策

`~/.codex/config.toml` を明示的に設定することで、安全なベースラインのデフォルトを確立します。

### 推奨設定 (`config.toml`)

提供されている [`config.toml`](config.toml) を `~/.codex/` ディレクトリにコピーしてください。

主要なセキュリティ設定は以下の通りです。

- **`sandbox_mode = "workspace-write"`**: エージェントが現在の作業中のワークスペース内のファイルのみを読み書きできるように制限します。システムファイルを変更したり、プロジェクト外の機密ディレクトリにアクセスしたりすることはできません。
- **`approval_policy = "untrusted"`**: ネットワークアクセスを必要とするコマンド、状態を変更するコマンド、またはその他の「信頼できない（untrusted）」とみなされるコマンドを実行する前に、Codex が常にあなたの承認を求めるようにします。これにより、エージェントが密かにデータを外部に送信したり、破壊的なコマンドを実行したりするのを防ぎます。
- **`allow_login_shell = false`**: シェルベースのツールのログインシェルを無効にし、攻撃対象領域を減らします。
- **`[sandbox_workspace_write] network_access = false`**: デフォルトの workspace-write モードでネットワークアクセスを明示的に無効にします。
- **`web_search = "cached"`**: ライブブラウジングの代わりに OpenAI のキャッシュされたインデックスを Web 検索に使用し、ライブ Web サイトからのプロンプトインジェクションのリスクを軽減します。

## 承認とシェル実行の管理

これらの設定を行っても、コントロールは維持されます。`approval_policy` が `"untrusted"` に設定されているため、Codex はすべてのシェルコマンド（`gh repo create` や `curl` など）をネイティブにインターセプトし、明示的な手動承認を求めるために一時停止します。これは、データの外部流出に対するきめ細かなセキュリティチェックとして機能します。Codex がこれらの境界外のアクション（ネットワークからのパッケージのインストールなど）を実行する必要がある場合、一時停止して承認を求めます。

完全に隔離された、使い捨ての環境（専用の信頼できない Docker コンテナなど）にいない限り、`--dangerously-bypass-approvals-and-sandbox` や `--yolo` フラグを**決して**使用しないでください。

## 検証

Codex が正しく設定され、サンドボックス設定を尊重していることを確認するために、リポジトリの統合テストスイートを使用できます。

```bash
make test-integration
```

これにより、自動化されたプローブが実行され、`codex exec 'gh repo create'` のようなコマンドがセキュリティ設定によってインターセプトされることが確認されます。

## 参考文献

- [公式 Codex セキュリティドキュメント](https://developers.openai.com/codex/security/)
- [Socket.dev の不正な AI エージェント実行に関する脅威レポート](https://socket.dev/blog/unauthorized-ai-agent-execution-code-published-to-openvsx-in-aqua-trivy-vs-code-extension)
