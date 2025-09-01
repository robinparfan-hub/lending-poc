# Sprint Command Implementations

## /sprint-status Implementation

When you type `/sprint-status`, I will:

```markdown
1. Check today's date and calculate current sprint week
2. Read /docs/week{current}-todo.md
3. Count completed vs total tasks
4. Read /docs/week{current}-progress-report.md if exists
5. For context, read previous weeks' completed items
6. Display:
   - Current week number
   - Progress percentage
   - Key completed items
   - Next priority tasks
   - Blockers/risks
```

## /sprint-recap Implementation

When you type `/sprint-recap`, I will:

```markdown
1. List all /docs/week*-todo.md files
2. For each week:
   - Extract completed tasks (marked with [x])
   - Note key deliverables
3. Read key documents:
   - /docs/architecture.md (summary)
   - /docs/data-model.md (objects created)
   - /docs/api-design.md (endpoints defined)
4. Generate comprehensive summary:
   - Timeline of achievements
   - Technical decisions made
   - Components built
   - Integration points established
```

## /sprint-continue Implementation

When you type `/sprint-continue`, I will:

```markdown
1. Load current week's todo list
2. Find first uncompleted task
3. Check related documentation:
   - If data model task → load /docs/data-model.md
   - If API task → load /docs/api-design.md
   - If architecture task → load /docs/architecture.md
4. Create active todo list with TodoWrite tool
5. Suggest specific next actions
```

## /sprint-week Implementation

When you type `/sprint-week 2` (or any number), I will:

```markdown
1. Read /docs/week{number}-todo.md
2. Read /docs/sprint-plan.md section for that week
3. Check if previous week's dependencies are met
4. Display:
   - Week theme
   - Objectives
   - Planned deliverables
   - Success criteria
   - Required prerequisites
```

## /project-context Implementation

When you type `/project-context`, I will:

```markdown
1. Read and summarize:
   - /docs/vision.md → Product goals
   - /docs/product-requirements.md → Key features
   - /docs/architecture.md → System design
   - /docs/data-model.md → Object structure
   - /docs/api-design.md → Integration points
   - CLAUDE.md → Org connection details
2. Provide consolidated context:
   - Project: Consumer Lending Platform POC
   - Timeline: 6-week sprint
   - Current state
   - Key technical decisions
   - Salesforce org details
```

## Quick Reference Card

```bash
# Start new session - get current status
/sprint-status

# Resume work after break
/sprint-continue

# Get full history of work done
/sprint-recap

# Look ahead to next week
/sprint-week 2

# Get complete project overview
/project-context

# Combination for maximum context:
/project-context
/sprint-recap
/sprint-continue
```

## File Structure Expected

```
/lending-poc/
├── docs/
│   ├── week1-todo.md
│   ├── week1-progress-report.md
│   ├── week2-todo.md (when created)
│   ├── sprint-plan.md
│   ├── architecture.md
│   ├── data-model.md
│   ├── api-design.md
│   ├── product-requirements.md
│   └── vision.md
├── scripts/
│   └── sprint-commands.md (this file)
├── .claudecommands
└── CLAUDE.md
```

## Sample Output Format

### /sprint-status output:
```
📊 Sprint Status: Week 1 (Day 1/5)
Theme: Foundation & Planning

Progress: ███████░░░░░░░░░ 25% Complete

✅ Completed:
- Salesforce org setup
- Architecture documentation
- Data model design

🔄 In Progress:
- Git repository setup

📌 Next Priority:
- Configure CI/CD pipeline
- Create project board

⚠️ Risks:
- None identified

💡 Ahead of schedule by ~2 days
```

### /sprint-continue output:
```
🚀 Resuming Sprint Week 1

📍 Current Task: Configure Git repository
Category: Environment Setup
Priority: High

📋 Creating todo list...
✅ Todo list created with 5 active tasks

🎯 Suggested Next Actions:
1. Initialize git repository
2. Create .gitignore file
3. Set up branch protection rules
4. Configure commit hooks

Ready to proceed with Git setup? (Y/n)
```