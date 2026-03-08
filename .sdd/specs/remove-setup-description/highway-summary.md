# Highway Summary

## 対象 spec
- remove-setup-description

## 設計
- 変更対象をドキュメントに限定し、実装コード（`src/`・`lib/`）および既存テストロジックには手を入れない。
- README運用ルールに従い、`README.md` と `README.ja.md` を同時に更新し、見出し構成を一致させる。
- 不要になったセットアップ説明（手動 `chmod` と手動 `PATH` 追加）を削除し、利用者向けの実行例は `Usage` / `使い方` として維持する。

## 実装
- `README.md`
  - `## Setup` セクションを削除。
  - 代わりに `## Usage` セクションを配置し、インストール後の利用例のみ記載。
- `README.ja.md`
  - `## セットアップ` セクションを削除。
  - 代わりに `## 使い方` セクションを配置し、インストール後の利用例のみ記載。

## 検証
- ドキュメント確認:
  - `rg -n "^## Setup$|^## セットアップ$|chmod \+x src/git-latest src/git-local-branch src/git-merged src/git-last" README.md README.ja.md`
  - ヒットなしを確認。
- 既存テスト実行:
  - `bash test/run.sh`
  - 結果: All tests passed

## 補足
- ドキュメント修正確認のための新規テストファイルは作成しない方針に合わせ、専用テスト追加は行っていない。
