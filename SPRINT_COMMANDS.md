# 🚀 Sprint Commands - Quick Reference

Use these commands at the start of any Claude Code session to load your project context.

## Essential Commands

### `/sprint-status`
**Use when**: Starting a new session or checking progress
```
Shows: Current week, progress %, completed tasks, next priorities
```

### `/sprint-continue` 
**Use when**: Resuming work after a break
```
Shows: Next incomplete task, creates todo list, suggests actions
```

### `/sprint-recap`
**Use when**: Need full history of what's been built
```
Shows: All completed work across all weeks, key decisions made
```

## Additional Commands

### `/sprint-week [number]`
**Use when**: Planning or reviewing a specific week
```
Example: /sprint-week 2
Shows: That week's plan, deliverables, dependencies
```

### `/project-context`
**Use when**: Need complete project overview
```
Shows: Vision, architecture, data model, API design, org details
```

## 🎯 Recommended Session Starters

### For Daily Work:
```
/sprint-status
/sprint-continue
```

### After Session Timeout:
```
/sprint-recap
/sprint-continue  
```

### For Planning:
```
/project-context
/sprint-week 2
```

### For New Team Member:
```
/project-context
/sprint-recap
/sprint-status
```

## 📁 What These Commands Read

- Current sprint: `/docs/week*-todo.md`
- Progress reports: `/docs/week*-progress-report.md`  
- Project docs: `/docs/*.md`
- Org config: `CLAUDE.md`
- Sprint plan: `/docs/sprint-plan.md`

## 💡 Pro Tips

1. **Start every session** with `/sprint-status`
2. **After long breaks** use `/sprint-recap` first
3. **Before planning** run `/project-context`
4. **Chain commands** for maximum context

## Example Session Start

```bash
You: /sprint-status
Claude: [Shows current week progress]

You: /sprint-continue  
Claude: [Loads next task and creates todo list]

You: Let's work on the Git setup
Claude: [Proceeds with specific task]
```

---
**Note**: These commands work because Claude Code will read the sprint files in your `/docs` directory and understand the context from the structured markdown files we've created.