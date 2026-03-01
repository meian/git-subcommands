# Summary: installer-uninstaller

## 実施内容
- `install.sh` / `uninstall.sh` / README / テストの整合を確認し、要件1-5を満たす実装として確定。
- `install.sh` の公開オプションを `--update` / `--tag` に限定し、`--repo` は非対応化（テストでは `GIT_SUBCOMMANDS_REPO_URL` を利用）。
- `tasks.md` の全タスクを完了（[x]）に更新。

## RED -> GREEN -> REFACTOR
- RED:
  - `test/test_installer_uninstaller.sh` に「`--repo` は未知引数として失敗すること」を追加し、失敗を確認。
- GREEN:
  - `install.sh` から `--repo` 引数処理を削除し、テスト成功。
- REFACTOR:
  - usage 表示を実装仕様に合わせて簡素化し、公開インターフェースを明確化。

## 検証結果
- `bash test/test_installer_uninstaller.sh` : PASS
- `bash test/run.sh` : All tests passed
## 変更ファイル（主要）
- `install.sh`
- `test/test_installer_uninstaller.sh`
- `.sdd/specs/installer-uninstaller/tasks.md`
- `.sdd/specs/installer-uninstaller/highway-summary.md`

## 補足
- `/sdd-archive` の専用コマンド実体がローカルにないため、同等処理として `highway-summary.md` 更新と `archives/` への同期を実施。
