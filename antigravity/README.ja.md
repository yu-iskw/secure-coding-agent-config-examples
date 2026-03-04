# Antigravity セキュリティガイド

Google Antigravity は、カーネルレベルの隔離（macOS では Apple の Seatbelt メカニズム）を使用して、AI エージェント用のターミナル・サンドボックスを提供します。これを有効にすると、コマンドは制限されたファイルシステムおよびネットワークアクセスを持つ隔離された環境で実行され、意図しない変更からシステムを保護します。

## 脅威

侵害された環境や悪意のあるスクリプトが、危険な権限を持つ AI エージェントを密かに呼び出そうとする可能性があります（Aqua Trivy 拡張機能における `--yolo` エクスプロイトを発見した Socket.dev のレポートなどがその例です）。チェックされていない AI エージェントは、ファイルシステムを探索したり、システムファイルを変更したり、インターネット経由で認証情報を外部に流出させたりする可能性があります。

## 解決策

Antigravity の設定を構成することで、OS レベルの制御によって強制される厳格な境界を定義できます。これは、任意の破壊的なコマンドの自動的かつサイレントな実行をブロックするために特に重要です。

プロジェクトを保護するために、Antigravity はプロジェクトレベルの構成ファイルをサポートしています。

### ターミナル・サンドボックスと権限の構成方法

Antigravity エージェントを安全に構成するには、提供されている `config.json` ファイルをプロジェクトにコピーします：

1. プロジェクトのルートに `.antigravity` という名前のディレクトリを作成します。
2. このリポジトリから [`config.json`](config.json) ファイルをそのディレクトリにコピーします（例：`your-project/.antigravity/config.json`）。

この構成ファイルは、いくつかの重要なセキュリティ対策を実装しています：

- **厳格なサンドボックス**: `sandbox.enabled: true` により、エージェントが定義された制限内で動作することを保証します。
- **きめ細かな権限**:
  - `permissions.fileWrite: "prompt"` により、エージェントがユーザーの明示的な承認なしにサイレントにファイルを変更または削除できないようにします。
  - `permissions.networkAccess: "localhost-only"` により、エージェントがデータを外部サーバーに送信したり、信頼できないコードをダウンロードしたりすることをブロックします。
  - `permissions.systemCommands: "blocked"` により、任意のシステムレベルのコマンドの実行を防ぎます。
- **保護されたパス**: `protectedPaths` 配列は、`.git`、`.env`、クラウド認証情報（`~/.aws/credentials`、`~/.gcp`、`~/.config/gcloud`）、システム構成ディレクトリ（`/etc`、`/usr/bin`）などの機密性の高い場所へのアクセスを明示的に拒否し、偶発的または悪意のある変更を防ぎます。
- **監査ログ**: `audit.enabled: true` および `audit.backupBeforeChanges: true` により、すべてのアクションがログに記録され、変更が行われる前にバックアップが保持されるようになります。

### グローバル UI 設定（任意）

プロジェクトレベルの `.antigravity/config.json` に加えて、グローバルな保護を強制することもできます：

1. **Antigravity User Settings** を開きます。
2. **Enable Terminal Sandboxing** を **On** に切り替えます（macOS Seatbelt を強制します）。
3. **Sandbox Allow Network** トグルを **Off** に設定します。

### ストリクトモード（Strict Mode）の代替案

非常に機密性の高い環境で作業する場合は、最大限の保護を強制できます：

- Antigravity User Settings で **Strict Mode** を有効にします。
  - _動作の内容:_ ストリクトモードが有効な場合、ネットワークアクセスが拒否された状態でサンドボックスが自動的にアクティブになり、シェル実行の前に手動のユーザープロンプトを強制します。人間がすべてのコマンドを確認する必要があるため、`gh` CLI などのツールを使用した高度なデータ流出手法を効果的に軽減できます。

### サンドボックス違反への対処

エージェントコマンドがサンドボックス外のネットワークアクセスまたはファイルシステムアクセスを正当に必要とする場合は、**Request Review** モードを介して構成できます。これにより、潜在的に危険なアクションが発生する前に人間が介在することが保証されます。

## 検証

Antigravity が正しく構成され、サンドボックスがアクティブであることを確認するには、リポジトリの統合テストスイートを使用できます：

```bash
make test-integration
```

これにより、自動化されたプロンプトが実行され、セキュリティ構成が正しく登録され、不正な探索に対して有効であることが確認されます。

## 参考文献

- [Official Google Antigravity Sandboxing Documentation](https://antigravity.google/docs/sandbox-mode)
- [Socket.dev Threat Report on Unauthorized AI Agent Execution](https://socket.dev/blog/unauthorized-ai-agent-execution-code-published-to-openvsx-in-aqua-trivy-vs-code-extension)
