# 技術設計書

## アーキテクチャ概要
本 spec は、既存の Bash ベース構成（`src/git-*` + `lib/common.sh`）に、配布用エントリとしてルート直下の `install.sh` と `uninstall.sh` を追加して統合する。
`install.sh` は GitHub 上の対象 ref（デフォルトブランチ / `--branch` / `--tag`）を取得し、`~/.local/share/git-subcommands` に配置する。対話モード初期化は `~/.git-subcommands.rc` で一元管理し、bash/zsh の対話設定ファイルへ管理ブロックを追加して読み込ませる。`~/.git-subcommands.rc` 内で `~/.local/share/git-subcommands/src` を PATH に追加する。
`uninstall.sh` は導入物と管理ブロックを冪等にクリーンアップし、既存サブコマンド実装（`src/git-*`）には直接変更を加えない。

## 主要コンポーネント
### コンポーネント1：Installer CLI (`install.sh`)
- 責務：初回導入、再実行時 no-op 判定、`--update` 更新、`--branch` / `--tag` による対象 ref 切替を実行する。
- 入力：CLI 引数（`--update`、`--branch <branch>`、`--tag <tag>`）、`$HOME`、リポジトリ URL。
- 出力：`~/.local/share/git-subcommands`、`~/.git-subcommands.rc`、シェル設定管理ブロック、完了メッセージ。
- 依存関係：`git`、Ref Resolver、Profile Manager。

### コンポーネント2：Ref Resolver
- 責務：引数の組み合わせから導入対象 ref を確定し、既存導入状態との差分を判定する。
- 入力：`InstallOptions`、記録済み導入 ref（例：`.install-ref`）。
- 出力：`resolved_ref`、`needs_reinstall`（再取得要否）。
- 依存関係：Installer CLI、Install State Store。

### コンポーネント3：Install State Store
- 責務：現在導入済み ref と導入モード（branch/tag/default）を保存・読み出しする。
- 入力：`resolved_ref`、導入モード、`install_root`。
- 出力：永続化された状態ファイル、現在状態。
- 依存関係：Installer CLI、Ref Resolver、Filesystem。

### コンポーネント4：Profile Manager
- 責務：`~/.git-subcommands.rc` の生成と、bash/zsh 対話モード設定ファイルへの管理ブロック追加/削除を行う。
- 入力：対象プロファイルパス、管理マーカー、`source ~/.git-subcommands.rc` 行。
- 出力：更新済み `~/.git-subcommands.rc` とプロファイルファイル。
- 依存関係：Installer CLI、Uninstaller CLI、テキスト処理（`awk` / `sed`）。

### コンポーネント5：Uninstaller CLI (`uninstall.sh`)
- 責務：`~/.local/share/git-subcommands` と `~/.git-subcommands.rc` の削除、bash/zsh 管理ブロックの除去を行う。
- 入力：`$HOME`、管理対象パス。
- 出力：削除済み状態、完了メッセージ。
- 依存関係：Profile Manager、Filesystem。

### コンポーネント6：Documentation Updater
- 責務：`README.md` と `README.ja.md` に install/update/uninstall 手順と bash/zsh 対応説明を同期反映する。
- 入力：CLI 使用例、対応シェル情報、設定変更の説明。
- 出力：同期済み README 2 ファイル。
- 依存関係：AGENTS.md の README 同期ルール。

## データモデル
### InstallOptions
- `update`：boolean、`--update` 指定有無。
- `branch`：string|null、`--branch` 指定値。
- `tag`：string|null、`--tag` 指定値。
- `repo_url`：string、取得元リポジトリ URL。

### ResolvedRef
- `mode`：enum(`default_branch` | `branch` | `tag`)、選択モード。
- `name`：string、解決後 ref 名（例：`main`、`feature/x`、`v1.2.3`）。
- `revision`：string、検証済みコミット識別子（取得時に確定）。

### InstallState
- `install_root`：path、`~/.local/share/git-subcommands`。
- `rc_file`：path、`~/.git-subcommands.rc`。
- `state_file`：path、導入状態記録ファイル（例：`.install-ref`）。
- `current_mode`：enum|null、現在導入モード。
- `current_ref_name`：string|null、現在 ref 名。
- `current_revision`：string|null、現在導入リビジョン。

### ManagedProfileBlock
- `profile_path`：path、対象プロファイル（bash/zsh）。
- `marker_begin`：string、管理開始マーカー。
- `marker_end`：string、管理終了マーカー。
- `source_line`：string、`~/.git-subcommands.rc` 読み込み行。

## 処理フロー
1. `install.sh` が引数を解析し、`InstallOptions` を確定する（`--branch` と `--tag` の競合はエラー）。
2. Ref Resolver が導入対象 ref を確定し、Install State Store から現在状態を取得する。
3. 再インストール要否を判定する。
4. 必要時のみ対象 ref を取得して `~/.local/share/git-subcommands` を更新し、state を保存する。
5. Profile Manager が `~/.git-subcommands.rc` を生成/更新し、`~/.local/share/git-subcommands/src` の PATH 追加を保証する。
6. Profile Manager が bash/zsh 対話設定へ管理ブロックを追加（重複防止）する。
7. 完了時に `source ~/.git-subcommands.rc` またはシェル再起動を案内する。
8. `uninstall.sh` 実行時は配置物と state を削除し、bash/zsh 管理ブロックを除去して冪等に終了する。

## エラーハンドリング
- エラーケース1：`git` が未導入。
- 対処法：前提チェックで即時終了し、必要コマンドを明示する。
- エラーケース2：`--branch` と `--tag` の同時指定。
- 対処法：引数エラーとして終了し、正しい使用方法を表示する。
- エラーケース3：指定 branch/tag が取得できない。
- 対処法：ref 解決/取得時に失敗として終了し、指定 ref 名を表示する。
- エラーケース4：設定ファイル編集時に書き込み失敗。
- 対処法：失敗ファイルを明示して終了し、既存内容は管理ブロック以外を保持する。
- エラーケース5：アンインストール対象が未存在。
- 対処法：スキップして成功扱いとし、冪等性を維持する。

## 既存コードとの統合
- 変更が必要なファイル：
  - `README.md`：install / update / uninstall 手順と bash/zsh 対応説明を追加。
  - `README.ja.md`：`README.md` と同等内容を日本語で同期。
- 新規作成ファイル：
  - `install.sh`：導入・更新・ref 切替・シェル設定反映を担当。
  - `uninstall.sh`：導入物削除・シェル設定クリーンアップを担当。
  - `test/test_installer_uninstaller.sh`：インストール/更新/削除の主要挙動を検証。
