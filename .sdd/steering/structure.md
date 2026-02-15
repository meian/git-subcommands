# Project Structure

## ルートディレクトリ構成
```text
/
├── git-last
├── git-latest
├── git-local-branch
├── git-merged
├── LICENSE
├── README.md
├── lib/
│   └── common.sh
├── test/
│   ├── run.sh
│   ├── test_helpers.sh
│   ├── test_git_latest.sh
│   ├── test_git_local_branch.sh
│   ├── test_git_merged.sh
│   └── test_git_last.sh
└── .sdd/
    ├── README.md
    ├── description.md
    ├── specs/
    ├── steering/
    │   ├── product.md
    │   ├── tech.md
    │   └── structure.md
    └── target-spec.txt
```

## コード構成パターン
`git-*` のコマンド本体と `lib/common.sh` の共通処理を分離し、`test/` にシェルスクリプトの結合テストを配置する構成です。
現時点では `git-*` がリポジトリ直下に存在しますが、仕様上の配置方針は「ユーザー公開スクリプトを `src/` 配下に置く」です。

## ファイル命名規則
- Git サブコマンド実行ファイル：`git-*`
- ステアリング文書：`.sdd/steering/*.md`
- テストスクリプト：`test/test_*.sh`
- 公開スクリプト配置方針：`src/` 配下

## 主要な設計原則
- 仕様準拠：`.sdd/description.md` に定義された機能（`latest` / `local-branch` / `merged`）に沿って実装する
- 依存関係の明示：`fzf` 必須機能は、未導入環境で実行不可と分かる挙動にする
