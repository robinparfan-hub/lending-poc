# LWC Architecture Plan for Lending Platform

## Component Structure
We'll create a modular LWC architecture with 3 main components:

### 1. **loanApplicationWizard** (Main Container)
- **Purpose**: Smart container managing application state and flow
- **Features**:
  - Progress indicator showing current stage (Draft → Submitted → Under Review → Approved/Declined)
  - Dynamic stage rendering based on Status__c field
  - Context awareness (internal vs external user detection)
  - Integration with Apex services for real-time decisions

### 2. **loanApplicationStage** (Stage Display Component)
- **Purpose**: Renders individual stages with appropriate fields
- **Stages**:
  1. **Draft/Application Entry**: Editable form fields
  2. **Submitted/Under Review**: Read-only summary with status updates
  3. **Pending Documentation**: Document upload interface
  4. **In Underwriting**: Processing status with estimated timeline
  5. **Approved**: Loan offer details with acceptance button
  6. **Declined**: Reason codes and next steps
  7. **Funded**: Final loan details and payment schedule

### 3. **loanOfferAcceptance** (Decision Component)
- **Purpose**: Handle loan offer acceptance for approved applications
- **Features**:
  - Display approved terms (amount, rate, monthly payment)
  - Accept/Decline buttons for customers
  - Terms & conditions acknowledgment
  - Digital signature capture

## Field Visibility Matrix

| Field | Internal View | External View (Customer) |
|-------|--------------|-------------------------|
| **SSN_Encrypted__c** | Masked (last 4) | Hidden |
| **Total_Income__c** | Full visibility | Hidden |
| **Risk Score/Credit Score** | Full visibility | Hidden |
| **Reason_Codes__c** | Full visibility | Simplified message |
| **Internal Notes** | Full visibility | Hidden |
| **Approved_Amount__c** | Full visibility | Visible when approved |
| **Interest_Rate__c** | Full visibility | Visible when approved |
| **Monthly Payment** | Full visibility | Visible when approved |
| **Application Status** | Full visibility | Visible |
| **Documents** | Full access | Own documents only |

## Technical Implementation Details

### User Context Detection
```javascript
// Detect if user is external (Experience Cloud) or internal
isExternalUser() {
    return window.location.pathname.includes('/s/') || 
           window.location.hostname.includes('.force.com');
}
```

### Component Communication
- Use Lightning Message Service for cross-component communication
- Publish events for stage transitions
- Subscribe to decision engine responses

### Security Features
- Field-level security enforcement via Apex
- CRUD/FLS checks in controllers
- Encrypted storage for sensitive data
- Session timeout handling for external users

### Mobile Responsiveness
- SLDS responsive grid system
- Touch-optimized buttons and inputs
- Collapsible sections for mobile view
- Progressive disclosure pattern

## File Structure
```
force-app/main/default/
├── lwc/
│   ├── loanApplicationWizard/
│   │   ├── loanApplicationWizard.js
│   │   ├── loanApplicationWizard.html
│   │   ├── loanApplicationWizard.js-meta.xml
│   │   └── loanApplicationWizard.css
│   ├── loanApplicationStage/
│   │   ├── loanApplicationStage.js
│   │   ├── loanApplicationStage.html
│   │   └── loanApplicationStage.js-meta.xml
│   └── loanOfferAcceptance/
│       ├── loanOfferAcceptance.js
│       ├── loanOfferAcceptance.html
│       └── loanOfferAcceptance.js-meta.xml
├── classes/
│   └── LoanApplicationController.cls (New Apex controller)
└── messageChannels/
    └── LoanApplicationUpdates.messageChannel-meta.xml
```

## Implementation Steps
1. Create base LWC components with responsive layouts
2. Implement user context detection and field visibility logic
3. Add Apex controller for secure data access
4. Integrate with existing DecisionEngineService
5. Add loan acceptance workflow with status updates
6. Implement Lightning Message Service for updates
7. Add comprehensive error handling and loading states
8. Create unit tests for all components
9. Add Playwright E2E tests for the complete flow

## Key Features by Component

### loanApplicationWizard
- Stage management and progression logic
- Integration with DecisionEngineService for real-time evaluation
- Auto-save functionality with draft status
- Field validation before stage progression
- Error recovery and retry mechanisms

### loanApplicationStage
- Dynamic field rendering based on stage and user type
- Conditional field visibility rules
- Input validation and formatting
- File upload capabilities for documents
- Progress save and resume functionality

### loanOfferAcceptance
- Display loan terms clearly (APR, monthly payment, total cost)
- Terms and conditions modal with scrollable content
- Digital signature capture using canvas
- Accept/Decline action buttons with confirmation
- PDF generation of signed agreement

## Integration Points

### Apex Services Integration
- **DecisionEngineService**: Real-time loan evaluation
- **CreditEvaluationService**: Credit score and risk assessment
- **LoanCalculatorService**: Payment calculations and amortization
- **LoanApplicationController**: New controller for LWC data operations

### Platform Features
- **Lightning Message Service**: Cross-component communication
- **Platform Events**: Real-time status updates
- **Files/ContentDocument**: Document management
- **Experience Cloud**: External user access

## Testing Strategy

### Unit Tests
- Jest tests for each LWC component
- Mock Apex responses for offline testing
- Validation logic testing
- User context detection testing

### Integration Tests
- Apex test classes for controller methods
- End-to-end flow testing
- Permission and security testing
- Cross-browser compatibility

### E2E Tests (Playwright)
- Complete application flow
- Document upload scenarios
- Loan acceptance workflow
- Mobile responsiveness verification

## Performance Considerations
- Lazy loading of stage components
- Debounced auto-save functionality
- Optimized Apex queries with selective fields
- Client-side caching of reference data
- Progressive enhancement for slow connections

## Security Considerations
- Field-level security enforcement in Apex
- CRUD/FLS checks before DML operations
- XSS prevention through proper encoding
- CSRF protection via Salesforce platform
- Secure handling of sensitive data (SSN, income)

## Accessibility Features
- ARIA labels for all interactive elements
- Keyboard navigation support
- Screen reader compatibility
- High contrast mode support
- Focus management for modal dialogs

## Next Phase Enhancements
- Real-time notifications using Platform Events
- Document preview and e-signature integration
- Multi-language support
- Analytics tracking for user behavior
- A/B testing framework for conversion optimization
- AI-powered form field suggestions
- Chatbot integration for application assistance

---
*Last Updated: September 3, 2025*
*Status: Ready for Implementation*