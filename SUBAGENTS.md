# 🤖 Lending POC Subagents

Quick reference for specialized agents available for your project.

## How to Use

Simply ask me to use a specific agent, or I'll automatically invoke them when appropriate:

```
"Use the object-builder agent to create Loan_Application__c"
"Have the salesforce-architect review our data model"
"Get the lwc-developer to build the application wizard"
```

## Available Agents

### Week 2 Agents (Object Creation)
| Agent | Purpose | When to Use |
|-------|---------|-------------|
| **object-builder** | Create Salesforce objects & fields | Building the 8 core objects |
| **salesforce-architect** | Architecture & design review | Planning relationships, security |
| **apex-developer** | Test-driven Apex development | Controllers, triggers, services |
| **deployment-manager** | CI/CD and deployments | Setting up GitHub Actions |

### Week 3 Agents (UI Development)
| Agent | Purpose | When to Use |
|-------|---------|-------------|
| **lwc-developer** | Build Lightning Web Components | Creating wizard, visualizations |
| **flow-automation** | Create Flows & Process Builder | Status updates, email alerts |
| **test-engineer** | Tests + Playwright UI automation | Unit tests & end-to-end testing |

### Week 4 Agents (Portal)
| Agent | Purpose | When to Use |
|-------|---------|-------------|
| **portal-builder** | Experience Cloud setup | Customer portal creation |
| **analytics-designer** | Reports & dashboards | Building analytics |

### Week 5-6 Agents (Integration & AI)
| Agent | Purpose | When to Use |
|-------|---------|-------------|
| **integration-specialist** | External integrations | Plaid, credit bureaus |
| **agentforce-configurator** | AI & AgentForce setup | Intelligent automation |

## Example Invocations

### Architecture Review
```
"salesforce-architect: Review if Loan and Payment should be master-detail or lookup"
```

### Object Creation
```
"object-builder: Create all 8 objects with fields from the data model"
```

### Component Development
```
"lwc-developer: Build the loan application wizard with 4 steps"
```

### Testing
```
"test-engineer: Generate test data for 50 loan applications"
"test-engineer: Create Playwright UI tests for the application flow"
```

### Apex Development
```
"apex-developer: Create LoanApplicationController with full test coverage"
"apex-developer: Build CreditCheckService using TDD approach"
```

## Agent Capabilities

Each agent has:
- ✅ Access to all project documentation
- ✅ Knowledge of current sprint progress
- ✅ Salesforce best practices
- ✅ POC vs Production guidance
- ✅ Code generation capabilities

## Files Created

```
.claude/
├── subagents/
│   ├── README.md               # Full documentation
│   ├── salesforce-architect.md # Architecture guidance
│   ├── object-builder.md       # Object creation specs
│   ├── lwc-developer.md        # LWC templates
│   ├── apex-developer.md       # TDD Apex development
│   └── test-engineer.md        # Testing with Playwright
```

## Pro Tips

1. **Batch Operations**: Ask agents to handle multiple related tasks
2. **Review Mode**: Have architects review before builders create
3. **Test Everything**: Use test-engineer after each component
4. **Document Decisions**: Agents will note POC shortcuts vs production needs

---
**Note**: These agents enhance Claude's capabilities for specific Salesforce development tasks. They maintain context across your entire project.