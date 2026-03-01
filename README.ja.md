# git-subcommands

`git-*` という名前の実行ファイルとして実装された、カスタム Git サブコマンド集です。

English version: [README.md](README.md)

## サブコマンド

- `git latest <branch>`
  - 対象ブランチに切り替え、fast-forward only でリモートから更新します。
- `git local-branch [branch-pattern]`
  - `fzf` でローカルブランチを選択して切り替えます。
  - `branch-pattern` を指定した場合、一致するローカルブランチのみ候補になります。
- `git merged [-clean]`
  - 現在のブランチにマージ済みのローカルブランチを一覧表示します。
  - `-clean` を指定すると、表示されたマージ済みローカルブランチを削除します。
- `git last [-n]`
  - 最新コミットの diff を表示します。
  - `-n`（正の整数）を指定すると、`HEAD` から `n` 個前のコミット（例: `-1`, `-2`）の diff を表示します。

## 必要要件

- `bash` または `zsh`（対応する対話シェル環境）
- `git`
- `fzf`（`git local-branch` で必要）

## インストール

GitHub（デフォルトブランチ）からインストール:

```bash
curl -fsSL https://raw.githubusercontent.com/meian/git-subcommands/main/install.sh | sh
```

既存インストールを更新:

```bash
curl -fsSL https://raw.githubusercontent.com/meian/git-subcommands/main/install.sh | sh -s -- --update
```

特定ブランチをインストール:

```bash
curl -fsSL https://raw.githubusercontent.com/meian/git-subcommands/main/install.sh | sh -s -- --branch feature/my-branch
```

特定タグをインストール:

```bash
curl -fsSL https://raw.githubusercontent.com/meian/git-subcommands/main/install.sh | sh -s -- --tag v1.0.0
```

インストールコマンドは、実行中のシェル種別（bash/zsh）に関係なく同じ手順で利用できます。

インストーラーは対話モード向けに `.bashrc` と `.zshrc` へ管理ブロックを追加し、`~/.git-subcommands.rc` を読み込むように設定します。
`~/.git-subcommands.rc` では `~/.local/share/git-subcommands/src` を `PATH` に追加します。

## セットアップ

1. スクリプトに実行権限を付与:
   - `chmod +x src/git-latest src/git-local-branch src/git-merged src/git-last`
2. `src/` ディレクトリを `PATH` に追加。

以降は通常の Git サブコマンドとして実行できます:

- `git latest main`
- `git local-branch feature`
- `git merged -clean`
- `git last -1`

## アンインストール

次を実行:

```bash
curl -fsSL https://raw.githubusercontent.com/meian/git-subcommands/main/uninstall.sh | sh
```

またはローカルスクリプトを実行:

```bash
./uninstall.sh
```

アンインストーラーは `.bashrc` と `.zshrc` の管理ブロックを削除し、`~/.git-subcommands.rc` も削除します。

## テスト

- `bash test/run.sh`
