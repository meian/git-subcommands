# Project Structure

## ルートディレクトリ構成
```text
/
├── LICENSE
├── README.md
├── lib/
│   └── common.sh
├── src/
│   ├── git-last
│   ├── git-latest
│   ├── git-local-branch
│   └── git-merged
├── test/
│   ├── run.sh
│   ├── test_helpers.sh
│   ├── test_git_latest.sh
│   ├── test_git_local_branch.sh
│   ├── test_git_merged.sh
│   ├── test_git_last.sh
│   └── test_src_layout.sh
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
`src/git-*` のコマンド本体と `lib/common.sh` の共通処理を分離し、`test/` にシェルスクリプトの結合テストを配置する構成です。

## ファイル命名規則
- Git サブコマンド実行ファイル：`git-*`
- ステアリング文書：`.sdd/steering/*.md`
- テストスクリプト：`test/test_*.sh`
- 公開スクリプト配置：`src/` 配下

## 主要な設計原則
- 仕様準拠：`.sdd/description.md` に定義された機能（`latest` / `local-branch` / `merged`）に沿って実装する
- 依存関係の明示：`fzf` 必須機能は、未導入環境で実行不可と分かる挙動にする
