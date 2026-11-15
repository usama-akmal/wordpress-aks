# Incident triage helper

The helper ranks likely causes for WordPress lab incidents, cites an observation for each hypothesis, and prints three read-only checks for an operator. It uses a fixed catalog of causes and commands. The model ranks and selects entries, and the script renders the matching commands for review.

## Run locally

Start Ollama and download the model. From the repo root:

    ollama pull qwen2.5:1.5b-instruct
    python3 scripts/triage-incident.py docs/ai/incidents.json --case gateway-dimension

## Evaluate all five cases

    mkdir -p evidence/ai
    python3 scripts/triage-incident.py docs/ai/incidents.json \
      --evaluate --output evidence/ai/triage-evaluation.md

Each case reconstructs a resolved incident from the lab. The expected cause and first check are available only to the evaluator. The report measures top-one accuracy, top-three accuracy, expected first-check agreement, and model request time. A different valid first check can still be useful, so review mismatches and the cited observations before interpreting the scores.

For a manual comparison, time yourself or a reviewer identifying a likely cause and first check using only each case's incident data. Record elapsed time, the proposed cause, and the first check before viewing the AI output or expected answers. Record whether the reviewer already knows the project. Keep human review time separate from model request time.
