# 実装タスクリスト

## セクション1：データモデル実装
- [x] 1.1 必要な型定義・データ構造を作成する
  - design.md の `InstallOptions`（`update` / `branch` / `tag` / `repo_url`）をシェル変数として定義する
  - design.md の `ResolvedRef`（`mode` / `name` / `revision`）を扱うための内部表現を実装する
  - `--branch` と `--tag` の排他バリデーションを実装する
- [x] 1.2 データ永続化層を実装する
  - design.md の `InstallState` を保存する state ファイル（例: `.install-ref`）の read/write を実装する
  - 現在状態（mode/ref/revision）の比較ロジックを実装し、再インストール要否を返せるようにする
  - `~/.local/share/git-subcommands` 不在時の初期化処理を実装する

## セクション2：ビジネスロジック実装
- [x] 2.1 Installer CLI (`install.sh`) のコア処理を実装する
  - design.md の処理フロー 1-3（引数解析、ref 解決、再取得判定）に対応する
  - 要件2/3に対応して no-op、`--update`、`--branch`、`--tag` を分岐実装する
  - 取得した ref を `~/.local/share/git-subcommands` へ配置し state を更新する
- [x] 2.2 Profile Manager / 設定反映処理を実装する
  - design.md の処理フロー 5-6（`~/.git-subcommands.rc` 生成、bash/zsh 管理ブロック追加）に対応する
  - `~/.local/share/git-subcommands/src` を PATH へ追加する処理を `~/.git-subcommands.rc` に実装する
  - 重複追加を防ぐ idempotent 処理を実装する
- [x] 2.3 Uninstaller CLI (`uninstall.sh`) とエラーハンドリングを実装する
  - design.md の処理フロー 8（配置物削除、管理ブロック除去、冪等終了）を実装する
  - design.md のエラーケース1-5（依存不足、引数競合、ref 取得失敗、書込失敗、未存在対象）を処理する
  - 終了コードとエラーメッセージを統一する

## セクション3：インターフェース実装
- [x] 3.1 CLIインターフェースを作成する
  - `install.sh` の usage（`--update` / `--branch` / `--tag`）を実装する
  - `uninstall.sh` の usage と実行結果メッセージを実装する
  - 成功時に `source ~/.git-subcommands.rc` または再起動案内を表示する
- [x] 3.2 入力バリデーションを実装する
  - 未知オプション、引数不足、排他違反の検証を実装する
  - 指定 branch/tag の存在検証を実装する
  - `git` 未導入時の前提チェックを実装する
- [x] 3.3 出力フォーマットを実装する
  - no-op / update / reinstall / uninstall の結果メッセージ形式を統一する
  - エラー時に「原因」と「対処ヒント」を簡潔に表示する
  - README 記載コマンドと出力メッセージの整合を取る

## セクション4：統合とテスト
- [x] 4.1 コンポーネントを統合する
  - Installer CLI、Ref Resolver、Install State Store、Profile Manager、Uninstaller CLI を接続する
  - design.md の処理フロー 1-8 が通ることを手動確認する
  - 既存 `src/git-*` に影響がないことを確認する
- [x] 4.2 基本的な動作テストを実装する
  - `test/test_installer_uninstaller.sh` を追加し、初回 install/no-op/`--update`/`--branch`/`--tag`/uninstall を検証する
  - プロファイル管理ブロックの追加・削除と冪等性を検証する
  - 主要エラー系（不正オプション、競合指定、存在しない ref）を検証する
- [x] 4.3 要件の受入基準を満たすことを確認する
  - requirements.md の要件1-6の受入基準に対する確認項目をテストにマッピングする
  - `README.md` / `README.ja.md` を同時更新し、手順差分がないことを確認する
  - 最終的に `bash test/run.sh` を実行して回帰がないことを確認する
