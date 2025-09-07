import { LightningElement, api, track } from 'lwc';

export default class LoanApplicationStage extends LightningElement {
    @api applicationData = {};
    @api currentStage = 'draft';
    @api isExternalUser = false;
    @api isReadOnly = false;
    
    @track localApplicationData = {
        Applicant_Profile__r: {}
    };
    @track showDocumentUpload = false;
    
    // Loan purpose options
    purposeOptions = [
        { label: 'Home Improvement', value: 'Home Improvement' },
        { label: 'Debt Consolidation', value: 'Debt Consolidation' },
        { label: 'Major Purchase', value: 'Major Purchase' },
        { label: 'Medical Expenses', value: 'Medical Expenses' },
        { label: 'Business', value: 'Business' },
        { label: 'Education', value: 'Education' },
        { label: 'Other', value: 'Other' }
    ];
    
    // Loan term options
    termOptions = [
        { label: '12 months', value: 12 },
        { label: '24 months', value: 24 },
        { label: '36 months', value: 36 },
        { label: '48 months', value: 48 },
        { label: '60 months', value: 60 },
        { label: '72 months', value: 72 }
    ];
    
    // Employment status options
    employmentOptions = [
        { label: 'Employed', value: 'Employed' },
        { label: 'Self-Employed', value: 'Self-Employed' },
        { label: 'Retired', value: 'Retired' },
        { label: 'Student', value: 'Student' },
        { label: 'Unemployed', value: 'Unemployed' }
    ];
    
    // Lifecycle
    connectedCallback() {
        // Deep clone the application data to avoid reference issues
        this.localApplicationData = { 
            ...this.applicationData,
            Applicant_Profile__r: {
                ...(this.applicationData?.Applicant_Profile__r || {})
            }
        };
        
        // TEST PREPOPULATION - REMOVE FOR PRODUCTION
        // Only prepopulate if this is a new application (draft stage with no existing data)
        if (this.isDraftStage && !this.localApplicationData.Amount_Requested__c) {
            this.prepopulateTestData();
        }
    }
    
    // TEST METHOD - REMOVE FOR PRODUCTION
    prepopulateTestData() {
        // Generate timestamp in YYYYMMDDHHmm format
        const now = new Date();
        const year = now.getFullYear();
        const month = String(now.getMonth() + 1).padStart(2, '0');
        const day = String(now.getDate()).padStart(2, '0');
        const hours = String(now.getHours()).padStart(2, '0');
        const minutes = String(now.getMinutes()).padStart(2, '0');
        const timestamp = `${year}${month}${day}${hours}${minutes}`;
        
        // Prepopulate loan details matching Decision Engine APPROVED_EXCELLENT_CREDIT scenario
        this.localApplicationData.Amount_Requested__c = 50000;  // Matches approved amount
        this.localApplicationData.Purpose__c = 'Home Improvement';
        this.localApplicationData.Term_Months__c = 60;  // Matches approved term
        
        // Ensure Applicant_Profile__r exists
        if (!this.localApplicationData.Applicant_Profile__r) {
            this.localApplicationData.Applicant_Profile__r = {};
        }
        
        // Prepopulate applicant information with timestamp
        this.localApplicationData.Applicant_Profile__r.Name = `Test ${timestamp}`;
        this.localApplicationData.Applicant_Profile__r.Email__c = `${timestamp}@test.com`;
        this.localApplicationData.Applicant_Profile__r.Date_of_Birth__c = '2000-12-31';
        this.localApplicationData.Applicant_Profile__r.Employment_Status__c = 'Employed';
        this.localApplicationData.Applicant_Profile__r.Phone__c = '555-555-5555';
        this.localApplicationData.Applicant_Profile__r.Total_Income__c = 120000;  // High income for excellent credit
        
        console.log('TEST DATA PREPOPULATED with timestamp:', timestamp);
        console.log('Values match Decision Engine APPROVED_EXCELLENT_CREDIT scenario');
        console.log('To remove prepopulation, delete the prepopulateTestData() method and its call in connectedCallback()');
    }
    
    @api
    get applicationDataForSave() {
        return this.localApplicationData;
    }
    
    // Null-safe getters for applicant fields
    get applicantName() {
        return this.localApplicationData?.Applicant_Profile__r?.Name || '';
    }
    
    get applicantEmail() {
        return this.localApplicationData?.Applicant_Profile__r?.Email__c || '';
    }
    
    get applicantPhone() {
        return this.localApplicationData?.Applicant_Profile__r?.Phone__c || '';
    }
    
    get applicantEmploymentStatus() {
        return this.localApplicationData?.Applicant_Profile__r?.Employment_Status__c || '';
    }
    
    get applicantIncome() {
        return this.localApplicationData?.Applicant_Profile__r?.Total_Income__c || null;
    }
    
    get applicantDOB() {
        return this.localApplicationData?.Applicant_Profile__r?.Date_of_Birth__c || '';
    }
    
