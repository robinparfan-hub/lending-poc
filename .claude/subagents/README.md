# Lending POC Subagents

These specialized agents help with specific aspects of the lending platform development. Claude can invoke these agents using the Task tool when appropriate.

## Available Subagents

### 1. 🏗️ salesforce-architect
**Purpose**: Design and review Salesforce architecture decisions
**Capabilities**:
- Analyze data model relationships
- Review object field definitions
- Suggest best practices for governor limits
- Design sharing and security models
- Plan integration patterns

**When to use**:
- Creating new custom objects
- Designing complex relationships
- Planning data architecture
- Reviewing security model

### 2. 💾 object-builder
**Purpose**: Create Salesforce custom objects and fields
**Capabilities**:
- Generate object metadata XML
- Create field definitions with proper types
- Set up validation rules
- Configure page layouts
- Define record types

**When to use**:
- Week 2: Creating the 8 core objects
- Adding new fields to existing objects
- Setting up master-detail relationships

### 3. ⚡ lwc-developer
**Purpose**: Build Lightning Web Components
**Capabilities**:
- Create LWC components with proper structure
- Implement wire adapters
- Handle events and communication
- Build responsive designs
- Create test files

**When to use**:
- Week 3: Building application wizard
- Creating custom UI components
- Building data visualization

### 4. 🔄 flow-automation
**Purpose**: Design and implement Salesforce automation
**Capabilities**:
- Create Flow metadata
- Design Process Builder logic
- Set up workflow rules
- Configure approval processes
- Build email alerts and templates

**When to use**:
- Setting up application status flows
- Creating approval processes
- Automating document verification

### 5. 🧪 test-engineer
**Purpose**: Create and run comprehensive tests including UI automation
**Capabilities**:
- Write Apex test classes with 90%+ coverage
- Create Jest tests for LWC components
- **Build UI automation tests using Playwright MCP tools**
- Generate consistent test data via TestDataFactory
- Execute end-to-end test scenarios
- Capture screenshots and validate UI states

**When to use**:
- After creating any Apex classes
- Testing LWC components
- Building UI automation for user flows
- Validating end-to-end scenarios
- Preparing for deployment

### 6. 🔌 integration-specialist
**Purpose**: Handle external integrations
**Capabilities**:
- Design REST API callouts
- Create mock services
- Handle authentication
- Process webhooks
- Manage external data

**When to use**:
- Week 3: Mock service implementation
- Week 5: Service integration
- Setting up Plaid/credit bureau connectors

### 7. 🌐 portal-builder
**Purpose**: Develop Experience Cloud portals
**Capabilities**:
- Configure Experience sites
- Create portal pages
- Set up guest user access
- Design customer journeys
- Configure authentication

**When to use**:
- Week 4: Customer portal development
- Setting up self-service features
- Configuring external user access

### 8. 🤖 agentforce-configurator
**Purpose**: Implement AI and AgentForce features
**Capabilities**:
- Configure AgentForce agents
- Set up Einstein features
- Create prediction models
- Design conversation flows
- Implement intelligent automation

**When to use**:
- Week 6: AI implementation
- Setting up intelligent agents
- Creating predictive models

### 9. 📊 analytics-designer
**Purpose**: Create reports and dashboards
**Capabilities**:
- Build reports with complex filters
- Design dashboards
- Create Einstein Analytics datasets
- Set up scheduled reports
- Configure KPI tracking

**When to use**:
- Creating operational dashboards
- Building executive reports
- Setting up analytics

### 10. 💻 apex-developer
**Purpose**: Expert Apex development with test-driven approach
**Capabilities**:
- Write bulkified, governor-limit-safe Apex code
- **Create test classes FIRST before implementation**
- **Iteratively run tests and fix until 90%+ coverage**
- Implement trigger handlers and batch processes
- Design service layers and API controllers
- Enforce security (CRUD/FLS) in all code

**When to use**:
- Creating Apex controllers for LWC
- Building trigger logic
- Implementing service classes
- Writing batch/scheduled jobs
- Creating REST/SOAP services

### 11. 🚀 deployment-manager
**Purpose**: Handle deployments and CI/CD
**Capabilities**:
- Create deployment packages
- Configure GitHub Actions
- Set up change sets
- Manage environment variables
- Handle deployment errors

**When to use**:
- Setting up CI/CD pipeline
- Deploying to production
- Managing releases

## How to Invoke Subagents

Claude will automatically use these agents when appropriate, but you can also request them specifically:

```
"Use the salesforce-architect agent to review our data model"
"Have the object-builder create the Loan_Application__c object"
"Get the test-engineer to write tests for our credit check service"
```

## Subagent Context

Each agent has access to:
- Project documentation in `/docs`
- Sprint plans and progress
- Salesforce org configuration
- GitHub repository
- Previous work completed

## Adding New Subagents

To add a new subagent:
1. Create a profile in this directory
2. Define capabilities and use cases
3. Add instruction file with specific guidance
4. Update this README

---
**Note**: These agents are invoked through Claude's Task tool and operate within the context of your lending POC project.