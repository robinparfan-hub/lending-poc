#!/bin/bash

# Sprint Recap Command - Shows all completed work across all sprints
# This command provides a comprehensive history of the project

DOCS_DIR="$(pwd)/docs"

echo "📚 SPRINT RECAP - Complete Project History"
echo "=========================================="
echo ""

# Iterate through all weeks
for week in {1..6}; do
    TODO_FILE="$DOCS_DIR/week${week}-todo.md"
    
    if [ -f "$TODO_FILE" ]; then
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "📅 WEEK $week"
        
        # Get theme and status
        THEME=$(grep "Theme:" "$TODO_FILE" 2>/dev/null | head -1 | sed 's/.*Theme: //')
        STATUS=$(grep "Sprint Status:" "$TODO_FILE" 2>/dev/null | head -1 | sed 's/.*Status: //')
        PROGRESS=$(grep "Progress:" "$TODO_FILE" 2>/dev/null | head -1 | sed 's/.*Progress: //')
        
        if [ -n "$THEME" ]; then
            echo "Theme: $THEME"
        fi
        
        if [ -n "$STATUS" ]; then
            echo "Status: $STATUS"
        fi
        
        if [ -n "$PROGRESS" ]; then
            echo "$PROGRESS"
        fi
        
        echo ""
        
        # Show completed tasks
        COMPLETED_COUNT=$(grep -E "^- \[x\]|^- \[✓\]|✅" "$TODO_FILE" 2>/dev/null | wc -l | tr -d ' ')
        
        if [ "$COMPLETED_COUNT" -gt 0 ]; then
            echo "✅ Completed Items ($COMPLETED_COUNT):"
            grep -E "^- \[x\]|^- \[✓\]|✅" "$TODO_FILE" 2>/dev/null | head -10 | sed 's/- \[x\]/  •/' | sed 's/- \[✓\]/  •/' | sed 's/.*✅/  •/'
            
            if [ "$COMPLETED_COUNT" -gt 10 ]; then
                echo "  ... and $((COMPLETED_COUNT - 10)) more"
            fi
        else
            echo "⏳ No completed items yet"
        fi
        
        echo ""
    fi
done

# Show key achievements from documentation
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🏆 KEY ACHIEVEMENTS"
echo ""

# Check for key documents
if [ -f "$DOCS_DIR/architecture.md" ]; then
    echo "✅ Technical Architecture documented"
fi

if [ -f "$DOCS_DIR/data-model.md" ]; then
    echo "✅ Data Model (ERD) designed"
fi

if [ -f "$DOCS_DIR/api-design.md" ]; then
    echo "✅ API Specifications created"
fi

if [ -f "$DOCS_DIR/product-requirements.md" ]; then
    echo "✅ Product Requirements defined"
fi

if [ -f "$DOCS_DIR/sprint-plan.md" ]; then
    echo "✅ 6-Week Sprint Plan created"
fi

echo ""

# Show project configuration
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "⚙️ PROJECT CONFIGURATION"
echo ""

# Check Git status
if [ -d .git ]; then
    BRANCH=$(git branch --show-current 2>/dev/null)
    REMOTE=$(git remote get-url origin 2>/dev/null | sed 's/.*github.com[:/]//' | sed 's/.git$//')
    COMMITS=$(git rev-list --count HEAD 2>/dev/null)
    
    echo "📦 Git Repository:"
    echo "  • Branch: $BRANCH"
    echo "  • GitHub: https://github.com/$REMOTE"
    echo "  • Commits: $COMMITS"
    echo ""
fi

# Check Salesforce connection
if command -v sf &> /dev/null; then
    ORG_INFO=$(sf org display --target-org lending-poc --json 2>/dev/null | grep username | sed 's/.*"username": "//' | sed 's/",//')
    if [ -n "$ORG_INFO" ]; then
        echo "☁️ Salesforce Org:"
        echo "  • Alias: lending-poc"
        echo "  • Username: $ORG_INFO"
        echo ""
    fi
fi

# Summary statistics
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 SUMMARY STATISTICS"
echo ""

TOTAL_WEEKS=$(ls "$DOCS_DIR"/week*-todo.md 2>/dev/null | wc -l | tr -d ' ')
COMPLETED_WEEKS=$(grep -l "COMPLETE" "$DOCS_DIR"/week*-todo.md 2>/dev/null | wc -l | tr -d ' ')
TOTAL_TASKS=$(grep -h "^- \[.\]" "$DOCS_DIR"/week*-todo.md 2>/dev/null | wc -l | tr -d ' ')
COMPLETED_TASKS=$(grep -h -E "^- \[x\]|^- \[✓\]" "$DOCS_DIR"/week*-todo.md 2>/dev/null | wc -l | tr -d ' ')

echo "📅 Sprints: $COMPLETED_WEEKS/$TOTAL_WEEKS weeks complete"
echo "✅ Tasks: $COMPLETED_TASKS/$TOTAL_TASKS tasks done"

if [ "$TOTAL_TASKS" -gt 0 ]; then
    PERCENT=$((COMPLETED_TASKS * 100 / TOTAL_TASKS))
    echo "📈 Overall Progress: $PERCENT%"
fi

echo ""
echo "💡 Use '/sprint-status' for current week"
echo "   Use '/sprint-continue' to resume work"