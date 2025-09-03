# Week 2 Sprint: Core Platform Development
**Sprint Period**: September 2-8, 2025  
**Theme**: Object Creation, Basic Layouts, Loan Application Creation, Demo Alpha Release

## 🎯 Sprint Goals
- Complete remaining infrastructure setup from Week 1
- Implement core Salesforce custom objects
- Create basic user interfaces and page layouts
- Develop initial loan application flow
- Deploy alpha version for internal testing

## 📋 Todo List

### Day 1: Infrastructure & Setup (Carried from Week 1)

#### CI/CD Pipeline
- [ ] Set up GitHub Actions workflow for Salesforce deployments
- [ ] Configure automated testing on PR
- [ ] Set up branch protection rules on GitHub
- [ ] Create deployment scripts

#### Team Alignment (If applicable)
- [ ] Kick-off meeting for code development phase
- [ ] Review branching strategy
- [ ] Establish code review process

### Day 2-3: Custom Object Creation

#### Core Objects Implementation
- [ ] Create **Loan_Application__c**
  - [ ] Fields: Application Number, Status, Amount, Term, Interest Rate, Purpose
  - [ ] Validation rules
  - [ ] Workflow for auto-numbering
  
- [ ] Create **Applicant_Profile__c**
  - [ ] Fields: Name, SSN (encrypted), DOB, Email, Phone, Address
  - [ ] Validation rules for data quality
  - [ ] Duplicate management rules
  
- [ ] Create **Income_Source__c**
  - [ ] Fields: Type, Employer, Amount, Frequency, Verified Status
  - [ ] Roll-up to Applicant Profile
  
- [ ] Create **Credit_Report__c**
  - [ ] Fields: Score, Bureau, Report Date, Inquiries, Trade Lines
  - [ ] Integration fields for external data
  
- [ ] Create **Decision__c**
  - [ ] Fields: Decision Type, Outcome, Reason Codes, Approved Amount
  - [ ] Approval process configuration
  
- [ ] Create **Loan__c**
  - [ ] Fields: Loan Number, Disbursement Date, Principal, Balance
  - [ ] Payment schedule calculations
  
- [ ] Create **Document__c**
  - [ ] Fields: Type, Status, Verification Status, S3 Link
  - [ ] File attachment configuration

### Day 3: Relationships & Automation

#### Data Relationships
- [ ] Configure Master-Detail: Loan Application → Applicant Profile
- [ ] Configure Lookups: Income Source → Applicant Profile
- [ ] Configure Lookups: Credit Report → Loan Application
- [ ] Configure Lookups: Decision → Loan Application
- [ ] Create Junction Objects (if needed)
- [ ] Set up Roll-up Summary fields

#### Process Automation
- [ ] Create Flow: Application Status Updates
- [ ] Create Flow: Document Verification Process
- [ ] Configure Email Alerts for status changes
- [ ] Set up Task creation for manual reviews
- [ ] Create Process Builder for field updates

### Day 4: Page Layouts & Apps

#### User Interface Setup
- [ ] Create Page Layouts:
  - [ ] Loan Officer Layout
  - [ ] Underwriter Layout
  - [ ] Customer Service Layout
  - [ ] Read-only Layout
  
- [ ] Configure Lightning Record Pages:
  - [ ] Loan Application Record Page
  - [ ] Applicant Profile Page
  - [ ] Decision Review Page
  
- [ ] Set up Related Lists on all objects
- [ ] Create Quick Actions:
  - [ ] New Application
  - [ ] Upload Document
  - [ ] Make Decision
  - [ ] Add Note

#### Lightning App Configuration
- [ ] Create "Lending Console" Lightning App
- [ ] Configure Navigation Menu:
  - [ ] Applications Queue
  - [ ] My Applications
  - [ ] Reports & Dashboards
  - [ ] Settings
- [ ] Set up Home Page with components
- [ ] Configure Utility Bar:
  - [ ] Recent Items
  - [ ] Notes
  - [ ] Calculator

### Day 5: Alpha Demo & Testing

#### Test Data Creation
- [ ] Create test Applicant profiles (10-15 records)
- [ ] Create test Loan Applications in various stages
- [ ] Generate sample Credit Reports
- [ ] Upload sample Documents

#### Basic Flow Testing
- [ ] Test Application creation flow
- [ ] Test status progression
- [ ] Test validation rules
- [ ] Test email alerts
- [ ] Test page layouts for different profiles

#### Alpha Demo Preparation
- [ ] Create demo script
- [ ] Prepare slide deck with screenshots
- [ ] Document known issues
- [ ] Create feedback form
- [ ] Schedule demo session

## 📊 Success Metrics
- [ ] All 7 core objects created and deployed
- [ ] Relationships properly configured
- [ ] Basic automation working (flows/processes)
- [ ] Page layouts optimized for user roles
- [ ] Alpha demo completed with stakeholder feedback
- [ ] Test coverage >75% for all Apex code

## 🚧 Dependencies & Risks
| Dependency | Status | Mitigation |
|------------|--------|------------|
| Salesforce org access | ✅ Complete | Already connected |
| GitHub repository | ✅ Complete | Already set up |
| CI/CD pipeline | ⏳ Day 1 Task | Manual deployment as backup |
| Test data | ⏳ Day 5 Task | Use data loader if needed |

## 📝 Deliverables Checklist
- [ ] 7 Custom Objects with fields and relationships
- [ ] 3-4 Page Layouts per key object
- [ ] Lightning App with navigation
- [ ] 5+ Automation processes (Flows/PB)
- [ ] Test data set (50+ records)
- [ ] Alpha demo recording
- [ ] Feedback summary document
- [ ] Week 2 retrospective notes

## 🎯 Definition of Done
- All objects deployed to Salesforce org
- Relationships verified with test data
- Page layouts tested with different profiles
- Automation tested end-to-end
- Alpha demo delivered to stakeholders
- Feedback collected and prioritized
- Code committed to GitHub with proper commit messages

## 📅 Daily Standup Topics
- **Monday**: Infrastructure setup, CI/CD configuration
- **Tuesday**: Object creation progress
- **Wednesday**: Relationships and automation
- **Thursday**: UI/UX and page layouts
- **Friday**: Demo preparation and delivery

## 🔄 Next Week Preview (Week 3)
- Build Lightning Web Components
- Create application wizard interface
- Implement mock service integrations
- Add lifecycle visualization
- Enhance user experience

---
**Last Updated**: September 1, 2025  
**Sprint Status**: 📅 Scheduled  
**Progress**: 0% Complete  
**Prerequisites**: ✅ Week 1 Complete