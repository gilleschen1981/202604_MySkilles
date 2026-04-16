# MySkills

Personal Claude Code skills and commands collection.

## Installation

### Option 1: Plugin (recommended)

```bash
# Local development / testing
claude --plugin-dir ~/Desktop/_SourceCode/MySkills

# Or add as marketplace (after pushing to GitHub)
claude plugin marketplace add your-username/MySkills
claude plugin install my-skills@your-username-MySkills
```

### Option 2: Symlink (legacy)

See [Symlink Installation](#option-1-symlink-recommended) below.

## Skills

| Skill | Trigger | Description |
|-------|---------|-------------|
| [git-health](skills/git-health/SKILL.md) | `/git-health` | Analyze git repo health: hot files, contributors, bug hotspots, activity trends |

## Commands

| Command | Trigger | Description |
|---------|---------|-------------|
| [mdout](commands/mdout.md) | `/mdout [path]` | Save last response to markdown file |

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
