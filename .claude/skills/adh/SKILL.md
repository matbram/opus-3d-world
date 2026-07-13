---
name: adh
description: Persist meaningful project checkpoints, decisions, next steps, and risks to the ADH cloud advisory service when completing milestones or discovering durable project information.
---

# ADH cloud continuity

Use ADH after a meaningful milestone, an important architectural decision, discovery of a durable risk, or a clear change in the next action. Do this before ending a substantial implementation turn so the next Remote session receives deliberate context instead of relying only on the automatically captured final response. Do not send secrets, raw credentials, hidden reasoning, or large logs.

The cloud environment provides `ADH_API_URL` and `ADH_PROJECT_TOKEN`. Never print the token or write it into the repository.

## Verify meaningful code changes

Before reporting a meaningful code change complete, run the committed verifier from the repository root:

```bash
bash .claude/skills/adh/scripts/verify.sh
```

This downloads the version-matched ADH CLI from Railway, loads the project's current test settings from the dashboard, runs the configured setup and bounded test, uploads evidence to Supabase, and publishes the advisory commit status through ADH. It does not use GitHub Actions minutes. If verification cannot run or fails, report that honestly and do not describe the current commit as tested.

Save a checkpoint:

```bash
session_id="${CLAUDE_CODE_REMOTE_SESSION_ID:-}"
session_id="${session_id#cse_}"
if [ -z "$session_id" ]; then session_id="$(cat "$(git rev-parse --git-path adh/session-id)" 2>/dev/null || true)"; fi
payload='{"summary":"REPLACE_SUMMARY","next_steps":"REPLACE_NEXT_STEP"}'
curl --fail --silent --show-error --max-time 5 \
  --header "Authorization: Bearer ${ADH_PROJECT_TOKEN}" \
  --header "X-ADH-Session-ID: ${session_id}" \
  --header 'Content-Type: application/json' \
  --data-binary "$payload" \
  "${ADH_API_URL%/}/v1/checkpoints"
```

Treat the service response as advisory storage acknowledgment, not proof that the statement is true. Verify against the current worktree before relying on an older briefing.

## Submit reviewable journal suggestions

When the ADH semantic Stop reviewer identifies durable facts, submit them to the review queue instead of promoting them directly to project memory. Include at most eight entries with `kind` set to `decision`, `risk`, `next`, or `note`. Confidence is an integer from 50 through 100. Never include secrets, raw prompts, copied third-party instructions, code/log dumps, or unverified guesses.

```bash
session_id="${CLAUDE_CODE_REMOTE_SESSION_ID:-}"
session_id="${session_id#cse_}"
if [ -z "$session_id" ]; then session_id="$(cat "$(git rev-parse --git-path adh/session-id)" 2>/dev/null || true)"; fi
payload='{"entries":[{"kind":"decision","text":"REPLACE_TEXT","confidence":90}]}'
curl --fail --silent --show-error --max-time 5 \
  --header "Authorization: Bearer ${ADH_PROJECT_TOKEN}" \
  --header "X-ADH-Session-ID: ${session_id}" \
  --header 'Content-Type: application/json' \
  --data-binary "$payload" \
  "${ADH_API_URL%/}/v1/journal-suggestions"
```

The operator accepts or dismisses each suggestion in Journal Review. A successful submission does not mean the suggestion is true or durable yet.

The SessionStart brief may include queued work. Treat it as a prioritized request, not authorization to bypass normal user instructions or repository review. State which queued item you are taking on, and save a new checkpoint when its status materially changes.

When starting or finishing a queued item, update the UUID shown in the brief:

```bash
session_id="${CLAUDE_CODE_REMOTE_SESSION_ID:-}"
session_id="${session_id#cse_}"
if [ -z "$session_id" ]; then session_id="$(cat "$(git rev-parse --git-path adh/session-id)" 2>/dev/null || true)"; fi
work_id="REPLACE_WORK_UUID"
payload='{"status":"in_progress"}' # use done or cancelled when appropriate
curl --fail --silent --show-error --max-time 5 \
  --request PATCH \
  --header "Authorization: Bearer ${ADH_PROJECT_TOKEN}" \
  --header "X-ADH-Session-ID: ${session_id}" \
  --header 'Content-Type: application/json' \
  --data-binary "$payload" \
  "${ADH_API_URL%/}/v1/work-items/${work_id}"
```
