# Advisory PR reviewer

Run this from the repo root with Ollama running and the qwen2.5:1.5b-instruct model installed.

    git fetch origin main
    python3 scripts/review-pr.py --base origin/main --head HEAD

This compares the branch with its merge base on main. The reviewer checks WordPress infrastructure, workload, RBAC, and pipeline diffs. It uses the first 160 parsed diff lines, including context. Review the full change when the report indicates truncation.

Each finding uses a known rule and cites an added or removed line. The report omits raw diff text. Share any verified observation in the GitHub PR yourself.

## Smoke-test the reviewer

    python3 scripts/review-pr.py --diff-file docs/ai/pr-fixtures/risky.diff
    python3 scripts/review-pr.py --diff-file docs/ai/pr-fixtures/clean.diff

The risky fixture contains two expected findings. It changes the deployment image to a mutable tag and points liveness at the MySQL-backed readiness endpoint. The clean fixture adjusts a memory limit. Record which issues were recognized and any additional claims. The result describes performance on these two known examples.
