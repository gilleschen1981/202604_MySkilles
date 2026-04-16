---
name: debug-local
description: >
  Deploy modified microservices to D2 via dscore skaffold and optionally run
  Flutter frontend locally. Dynamically detects changed services from git diff.
  Use when the user wants to test branch changes end-to-end on D2.
---

# Debug Local Workflow

Deploy changed microservices to D2 and optionally run the Flutter frontend locally for end-to-end testing.

## Modes

The user may request one of two modes:

1. **backend-only** — deploy modified microservices only (no Flutter)
2. **full** (default) — deploy microservices + run Flutter frontend locally

Ask the user which mode if not specified.

## Defaults

| Parameter | Value |
|-----------|-------|
| Alias | `gilles` |
| Env | D2 |
| Cluster context | `lightning-d2` |
| Namespace | `core` (override per service if needed, e.g. `waop` for waop-* services) |

## Step 1 — Detect changed services and frontend

This branch typically merges `origin/main` periodically, so a plain `git diff main` includes
hundreds of unrelated PR changes. To find **only the changes made on this branch**, filter out
commits whose message starts with "Pull request" or "Auto-Merge" (these are merged PRs from main).

### Detect changed services

```bash
for c in $(git log --format=%H HEAD --not origin/main --no-merges); do
  msg=$(git log --format=%s -1 "$c")
  echo "$msg" | grep -qE "^(Pull request|Auto-Merge)" && continue
  git diff-tree --no-commit-id --name-only -r "$c" 2>/dev/null
done | grep "^services/" | cut -d/ -f2 | sort -u
```

### Detect frontend changes

```bash
for c in $(git log --format=%H HEAD --not origin/main --no-merges); do
  msg=$(git log --format=%s -1 "$c")
  echo "$msg" | grep -qE "^(Pull request|Auto-Merge)" && continue
  git diff-tree --no-commit-id --name-only -r "$c" 2>/dev/null
done | grep "^apps/lightning/" | sort -u
```

### Mode selection

- If services are changed → deploy them (Step 2)
- If `apps/lightning/` is changed → run Flutter locally (Step 3)
- If both → **full** mode (deploy services + run Flutter)
- If user explicitly requests **backend-only**, skip Step 3 even if frontend has changes

Present the detected services and frontend change status to the user and ask for confirmation
before proceeding. The user may choose to deploy all or a subset of services.

If no services are changed, skip to Step 3 (frontend only) or inform the user there is nothing to deploy.

## Step 2 — Deploy microservices with dscore skaffold

For each confirmed service, deploy using the **deploy-once pattern**:

```bash
ALIAS=gilles
CONTEXT=lightning-d2
NAMESPACE=core   # adjust per service if needed

dscore skaffold <service-name> -n $NAMESPACE -a $ALIAS -c $CONTEXT &

# Wait for pod to be ready (2/2 Running)
while ! kubectl get pods -n $NAMESPACE -l app=<service-name>-$ALIAS \
  --context $CONTEXT 2>/dev/null \
  | grep -q "2/2.*Running"; do sleep 2; done

# SIGKILL to keep deployment alive (SIGTERM would delete it)
pkill -9 -f "skaffold dev"
pkill -9 -f "dscore skaffold"

# Verify
kubectl get pods -n $NAMESPACE -l app=<service-name>-$ALIAS --context $CONTEXT

# Re-apply VirtualService patch (dscore skaffold unpatches on exit, even SIGKILL)
# Only needed for gateway services that have VirtualService routing
# IMPORTANT: --field-manager prevents ArgoCD from reverting the patch
export SERVICE_NAME=<service-name> TARGET=<service-name> ALIAS=$ALIAS
kubectl patch virtualservice -n $NAMESPACE "${SERVICE_NAME}-exp" \
  --context $CONTEXT --type=json \
  --field-manager "remoteenv-controller" \
  -p "$(envsubst < skaffold-remotedev/patch-gateway.json)"
```

Deploy services **sequentially** (each dscore skaffold build uses significant resources).

### Namespace hints

Determine the namespace from the service's kustomization or existing deployment:

```bash
# Check the service's k8s overlay for namespace
cat services/<service-name>/k8s/overlays/d2/kustomization.yaml | grep namespace
```

Common mappings:
- `waop-*` services → namespace `waop`
- Most other services → namespace `core`

### Cleanup (remind the user)

```bash
kubectl delete deploy/<service-name>-gilles -n <namespace> \
  --context lightning-d2
```

## Step 3 — Run Flutter frontend locally (full mode only)

Skip this step if mode is **backend-only**.

```bash
cd apps/lightning

# 1. Set environment to D2
./utils/set_environment.sh d2

# 2. Generate gRPC code
make generate

# 3. Run on port 8080
flutter run -d chrome --web-port 8080
```

### Route traffic to remotedev pods

Set the remotedev cookie so the local frontend hits the skaffolded services:

```javascript
// Run in browser console on the app page
document.cookie = "remotedev=gilles; SameSite=None; path=/; max-age=6000; secure"
```

## Troubleshooting

- **Pod not receiving traffic:** verify `remotedev=gilles` cookie/header is set
- **Flutter port conflict:** ensure port 8080 is free (`lsof -i :8080`)
- **Skaffold rebuild loop:** make sure no auto-generated files trigger file watchers
- **Container exit 137:** OOM or eviction — retry the deployment
- **Port-forward drops:** use auto-reconnect loop if needed:
  ```bash
  while true; do
    kubectl port-forward -n <ns> deploy/<service>-gilles <local>:<remote> \
      --context lightning-d2 2>&1
    echo "Reconnecting..."; sleep 1
  done &
  ```
