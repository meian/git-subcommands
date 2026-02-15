# Technology Stack

## アーキテクチャ
Git の外部サブコマンド機構（`git-<name>` という実行可能ファイルを `PATH` 上に配置）を利用する CLI ツール群です。
各サブコマンドは Bash スクリプトとして実装し、共通処理は `lib/common.sh` に集約します。
今後の配置方針として、ユーザー公開スクリプトは `src/` 配下に配置するルールを採用します。

## 使用技術
### 言語とフレームワーク
- Git CLI：サブコマンド実行基盤
- Bash：`git-latest` / `git-local-branch` / `git-merged` / `git-last` の実装言語

### 依存関係
- `git`：必須（サブコマンド実行対象）
- `fzf`：一部機能（`git local-branch`）で必須

## 開発環境
### 必要なツール
- Git
- fzf（対象機能を利用する場合）

### よく使うコマンド
- ステアリング作成：`/sdd-steering`
- 要件定義：`/sdd-requirements`
- 設計：`/sdd-design`
- タスク分解：`/sdd-tasks`
- 実装：`/sdd-implement`
- テスト：`bash test/run.sh`
- 実行権限付与：`chmod +x git-latest git-local-branch git-merged git-last`

## 環境変数
- 現時点で明示された必須環境変数はありません。
