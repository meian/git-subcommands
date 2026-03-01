# 技術設計書

## アーキテクチャ概要
本specは、既存の Git サブコマンド実装（`src/git-*` と `lib/common.sh`）には手を入れず、リポジトリルートのドキュメント層に変更を統合する。
具体的には、`README.md`（英語）と `README.ja.md`（日本語）を並行保守する構成を採用し、プロジェクトレベルの運用ルールを `AGENTS.md` に明文化する。
これにより、技術スタック（Git CLI + Bash）やコマンド実行フローへ影響を与えず、利用者向け情報提供と保守手順のみを拡張する。

## 主要コンポーネント
### コンポーネント1：English README (`README.md`)
- 責務：プロジェクトの一次ドキュメントとして、機能概要・セットアップ・利用方法を英語で提供する。
- 入力：既存のプロジェクト機能情報、コマンド仕様、更新内容。
- 出力：英語で記述された利用者向け説明、および `README.ja.md` へのリンク。
- 依存関係：`README.ja.md`（相互リンク）、`src/git-*` の実際のコマンド仕様。

### コンポーネント2：Japanese README (`README.ja.md`)
- 責務：`README.md` と同等情報を日本語で提供する。
- 入力：`README.md` の内容、既存コマンド仕様、翻訳方針（識別子は原文維持）。
- 出力：日本語で記述された利用者向け説明、および `README.md` へのリンク。
- 依存関係：`README.md`（同期元）、`src/git-*` の実際のコマンド仕様。

### コンポーネント3：README同期運用ルール (`AGENTS.md`)
- 責務：Codex 作業時のルールとして、英語版・日本語版 README の同期更新を強制する。
- 入力：ドキュメント運用方針、保守時の注意点。
- 出力：README 同期更新ルールの明文化。
- 依存関係：`README.md`、`README.ja.md`。

## データモデル
### ReadmeSectionMap
- `section_key`: string、セクション識別子（例: `overview`, `subcommands`, `requirements`, `setup`, `test`）。
- `readme_en_anchor`: string、`README.md` 上の対応セクション名または位置。
- `readme_ja_anchor`: string、`README.ja.md` 上の対応セクション名または位置。
- `sync_required`: boolean、同期必須セクションかどうか。

### DocumentationLink
- `source_file`: string、リンク元ファイルパス。
- `target_file`: string、リンク先ファイルパス。
- `label`: string、表示ラベル（例: `日本語版`, `English version`）。

### MaintenanceRule
- `rule_id`: string、運用ルール識別子。
- `description`: string、ルール本文。
- `applies_to`: string[]、対象ファイル一覧（`README.md`, `README.ja.md`）。

## 処理フロー
1. `README.md` の既存セクション構造を基準として、対応する日本語セクションを `README.ja.md` に定義する。
2. `README.md` に `README.ja.md` へのリンク、`README.ja.md` に `README.md` へのリンクを追加する。
3. `AGENTS.md` に「片方更新時はもう片方も更新する」運用ルールを記載する。
4. 差分確認時に、主要セクション対応と相互リンクの存在を確認し、要件の受入基準に照合する。

## エラーハンドリング
- エラーケース1：`README.ja.md` に対応セクションが不足する。
  - 対処法：`README.md` の主要セクション一覧に基づき不足セクションを追加し、内容差分を解消する。
- エラーケース2：相互リンクの片側が欠落する。
  - 対処法：両READMEの先頭付近にリンクを再配置し、リンク切れがないか確認する。
- エラーケース3：README同期ルールが未記載または曖昧。
  - 対処法：`AGENTS.md` に対象ファイル名を明示した同期更新ルールを追加する。

## 既存コードとの統合
- 変更が必要なファイル：
  - `README.md`：日本語版 README への導線追加、記載内容の同期元として維持。
- 新規作成ファイル：
  - `README.ja.md`：英語版と同等内容の日本語ドキュメント。
  - `AGENTS.md`：README 同期運用ルールを保持するプロジェクトレベルプロンプト。
