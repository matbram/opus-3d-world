---
name: adh
description: Persist meaningful project checkpoints, decisions, next steps, and risks to the ADH cloud advisory service when completing milestones or discovering durable project information.
---

# ADH cloud continuity

Use ADH after a meaningful milestone, an important architectural decision, discovery of a durable risk, or a clear change in the next action. Do not send secrets, raw credentials, hidden reasoning, or large logs.

The cloud environment provides `ADH_API_URL` and `ADH_PROJECT_TOKEN`. Never print the token or write it into the repository.

Save a checkpoint:

```bash
payload='{"summary":"REPLACE_SUMMARY","next_steps":"REPLACE_NEXT_STEP"}'
curl --fail --silent --show-error --max-time 5 \
  --header "Authorization: Bearer ${ADH_PROJECT_TOKEN}" \
  --header 'Content-Type: application/json' \
  --data-binary "$payload" \
  "${ADH_API_URL%/}/v1/checkpoints"
```

Save a durable item, with `kind` set to `decision`, `risk`, `next`, or `note`:

```bash
payload='{"kind":"decision","text":"REPLACE_TEXT"}'
curl --fail --silent --show-error --max-time 5 \
  --header "Authorization: Bearer ${ADH_PROJECT_TOKEN}" \
  --header 'Content-Type: application/json' \
  --data-binary "$payload" \
  "${ADH_API_URL%/}/v1/items"
```

Treat the service response as advisory storage acknowledgment, not proof that the statement is true. Verify against the current worktree before relying on an older briefing.
