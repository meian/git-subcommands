# README Sync Checklist

## ReadmeSectionMap
- `overview`: `README.md` の導入文 ↔ `README.ja.md` の導入文
- `subcommands`: `## Subcommands` ↔ `## サブコマンド`
- `requirements`: `## Requirements` ↔ `## 必要要件`
- `setup`: `## Setup` ↔ `## セットアップ`
- `test`: `## Test` ↔ `## テスト`

## DocumentationLink
- `README.md` -> `README.ja.md`
  - label: `日本語版`
  - location: タイトル直下の導入文の次
- `README.ja.md` -> `README.md`
  - label: `English version`
  - location: タイトル直下の導入文の次

## MaintenanceRule
- `rule_id`: `readme-sync-update`
- `description`: `README.md` または `README.ja.md` のどちらかを変更した場合、もう片方も同時に更新して内容差分を残さない。
- `applies_to`: `README.md`, `README.ja.md`

## Validation Points
- 主要セクション（overview/subcommands/requirements/setup/test）が両READMEで対応していること。
- 相互リンクが片側欠落なく存在すること。
- `AGENTS.md` に README 同期更新ルールが明記されていること。
