---
name: git-health
description: Analyze git repository health - hot files, contributors, bug hotspots, activity trends, and emergency fixes
trigger: /git-health
---

# /git-health

Analyze a git repository's health using key metrics from commit history. Based on the article "Git commands before reading code" by piechowski.io.

## Usage

```
/git-health              # Run all analyses
/git-health hotfiles     # Only show high-frequency changed files
/git-health services     # Only show changes by microservice
/git-health contributors # Only show contributor ranking
/git-health bugs         # Only show bug fix hotspots
/git-health activity     # Only show monthly commit activity
/git-health emergency    # Only show reverts/hotfixes/rollbacks
```

## What You Must Do When Invoked

Run the requested analysis (or all if no subcommand given). Use these adjusted commands that filter out noise like i18n/generated files.

### 1. High-Frequency Changed Files (hotfiles)

Find source files changed most frequently, excluding generated code:

```bash
git log --format=format: --name-only --since="1 year ago" \
  | grep -v "l10n\|generated\|\.lock\|\.g\.dart\|\.pb\.go\|\.pbjson\|\.pbgrpc" \
  | grep -E "\.(go|dart|ts|py|proto|js|tsx|jsx)$" \
  | sort | uniq -c | sort -nr | head -30
```

**Interpretation guide:**
| Changes/Year | Meaning |
|-------------|---------|
| 200+ | Very high - possible god file, may need splitting |
| 100-200 | High - active development area |
| 50-100 | Medium - normal maintenance |
| <50 | Low - stable code |

For top files, also show line counts:
```bash
wc -l <top-3-files>
```

A 5000+ line file with 200+ annual changes is a strong signal for refactoring.

### 2. Changes by Microservice (services)

Aggregate changes by service directory:

```bash
git log --format=format: --name-only --since="1 year ago" \
  | grep -v "l10n\|generated\|\.lock\|\.g\.dart\|\.pb\.go\|\.pbjson\|\.pbgrpc" \
  | grep -E "^services/[^/]+/" \
  | sed 's|^services/\([^/]*\)/.*|\1|' \
  | sort | uniq -c | sort -nr | head -20
```

Present as a ranked table showing which microservices see the most development activity.

### 3. Contributor Ranking (contributors)

List contributors by commit count:

```bash
git log --format='%aN' --since="1 year ago" | sort | uniq -c | sort -nr | head -40
```

Also calculate:
```bash
# Total contributors
git log --format='%aN' --since="1 year ago" | sort -u | wc -l

# Internal vs External split (if naming convention exists)
git log --format='%aN' --since="1 year ago" | sort | uniq -c | sort -nr \
  | awk '{if ($0 ~ /External/) ext+=$1; else internal+=$1} END {print "External:", ext, "Internal:", internal}'
```

**Bus factor assessment:**
- If top 3 contributors > 30% of commits: HIGH risk
- If top 3 contributors 15-30%: MEDIUM risk  
- If top 3 contributors < 15%: LOW risk

### 4. Bug Fix Hotspots (bugs)

Find files with most bug-related commits, excluding generated files:

```bash
git log -i -E --grep="fix|bug|broken" --name-only --format='' --since="1 year ago" \
  | grep -v "l10n\|generated\|\.lock\|\.g\.dart\|\.pb\.go" \
  | grep -E "\.(go|dart|ts|py)$" \
  | sort | uniq -c | sort -nr | head -20
```

Cross-reference with hotfiles - files appearing in BOTH lists are high-risk candidates for technical debt.

### 5. Monthly Activity (activity)

Show commit activity trends:

```bash
git log --format='%ad' --date=format:'%Y-%m' --since="2 years ago" | sort | uniq -c
```

**Interpretation:**
- Steady or growing: healthy project
- Declining: possible maintenance mode or abandonment
- Spiky: release-driven development
- December dips: normal (holidays)

### 6. Emergency Fixes (emergency)

Find reverts, hotfixes, and rollbacks:

```bash
git log --oneline --since="1 year ago" | grep -iE 'revert|hotfix|emergency|rollback' | head -30
```

**Assessment:**
- 0-5/year: Normal operations
- 5-15/year: Some instability, worth investigating
- 15+/year: Possible "firefighting mode" - deeper issues

---

## Output Format

Present results as clean markdown tables. End with a summary section:

```
## Summary

| Metric | Value | Assessment |
|--------|-------|------------|
| Hottest file | X (N changes) | [OK/WARN] |
| Busiest service | Y (N changes) | - |
| Bus factor | Top 3 = X% | [LOW/MED/HIGH risk] |
| Bug hotspot | Z (N fixes) | [OK/WARN] |
| Monthly avg | N commits | [Active/Stable/Declining] |
| Emergency fixes | N/year | [OK/WARN] |
```

If any metric shows WARNING, provide a brief recommendation.
