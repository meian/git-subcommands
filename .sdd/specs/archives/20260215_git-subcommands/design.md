# 技術設計書

## アーキテクチャ概要
本機能は Git の外部サブコマンド機構（`git-<name>` 実行ファイル）へ統合する。
各機能は `git-latest`、`git-local-branch`、`git-merged`、`git-last` の個別コマンドとして実装し、共通処理（引数検証、依存確認、エラー出力）を共有ライブラリへ集約する。
`git local-branch` のみ `fzf` 依存を持ち、起動時に依存確認して未導入時は明示的に失敗させる。

## 主要コンポーネント
### コンポーネント1：Command Entrypoints
- 責務：`git-<name>` として呼び出される各サブコマンドの入口処理を行う
- 入力：CLI引数（例：`branch`、`branch-pattern`、`-clean`、`-n`）
- 出力：標準出力への結果表示、標準エラーへの失敗理由、終了コード
- 依存関係：`Core Git Operations`、`Dependency Checker`、`Argument Parser`

### コンポーネント2：Core Git Operations
- 責務：Gitコマンド実行（ブランチ切替、更新、一覧取得、削除、差分取得）を担当する
- 入力：正規化済みパラメータ（ブランチ名、検索パターン、オプション）
- 出力：コマンド実行結果（文字列リスト、成功/失敗）
- 依存関係：`Error Formatter`、システムの `git` コマンド

### コンポーネント3：Dependency Checker
- 責務：必要コマンド（`git` と必要時の `fzf`）の存在確認を行う
- 入力：実行サブコマンド名
- 出力：依存充足可否、欠落依存名
- 依存関係：システムの `PATH`

### コンポーネント4：Argument Parser
- 責務：各サブコマンド引数を解釈し、妥当性を検証する
- 入力：生の CLI 引数配列
- 出力：検証済みオプション構造体
- 依存関係：`Error Formatter`

### コンポーネント5：Error Formatter
- 責務：利用者向けの一貫したエラーメッセージを生成する
- 入力：エラー種別（依存欠落、不正引数、Git実行失敗）
- 出力：標準エラーへ出力するメッセージ文字列、終了コード
- 依存関係：なし

## データモデル
### CommandContext
- `name`：string、サブコマンド名（`latest` / `local-branch` / `merged` / `last`）
- `args`：string[]、受け取った引数
- `cwd`：string、実行時カレントディレクトリ

### LatestOptions
- `branch`：string、更新対象ブランチ名

### LocalBranchOptions
- `pattern`：string | null、ブランチ絞り込み条件

### MergedOptions
- `clean`：boolean、削除実行有無

### LastOptions
- `offset`：number、対象コミット位置（`git last` は 0、`git last -n` は n）

### CommandResult
- `stdout`：string、通常出力内容
- `stderr`：string、エラー出力内容
- `exitCode`：number、プロセス終了コード

## 処理フロー
1. `git-<name>` 実行時に `Command Entrypoints` が起動し、コマンド名と引数を受け取る。
2. `Dependency Checker` が `git` を確認し、`local-branch` の場合のみ `fzf` も確認する。
3. `Argument Parser` が引数を検証し、機能別オプションへ変換する（`-n` は正の整数のみ許可）。
4. `Core Git Operations` が要件に対応する Git 操作を実行する。
5. 実行結果を標準出力へ表示する。失敗時は `Error Formatter` で整形したメッセージを標準エラーへ表示して非0で終了する。

## エラーハンドリング
- エラーケース1：`git` または `fzf` が未導入
  - 対処法：不足コマンド名を表示し、導入が必要であることを案内して終了する。
- エラーケース2：引数形式不正（`git last -n` の n が未指定/非数/0以下）
  - 対処法：正しい使用例を表示して終了する。
- エラーケース3：対象ブランチ不存在、削除不能など Git 実行失敗
  - 対処法：Git の失敗内容を併記し、処理を中断して終了する。
- エラーケース4：`local-branch` で候補が0件、または `fzf` 選択キャンセル
  - 対処法：何も変更せず終了し、候補なし/キャンセルを明示する。

## 既存コードとの統合
- 変更が必要なファイル：
  - `README.md`：提供サブコマンド一覧、使用方法、`fzf` 必須条件を維持・更新する。
  - `lib/common.sh`：共通処理（引数処理・依存確認・エラー整形・Git補助関数）の保守対象。
  - `test/test_*.sh`：受入基準に対応する結合テストの保守対象。
- 新規作成ファイル：
  - なし（`git-latest`、`git-local-branch`、`git-merged`、`git-last`、`lib/common.sh`、`test/` 配下テストは作成済み）。
