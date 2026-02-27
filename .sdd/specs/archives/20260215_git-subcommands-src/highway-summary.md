# Highway Summary

## 対象spec
- `git-subcommands-src`

## 実施内容
要件定義とステアリングをもとに、公開スクリプトを `src/` 配下へ集約する実装を実施しました。

## RED（テスト先行）
- 既存テストの実行対象を `src/git-*` に変更。
- `test/test_src_layout.sh` を新規追加し、`src/git-*` の存在と実行可能属性を検証。
- この時点で `src/` 未作成のためテスト失敗を確認。

## GREEN（最小実装）
- `src/` を作成し、`git-latest` / `git-local-branch` / `git-merged` / `git-last` を移動。
- 各スクリプトの `lib/common.sh` 参照を `src/` 配下起点に修正。
- `README.md` のセットアップ手順を `src/` 前提へ更新。
- `bash test/run.sh` で全テスト成功を確認。

## REFACTOR（整備）
- 追加した配置テストを含め、テスト構成を `src/` 前提で統一。
- `bash -n` によるシェル構文チェックを実施し成功を確認。

## 変更ファイル
- 追加: `test/test_src_layout.sh`
- 変更: `test/test_git_latest.sh`
- 変更: `test/test_git_local_branch.sh`
- 変更: `test/test_git_merged.sh`
- 変更: `test/test_git_last.sh`
- 変更: `src/git-latest`
- 変更: `src/git-local-branch`
- 変更: `src/git-merged`
- 変更: `src/git-last`
- 変更: `README.md`

## 検証結果
- `bash test/run.sh` : 成功
- `bash -n src/git-latest src/git-local-branch src/git-merged src/git-last lib/common.sh test/run.sh test/test_helpers.sh test/test_git_latest.sh test/test_git_local_branch.sh test/test_git_merged.sh test/test_git_last.sh test/test_src_layout.sh` : 成功
