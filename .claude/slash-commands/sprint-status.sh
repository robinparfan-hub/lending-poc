#!/bin/bash

# Sprint Status Command - Shows current sprint progress
# This command analyzes the current week's todo list and shows progress

DOCS_DIR="$(pwd)/docs"
CURRENT_DATE=$(date +%Y-%m-%d)
WEEK_NUM=1  # Default to week 1

# Try to determine current week based on existing todo files
for i in {6..1}; do
    if [ -f "$DOCS_DIR/week${i}-todo.md" ]; then
        # Check if this week is marked complete
        if grep -q "COMPLETE" "$DOCS_DIR/week${i}-todo.md" 2>/dev/null; then
            WEEK_NUM=$((i + 1))
        else
            WEEK_NUM=$i
            break
        fi
    fi
done

echo "📊 SPRINT STATUS - Week $WEEK_NUM"
echo "================================="
echo ""

# Check if current week todo exists
CURRENT_TODO="$DOCS_DIR/week${WEEK_NUM}-todo.md"
if [ -f "$CURRENT_TODO" ]; then
    # Extract key information
    THEME=$(grep "Theme:" "$CURRENT_TODO" 2>/dev/null | head -1 || echo "")
    PROGRESS=$(grep "Progress:" "$CURRENT_TODO" 2>/dev/null | head -1 || echo "")
    STATUS=$(grep "Sprint Status:" "$CURRENT_TODO" 2>/dev/null | head -1 || echo "")
    
    echo "📅 Current: Week $WEEK_NUM"
    echo "$THEME"
    echo "$PROGRESS"
    echo "$STATUS"
    echo ""
    
    # Count completed vs total tasks
    TOTAL_TASKS=$(grep -E "^- \[.\]" "$CURRENT_TODO" 2>/dev/null | wc -l | tr -d ' ')
    COMPLETED=$(grep -E "^- \[x\]|^- \[✓\]|✅" "$CURRENT_TODO" 2>/dev/null | wc -l | tr -d ' ')
    
    echo "📈 Task Completion: $COMPLETED/$TOTAL_TASKS tasks"
    echo ""
    
    # Show next uncompleted tasks (first 5)
    echo "📌 Next Tasks:"
    grep -E "^- \[ \]" "$CURRENT_TODO" 2>/dev/null | head -5 | sed 's/- \[ \]/  •/'
    echo ""
    
    # Show completed items from previous week if exists
    if [ $WEEK_NUM -gt 1 ]; then
        PREV_WEEK=$((WEEK_NUM - 1))
        PREV_TODO="$DOCS_DIR/week${PREV_WEEK}-todo.md"
        if [ -f "$PREV_TODO" ]; then
            echo "✅ Previous Week Highlights:"
            grep -E "^- \[x\]|✅" "$PREV_TODO" 2>/dev/null | head -3 | sed 's/- \[x\]/  ✓/'
            echo ""
        fi
    fi
else
    echo "⚠️  No todo file found for Week $WEEK_NUM"
    echo "   Looking for: $CURRENT_TODO"
    echo ""
    echo "Available week files:"
    ls -la "$DOCS_DIR"/week*-todo.md 2>/dev/null || echo "No week files found"
fi

# Show key project info
echo "🔧 Project Configuration:"
echo "  • Salesforce Org: lending-poc"
echo "  • GitHub: https://github.com/robinparfan-hub/lending-poc"
echo "  • Docs: $DOCS_DIR"
echo ""

echo "💡 Use '/sprint-continue' to resume work"
echo "   Use '/sprint-recap' for full history"