    // Calculate max date for DOB (must be 18+ years old)
    get maxDateOfBirth() {
        const today = new Date();
        const maxDate = new Date(today.getFullYear() - 18, today.getMonth(), today.getDate());
        return maxDate.toISOString().split('T')[0];
    }
    
    // Computed properties
    get isDraftStage() {
        return this.currentStage === 'draft';
    }
    
    get isSubmittedStage() {
        return this.currentStage === 'submitted';
    }
    
    get isUnderwritingStage() {
        return this.currentStage === 'underwriting';
    }
    
    get isDecisionStage() {
        return this.currentStage === 'decision';
    }
    
    get isFundedStage() {
        return this.currentStage === 'funded';
    }
    
    get isApproved() {
        return this.applicationData.Status__c === 'Approved';
    }
    
    get isDeclined() {
        return this.applicationData.Status__c === 'Declined';
    }
    
    get showApplicantIncome() {
        return !this.isExternalUser && this.localApplicationData.Applicant_Profile__r?.Total_Income__c;
    }
    
    get showInternalFields() {
        return !this.isExternalUser;
    }
    
    get statusClass() {
        const status = this.applicationData.Status__c;
        if (status === 'Approved' || status === 'Funded') {
            return 'slds-badge slds-theme_success';
        } else if (status === 'Declined' || status === 'Cancelled') {
            return 'slds-badge slds-theme_error';
        } else if (status === 'Under Review' || status === 'In Underwriting') {
            return 'slds-badge slds-theme_warning';
        }
        return 'slds-badge';
    }
    
    get formattedAmount() {
        if (this.localApplicationData.Amount_Requested__c) {
            return new Intl.NumberFormat('en-US', {
                style: 'currency',
                currency: 'USD'
            }).format(this.localApplicationData.Amount_Requested__c);
        }
        return null;
    }
    
    get formattedApprovedAmount() {
        if (this.applicationData.Approved_Amount__c) {
            return new Intl.NumberFormat('en-US', {
                style: 'currency',
                currency: 'USD'
            }).format(this.applicationData.Approved_Amount__c);
        }
        return null;
    }
    
    get formattedMonthlyPayment() {
        if (this.applicationData.Monthly_Payment__c) {
            return new Intl.NumberFormat('en-US', {
                style: 'currency',
                currency: 'USD'
            }).format(this.applicationData.Monthly_Payment__c);
        }
        return null;
    }
    
    get declineMessage() {
        if (this.isExternalUser && this.isDeclined) {
            return this.applicationData.declineMessage || 'Your application does not meet our current lending criteria.';
        }
        return this.applicationData.Reason_Codes__c;
    }
    
    // Event handlers
    handleAmountChange(event) {
        this.localApplicationData.Amount_Requested__c = parseFloat(event.target.value);
        this.notifyChange('fieldChange');
    }
    
    handlePurposeChange(event) {
        this.localApplicationData.Purpose__c = event.detail.value;
        this.notifyChange('fieldChange');
    }
    
    handleTermChange(event) {
        this.localApplicationData.Term_Months__c = parseInt(event.detail.value);
        this.notifyChange('fieldChange');
    }
    
    handleApplicantFieldChange(event) {
        const field = event.currentTarget.dataset.field;
        const value = event.detail?.value !== undefined ? event.detail.value : event.target.value;
        
        if (!this.localApplicationData.Applicant_Profile__r) {
            this.localApplicationData.Applicant_Profile__r = {};
        }
        
        if (field === 'Total_Income__c' && value) {
            this.localApplicationData.Applicant_Profile__r[field] = parseFloat(value);
        } else {
            this.localApplicationData.Applicant_Profile__r[field] = value || '';
        }
        
        this.notifyChange('fieldChange');
    }
    
    handleEmploymentChange(event) {
        if (!this.localApplicationData.Applicant_Profile__r) {
            this.localApplicationData.Applicant_Profile__r = {};
        }
        this.localApplicationData.Applicant_Profile__r.Employment_Status__c = event.detail.value;
        this.notifyChange('fieldChange');
    }
    
    handleSave() {
        this.dispatchEvent(new CustomEvent('stagechange', {
            detail: {
                eventType: 'save',
                data: this.localApplicationData
            }
        }));
    }
    
    @api
    handleSubmit() {
        console.log('handleSubmit called in stage component');
        console.log('Dispatching stagechange event with data:', this.localApplicationData);
        this.dispatchEvent(new CustomEvent('stagechange', {
            detail: {
                eventType: 'submit',
                data: this.localApplicationData
            }
        }));
    }
    
    notifyChange(eventType) {
        // Removed auto-save functionality
        // Field changes now only update local state
        // User must explicitly click Save Draft or Submit Application
    }
    
    handleDocumentUpload() {
        this.showDocumentUpload = true;
        // Document upload logic would go here
    }
}