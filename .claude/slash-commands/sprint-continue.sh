#!/bin/bash

# Sprint Continue Command - Shows next task to work on and creates action plan
# This command finds the next incomplete task and provides guidance

DOCS_DIR="$(pwd)/docs"
WEEK_NUM=1

# Find current active week
for i in {6..1}; do
    if [ -f "$DOCS_DIR/week${i}-todo.md" ]; then
        if grep -q "COMPLETE" "$DOCS_DIR/week${i}-todo.md" 2>/dev/null; then
            WEEK_NUM=$((i + 1))
        else
            WEEK_NUM=$i
            break
        fi
    fi
done

echo "🚀 SPRINT CONTINUE - Week $WEEK_NUM"
echo "===================================="
echo ""

CURRENT_TODO="$DOCS_DIR/week${WEEK_NUM}-todo.md"

if [ -f "$CURRENT_TODO" ]; then
    # Find first uncompleted task
    NEXT_TASK=$(grep -E "^- \[ \]" "$CURRENT_TODO" 2>/dev/null | head -1 | sed 's/- \[ \] //')
    
    if [ -n "$NEXT_TASK" ]; then
        echo "📍 Next Task:"
        echo "   $NEXT_TASK"
        echo ""
        
        # Determine task category and provide specific guidance
        if echo "$NEXT_TASK" | grep -qi "CI/CD\|GitHub Actions"; then
            echo "📋 Task Type: CI/CD Pipeline Setup"
            echo ""
            echo "🎯 Suggested Actions:"
            echo "1. Create .github/workflows/deploy.yml"
            echo "2. Add Salesforce CLI to workflow"
            echo "3. Configure secrets in GitHub"
            echo "4. Set up automated testing"
            echo ""
            echo "📁 Relevant Files:"
            echo "  • Create: .github/workflows/deploy.yml"
            echo "  • Update: README.md with CI/CD badge"
            
        elif echo "$NEXT_TASK" | grep -qi "object\|__c"; then
            echo "📋 Task Type: Salesforce Object Creation"
            echo ""
            echo "🎯 Suggested Actions:"
            echo "1. Create object metadata files"
            echo "2. Define fields and relationships"
            echo "3. Add validation rules"
            echo "4. Deploy to org"
            echo ""
            echo "📁 Relevant Files:"
            echo "  • force-app/main/default/objects/"
            echo "  • Reference: docs/data-model.md"
            
        elif echo "$NEXT_TASK" | grep -qi "page layout\|lightning"; then
            echo "📋 Task Type: UI Configuration"
            echo ""
            echo "🎯 Suggested Actions:"
            echo "1. Create page layouts"
            echo "2. Configure Lightning pages"
            echo "3. Set up related lists"
            echo "4. Add quick actions"
            echo ""
            echo "📁 Relevant Files:"
            echo "  • force-app/main/default/layouts/"
            echo "  • force-app/main/default/flexipages/"
            
        elif echo "$NEXT_TASK" | grep -qi "flow\|automation\|process"; then
            echo "📋 Task Type: Process Automation"
            echo ""
            echo "🎯 Suggested Actions:"
            echo "1. Create Flow in Salesforce"
            echo "2. Define trigger criteria"
            echo "3. Configure actions"
            echo "4. Test automation"
            echo ""
            echo "📁 Relevant Files:"
            echo "  • force-app/main/default/flows/"
            
        else
            echo "📋 Task Type: General Development"
            echo ""
            echo "🎯 Review the task and determine next steps"
        fi
        
        echo ""
        echo "📚 Context Documents:"
        echo "  • Architecture: docs/architecture.md"
        echo "  • Data Model: docs/data-model.md"
        echo "  • Sprint Plan: docs/sprint-plan.md"
        echo ""
        
        # Show task context (tasks around it)
        echo "📊 Task Context:"
        grep -B2 -A2 "$NEXT_TASK" "$CURRENT_TODO" 2>/dev/null | grep "^- \[" | head -5
        
    else
        echo "✅ All tasks in Week $WEEK_NUM are complete!"
        echo ""
        NEXT_WEEK=$((WEEK_NUM + 1))
        if [ -f "$DOCS_DIR/week${NEXT_WEEK}-todo.md" ]; then
            echo "📅 Ready to start Week $NEXT_WEEK"
            echo "   Run this command again to see Week $NEXT_WEEK tasks"
        else
            echo "🎉 All planned sprints complete!"
        fi
    fi
else
    echo "⚠️  No todo file found for Week $WEEK_NUM"
    echo ""
    echo "Available week files:"
    ls -la "$DOCS_DIR"/week*-todo.md 2>/dev/null || echo "No week files found"
fi

echo ""
echo "💡 Commands:"
echo "  '/sprint-status' - Check current progress"
echo "  '/sprint-recap' - View completed work"