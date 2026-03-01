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

- `git`
- `fzf`（`git local-branch` で必要）

## セットアップ

1. スクリプトに実行権限を付与:
   - `chmod +x src/git-latest src/git-local-branch src/git-merged src/git-last`
2. `src/` ディレクトリを `PATH` に追加。

以降は通常の Git サブコマンドとして実行できます:

- `git latest main`
- `git local-branch feature`
- `git merged -clean`
- `git last -1`

## テスト

- `bash test/run.sh`
