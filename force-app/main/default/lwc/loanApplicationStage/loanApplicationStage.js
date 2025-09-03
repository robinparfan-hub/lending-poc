import { LightningElement, api, track } from 'lwc';

export default class LoanApplicationStage extends LightningElement {
    @api applicationData = {};
    @api currentStage = 'draft';
    @api isExternalUser = false;
    @api isReadOnly = false;
    
    @track localApplicationData = {};
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
        this.localApplicationData = { ...this.applicationData };
    }
    
    @api
    get applicationDataForSave() {
        return this.localApplicationData;
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
        const field = event.target.dataset.field;
        
        if (!this.localApplicationData.Applicant_Profile__r) {
            this.localApplicationData.Applicant_Profile__r = {};
        }
        
        if (field === 'Total_Income__c') {
            this.localApplicationData.Applicant_Profile__r[field] = parseFloat(event.target.value);
        } else {
            this.localApplicationData.Applicant_Profile__r[field] = event.target.value;
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
    
    handleSubmit() {
        this.dispatchEvent(new CustomEvent('stagechange', {
            detail: {
                eventType: 'submit',
                data: this.localApplicationData
            }
        }));
    }
    
    notifyChange(eventType) {
        // Debounce auto-save
        clearTimeout(this.saveTimeout);
        this.saveTimeout = setTimeout(() => {
            if (eventType === 'fieldChange' && !this.isReadOnly) {
                this.handleSave();
            }
        }, 2000); // Auto-save after 2 seconds of inactivity
    }
    
    handleDocumentUpload() {
        this.showDocumentUpload = true;
        // Document upload logic would go here
    }
}