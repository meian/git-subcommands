# 技術設計書

## アーキテクチャ概要
Git の外部サブコマンド機構（`git-<name>`）を利用する Bash ベースの CLI 構成を維持しつつ、公開スクリプト配置を `src/` 配下へ統一する。
共通処理は既存どおり `lib/common.sh` に集約し、`src/git-*` から参照する。
既存機能（`latest` / `local-branch` / `merged` / `last`）の振る舞いは維持し、配置変更による動作劣化をテストで防ぐ。

## 主要コンポーネント
### コンポーネント1：Public Command Scripts (`src/git-*`)
- 責務：各サブコマンドのエントリーポイントとして引数受け取り・共通処理呼び出し・結果出力を行う
- 入力：CLI 引数（`branch`、`branch-pattern`、`-clean`、`-n`）
- 出力：標準出力（結果）、標準エラー（エラー）、終了コード
- 依存関係：`lib/common.sh`、システムの `git`、（`local-branch` は `fzf`）

### コンポーネント2：Common Library (`lib/common.sh`)
- 責務：依存確認、引数バリデーション補助、Git 補助操作、エラー出力を提供
- 入力：コマンド名、引数値、実行コンテキスト
- 出力：正規化パラメータ、ブランチ一覧、マージ済み一覧、エラーメッセージ
- 依存関係：システムの `git`、POSIX/Bash 実行環境

### コンポーネント3：Test Suite (`test/test_*.sh`)
- 責務：受入基準（機能動作・依存エラー・配置要件）を検証
- 入力：テスト用一時 Git リポジトリ、実行対象スクリプトパス
- 出力：テスト成否（終了コード）、失敗時メッセージ
- 依存関係：`test/test_helpers.sh`、`src/git-*`、`git`

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

## 処理フロー
1. `src/git-*` が起動し、サブコマンド名と引数を受け取る。
2. `lib/common.sh` の共通関数で依存確認と引数検証を実施する。
3. サブコマンド別の Git 操作（更新・選択・一覧・削除・差分表示）を実行する。
4. 正常時は標準出力へ結果を出力し、異常時は標準エラーへメッセージを出力する。
5. テストスイートが `src/` 配置要件と機能要件の双方を検証する。

## エラーハンドリング
- エラーケース1：`git` または `fzf` 未導入
  - 対処法：不足コマンド名を明示して終了する。
- エラーケース2：引数不正（例：`git last -0`、未知オプション）
  - 対処法：Usage を表示し非0終了する。
- エラーケース3：Git 操作失敗（ブランチ不存在、削除失敗など）
  - 対処法：失敗内容を標準エラーに表示して処理中断する。
- エラーケース4：`local-branch` で候補なし/選択キャンセル
  - 対処法：状態を変更せず、理由を表示して終了する。

## 既存コードとの統合
- 変更が必要なファイル：
  - `README.md`：`src/` 配置前提のセットアップ・PATH 設定を記載する。
  - `test/test_git_latest.sh`：実行対象を `src/git-latest` へ更新。
  - `test/test_git_local_branch.sh`：実行対象を `src/git-local-branch` へ更新。
  - `test/test_git_merged.sh`：実行対象を `src/git-merged` へ更新。
  - `test/test_git_last.sh`：実行対象を `src/git-last` へ更新。
  - `.sdd/steering/structure.md`：構成の実態と配置方針を整合させる。
- 新規作成ファイル：
  - `src/git-latest`：`git latest` エントリーポイント（移設後）。
  - `src/git-local-branch`：`git local-branch` エントリーポイント（移設後）。
  - `src/git-merged`：`git merged` エントリーポイント（移設後）。
  - `src/git-last`：`git last` エントリーポイント（移設後）。
  - `test/test_src_layout.sh`：`src/` 配下配置と実行可能属性の検証。
