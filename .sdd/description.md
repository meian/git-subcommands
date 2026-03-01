# 機能概要
READMEの日本語バージョン

## 背景
GitHub Issue #2
https://api.github.com/repos/meian/git-subcommands/issues/2

## 要求内容（Issue原文）
- READMEと同じ内容を日本語で記述したファイルを README.ja.md として作成する
- 相互のファイルにリンクを貼る
- プロジェクトレベルのcodex用のプロンプトファイルに、片方のファイルを修正する場合はそれに合わせてもう片方のファイルを更新する旨を明記する

## スコープ
- In Scope: Issue本文と追加回答で合意した範囲
- Out of Scope: 明示的に合意していない拡張

## 受け入れ観点（初版）
- [ ] 主要要件を満たす
- [ ] 既存機能への影響を説明できる
- [ ] requirements で検証可能な条件に落とし込める

## 追加指示（Codex公式仕様）
- プロジェクトレベルの `AGENTS.md` はリポジトリルート（通常は Git ルート）に配置する。
- Codex はプロジェクトルートから現在の作業ディレクトリまで探索し、各階層で `AGENTS.override.md` を優先し、次に `AGENTS.md` を読む。
