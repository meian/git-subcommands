# 実装タスクリスト

## セクション1：データモデル実装
- [x] 1.1 必要な型定義・データ構造を作成する
  - design.md で定義された `CommandContext` / `LatestOptions` / `LocalBranchOptions` / `MergedOptions` / `LastOptions` を Bash 実装へ落とし込む
  - `-n` 正の整数判定、`-clean` 判定、依存コマンド検証などのバリデーションルールを実装
- [x] 1.2 データ永続化層を実装する
  - 本specの永続化対象は Git 状態のため、Git 実行ラッパーを共通化
  - ブランチ一覧取得・マージ済み判定・差分取得・ブランチ削除の CRUD 操作を実装

## セクション2：ビジネスロジック実装
- [x] 2.1 Public Command Scripts（コンポーネント1）のコア処理を実装する
  - design.md の処理フロー1-3（起動、依存確認、引数検証）に対応
  - `src/git-latest` / `src/git-local-branch` / `src/git-merged` / `src/git-last` の入口処理を実装
- [x] 2.2 Common Library（コンポーネント2）の処理を実装する
  - design.md の処理フロー4-5（Git実行、結果出力）に対応
  - 4サブコマンドの正常系処理と共通関数を `lib/common.sh` に集約
- [x] 2.3 エラーハンドリングを実装する
  - design.md のエラーケース（依存欠落、不正引数、Git失敗、選択キャンセル）を実装
  - 標準エラー出力と終了コードを統一

## セクション3：インターフェース実装
- [x] 3.1 UIコンポーネント/APIエンドポイントの代替として CLI エントリーポイントを作成する
  - 公開スクリプトを `src/` 配下へ配置し、`git-***` 命名規則を維持
  - `PATH` を `src/` に向けた際に `git <subcommand>` として解決されることを確認
- [x] 3.2 入力バリデーションを実装する
  - `latest` の branch 必須、`local-branch` の pattern 任意、`merged` の `-clean`、`last` の `-n` を検証
  - 不正入力時に Usage を表示して終了
- [x] 3.3 出力フォーマットを実装する
  - ブランチ一覧・差分表示・削除結果などの標準出力形式を統一
  - エラー出力を標準エラーへ分離

## セクション4：統合とテスト
- [x] 4.1 コンポーネントを統合する
  - `src/git-*` と `lib/common.sh` の接続を確認
  - 既存テストが `src/` 配置前提で実行できることを確認
- [x] 4.2 基本的な動作テストを実装する
  - 既存統合テスト（`test/test_git_*.sh`）を `src/` 実行パスへ更新
  - 配置要件テスト `test/test_src_layout.sh` を追加し、存在と実行可能属性を検証
- [x] 4.3 要件の受入基準を満たすことを確認する
  - `bash test/run.sh` で全テスト成功を確認
  - `README.md` の `src/` 前提セットアップ手順と要件1-5の整合を最終確認

## 実装メモ
- テスト先行で `src/` 配置要件の検証（`test/test_src_layout.sh`）を追加し、失敗を確認後に `src/git-*` へ移設して解消。
- `bash test/run.sh` 成功（全テスト通過）。
- `bash -n` によるシェル構文チェック成功。
- 未解決タスクなし。
