# Yiming's Toolkit

Personal Claude Code plugin marketplace - skills, commands, and MCP servers.

## Available Plugins

| Plugin | Description |
|--------|-------------|
| **git-tools** | Git repository analysis and health checking |
| **dev-workflow** | Development workflow automation (debug, deploy, output) |
| **mcp-collection** | Curated MCP server configurations |

## Installation

### 1. Add this marketplace (once)

```bash
claude plugin marketplace add gilleschen1981/202604_MySkilles
```

### 2. Install plugins as needed

```bash
# Install individual plugins
claude plugin install git-tools@gilleschen1981-202604_MySkilles
claude plugin install dev-workflow@gilleschen1981-202604_MySkilles
claude plugin install mcp-collection@gilleschen1981-202604_MySkilles

# Specify scope
claude plugin install git-tools@gilleschen1981-202604_MySkilles --scope project
```

### Local Development

```bash
# Test a specific plugin
claude --plugin-dir ~/Desktop/_SourceCode/MySkills/plugins/git-tools

# Validate marketplace
claude plugin validate ~/Desktop/_SourceCode/MySkills
```

## Plugin Details

### git-tools

| Skill | Trigger | Description |
|-------|---------|-------------|
| git-health | `/git-health` | Analyze git repo health: hot files, contributors, bug hotspots |

### dev-workflow

| Type | Name | Description |
|------|------|-------------|
| Skill | debug-local | Deploy microservices to D2 + run Flutter locally |
| Command | mdout | Save last response to markdown file |

### mcp-collection

Pre-configured MCP servers:
- `filesystem` - File system access
- `fetch` - HTTP fetch capabilities

## Adding External Plugins

Edit `.claude-plugin/marketplace.json` to add plugins from other GitHub repos:

```json
{
  "name": "external-plugin",
  "description": "A plugin from another repo",
  "source": {
    "source": "url",
    "url": "https://github.com/someone/their-plugin.git"
  }
}
```

## Structure

```
MySkills/
├── .claude-plugin/
│   └── marketplace.json      # Marketplace manifest
├── plugins/
│   ├── git-tools/
│   │   ├── .claude-plugin/plugin.json
│   │   └── skills/git-health/SKILL.md
│   ├── dev-workflow/
│   │   ├── .claude-plugin/plugin.json
│   │   ├── skills/debug-local/SKILL.md
│   │   └── commands/mdout.md
│   └── mcp-collection/
│       ├── .claude-plugin/plugin.json
│       └── .mcp.json
└── README.md
```
