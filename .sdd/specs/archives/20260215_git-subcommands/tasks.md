# 実装タスクリスト

## セクション1：データモデル実装
- [x] 1.1 必要な型定義・データ構造を作成する
  - design.md で定義された `CommandContext` / `LatestOptions` / `LocalBranchOptions` / `MergedOptions` / `LastOptions` / `CommandResult` を実装
  - `git last -n` の正の整数チェック、`-clean` オプション判定などのバリデーションルールを実装
- [x] 1.2 データ永続化層を実装する
  - 本specの永続化対象は Git 状態のため、Gitコマンド実行ラッパーを共通化
  - ブランチ一覧取得・マージ済み判定・差分取得の読み取り/更新操作を実装

## セクション2：ビジネスロジック実装
- [x] 2.1 Command Entrypoints のコア処理を実装する
  - design.md の処理フロー1-3（起動、依存確認、引数検証）に対応
  - `git-latest` / `git-local-branch` / `git-merged` / `git-last` の入口処理を実装
- [x] 2.2 Core Git Operations の処理を実装する
  - design.md の処理フロー4-5（Git実行、結果出力）に対応
  - 要件1-4（latest/local-branch/merged/last）の正常系処理を実装
- [x] 2.3 エラーハンドリングを実装する
  - design.md で定義されたエラーケース（依存欠落、不正引数、Git実行失敗、fzfキャンセル）を実装
  - `Error Formatter` による統一メッセージと終了コードを実装

## セクション3：インターフェース実装
- [x] 3.1 CLIインターフェース（gitサブコマンド実行ファイル）を作成する
  - `git-latest` / `git-local-branch` / `git-merged` / `git-last` を実行可能ファイルとして作成
  - `PATH` 経由で `git <subcommand>` として解決されることを確認
- [x] 3.2 入力バリデーションを実装する
  - `branch` 必須性、`branch-pattern` 任意入力、`-clean` オプション、`-n` 引数形式を検証
  - 不正入力時に使用例を表示して終了する
- [x] 3.3 出力フォーマットを実装する
  - 一覧表示（merged / local-branch 候補）と差分表示（last）の出力整形を実装
  - 正常系は標準出力、エラー系は標準エラーへ統一

## セクション4：統合とテスト
- [x] 4.1 コンポーネントを統合する
  - Entrypoints、共通ライブラリ、Git操作層、エラー整形層を接続
  - `git switch -` で戻れることを含む `latest` のデータフローを確認
- [x] 4.2 基本的な動作テストを実装する
  - ユニットテスト：引数解析、依存確認、エラー整形
  - 統合テスト：各サブコマンドの Git 操作（正常系・異常系）
- [x] 4.3 要件の受入基準を満たすことを確認する
  - requirements.md の受入基準チェックリストを実行結果で検証
  - README の利用方法と依存条件（`fzf` 必須）を最終確認

## 実装メモ
- RED/GREEN/REFACTOR の実施方針に沿って、結合テスト群（`test/test_*.sh`）と共通処理（`lib/common.sh`）を整備済み。
- `bash test/run.sh` で全テスト成功を確認。
- `bash -n` によるシェル構文チェック成功。
- 未解決タスクはなし。
