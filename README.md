# MySkills

Personal Claude Code skills collection.

## Skills

| Skill | Trigger | Description |
|-------|---------|-------------|
| [git-health](skills/git-health/SKILL.md) | `/git-health` | Analyze git repo health: hot files, contributors, bug hotspots, activity trends |

## Usage

### Option 1: Symlink (recommended)

Link skills to your project's `.claude/skills/` directory:

```bash
# Link a single skill
ln -s ~/Desktop/_SourceCode/MySkills/skills/git-health .claude/skills/git-health

# Or link all skills at once
for skill in ~/Desktop/_SourceCode/MySkills/skills/*/; do
  ln -s "$skill" .claude/skills/$(basename "$skill")
done
```

### Option 2: Install script

```bash
~/Desktop/_SourceCode/MySkills/install.sh /path/to/your/project
```

## Adding to CLAUDE.md

After linking, register the skill in your project's `.claude/CLAUDE.md`:

```markdown
## git-health
- **git-health** (`.claude/skills/git-health/SKILL.md`) - analyze git repo health
When the user types `/git-health`, invoke the Skill tool with `skill: "git-health"`.
```
