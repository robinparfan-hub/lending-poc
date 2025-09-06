import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { publish, MessageContext } from 'lightning/messageService';
import LOAN_APP_CHANNEL from '@salesforce/messageChannel/LoanApplicationUpdates__c';
import getApplicationData from '@salesforce/apex/LoanApplicationController.getApplicationData';
import saveApplication from '@salesforce/apex/LoanApplicationController.saveApplication';

export default class LoanApplicationWizard extends LightningElement {
    @api recordId; // Application ID if editing existing
    @api isExternalUser = false; // Set to true for Experience Cloud
    
    @track applicationData = {};
    @track currentStage = 'draft';
    @track isLoading = false;
    @track error = null;
    @track hasAccess = true;
    
    @wire(MessageContext)
    messageContext;
    
    // Stage definitions
    stages = [
        { value: 'draft', label: 'Application', status: 'Draft' },
        { value: 'submitted', label: 'Review', status: 'Submitted' },
        { value: 'underwriting', label: 'Underwriting', status: 'In Underwriting' },
        { value: 'decision', label: 'Decision', status: 'Approved,Declined' },
        { value: 'funded', label: 'Funded', status: 'Funded' }
    ];
    
    // Computed properties
    get progressPercent() {
        const stageIndex = this.stages.findIndex(s => s.value === this.currentStage);
        return ((stageIndex + 1) / this.stages.length) * 100;
    }
    
    get isReadOnly() {
        return this.currentStage !== 'draft' || !this.hasAccess;
    }
    
    get showAcceptanceComponent() {
        return this.applicationData.Status__c === 'Approved' && 
               this.applicationData.Approved_Amount__c != null;
    }
    
    get progressBarStyle() {
        return `width: ${this.progressPercent}%`;
    }
    
    get stagesWithClasses() {
        return this.stages.map(stage => {
            const isCurrent = stage.value === this.currentStage;
            const currentIndex = this.stages.findIndex(s => s.value === this.currentStage);
            const stageIndex = this.stages.findIndex(s => s.value === stage.value);
            const isComplete = stageIndex < currentIndex;
            
            return {
                ...stage,
                class: `slds-path__item ${isCurrent ? 'slds-is-current' : isComplete ? 'slds-is-complete' : 'slds-is-incomplete'}`,
                iconName: isComplete ? 'utility:success' : isCurrent ? 'utility:chevronright' : 'utility:clock'
            };
        });
    }
    
    // Lifecycle hooks
    connectedCallback() {
        this.detectUserContext();
        this.loadApplication();
    }
    
    // Methods
    detectUserContext() {
        // Check if running in Experience Cloud
        const path = window.location.pathname;
        const hostname = window.location.hostname;
        this.isExternalUser = path.includes('/s/') || hostname.includes('.force.com');
    }
    
    loadApplication() {
        this.isLoading = true;
        this.error = null;
        
        getApplicationData({ applicationId: this.recordId })
            .then(result => {
                this.hasAccess = result.hasAccess;
                
                if (!result.hasAccess) {
                    this.error = result.error || 'Access denied';
                    return;
                }
                
                if (result.application) {
                    this.applicationData = result.application;
                    this.determineCurrentStage();
                } else {
                    // New application
                    this.initializeNewApplication();
                }
                
                this.isExternalUser = result.isExternalUser;
            })
            .catch(error => {
                this.error = error.body?.message || 'Error loading application';
                console.error('Error loading application:', error);
            })
            .finally(() => {
                this.isLoading = false;
            });
    }
    
    initializeNewApplication() {
        this.applicationData = {
            Status__c: 'Draft',
            Amount_Requested__c: null,
            Purpose__c: null,
            Term_Months__c: 60,
            Application_Date__c: new Date().toISOString().split('T')[0],
            Applicant_Profile__r: {
                Name: '',
                Email__c: '',
                Phone__c: ''
            }
        };
        this.currentStage = 'draft';
    }
    
    determineCurrentStage() {
        const status = this.applicationData.Status__c;
        
        switch(status) {
            case 'Draft':
                this.currentStage = 'draft';
                break;
            case 'Submitted':
            case 'Under Review':
            case 'Pending Documentation':
                this.currentStage = 'submitted';
                break;
            case 'In Underwriting':
                this.currentStage = 'underwriting';
                break;
            case 'Approved':
            case 'Declined':
                this.currentStage = 'decision';
                break;
            case 'Funded':
            case 'Cancelled':
                this.currentStage = 'funded';
                break;
            default:
                this.currentStage = 'draft';
        }
    }
    
    handleStageChange(event) {
        console.log('handleStageChange called with event:', event.detail);
        const { applicationId, status, eventType, data } = event.detail;
        
        if (eventType === 'save') {
            console.log('Saving application data');
            this.saveApplicationData(data);
        } else if (eventType === 'submit') {
            console.log('Submitting application with data:', data);
            // Update application data before submission
            if (data) {
                this.applicationData = {
                    ...this.applicationData,
                    ...data
                };
            }
            this.submitApplication(this.applicationData);
        } else if (eventType === 'statusChange') {
            this.applicationData.Status__c = status;
            this.determineCurrentStage();
            this.publishUpdate('statusChange');
        }
    }
    
    saveApplicationData(updatedData) {
        this.isLoading = true;
        this.error = null;
        
        // Merge updated data first
        const mergedData = {
            ...this.applicationData,
            ...updatedData
        };
        
        // Transform data for Apex - ensure proper structure
        const dataToSave = {
            Id: mergedData.Id || null,
            Amount_Requested__c: mergedData.Amount_Requested__c,
            Purpose__c: mergedData.Purpose__c,
            Term_Months__c: mergedData.Term_Months__c,
            Status__c: mergedData.Status__c || 'Draft',
            applicant: mergedData.Applicant_Profile__r ? {
                Name: mergedData.Applicant_Profile__r.Name || '',
                Email__c: mergedData.Applicant_Profile__r.Email__c || '',
                Phone__c: mergedData.Applicant_Profile__r.Phone__c || '',
                Employment_Status__c: mergedData.Applicant_Profile__r.Employment_Status__c || '',
                Date_of_Birth__c: mergedData.Applicant_Profile__r.Date_of_Birth__c || null,
                Total_Income__c: mergedData.Applicant_Profile__r.Total_Income__c || null
            } : null
        };
        
        saveApplication({ applicationData: dataToSave })
            .then(applicationId => {
                this.recordId = applicationId;
                this.applicationData.Id = applicationId;
                
                this.showToast('Success', 'Application saved successfully', 'success');
                this.publishUpdate('save');
                
                // Reload to get updated data
                return this.loadApplication();
            })
            .catch(error => {
                this.error = error.body?.message || 'Error saving application';
                this.showToast('Error', this.error, 'error');
            })
            .finally(() => {
                this.isLoading = false;
            });
    }
    
    submitApplication(updatedData) {
        // Merge updated data if provided
        if (updatedData) {
            this.applicationData = {
                ...this.applicationData,
                ...updatedData
            };
        }
        
        // Validate before submission
        if (!this.validateApplication()) {
            return;
        }
        
        this.isLoading = true;
        
        // Transform data for Apex - ensure proper structure
        const dataToSave = {
            Id: this.applicationData.Id || null,
            Amount_Requested__c: this.applicationData.Amount_Requested__c,
            Purpose__c: this.applicationData.Purpose__c,
            Term_Months__c: this.applicationData.Term_Months__c,
            Status__c: 'Submitted',
            applicant: this.applicationData.Applicant_Profile__r ? {
                Name: this.applicationData.Applicant_Profile__r.Name || '',
                Email__c: this.applicationData.Applicant_Profile__r.Email__c || '',
                Phone__c: this.applicationData.Applicant_Profile__r.Phone__c || '',
                Employment_Status__c: this.applicationData.Applicant_Profile__r.Employment_Status__c || '',
                Date_of_Birth__c: this.applicationData.Applicant_Profile__r.Date_of_Birth__c || null,
                Total_Income__c: this.applicationData.Applicant_Profile__r.Total_Income__c || null
            } : null
        };
        
        saveApplication({ applicationData: dataToSave })
            .then(applicationId => {
                this.recordId = applicationId;
                this.applicationData.Id = applicationId;
                this.applicationData.Status__c = 'Submitted';
                
                this.showToast('Success', 'Application submitted for review', 'success');
                this.determineCurrentStage();
                this.publishUpdate('submit');
                
                // Trigger evaluation after short delay
                setTimeout(() => {
                    this.loadApplication();
                }, 3000);
            })
            .catch(error => {
                console.error('Error submitting application:', error);
                const errorMessage = error.body?.message || error.message || 'Error submitting application';
                this.error = errorMessage;
                this.showToast('Error', errorMessage, 'error');
            })
            .finally(() => {
                this.isLoading = false;
            });
    }
    
    validateApplication() {
        const errors = [];
        
        if (!this.applicationData.Amount_Requested__c) {
            errors.push('Loan amount is required');
        } else if (this.applicationData.Amount_Requested__c < 1000 || 
                   this.applicationData.Amount_Requested__c > 100000) {
            errors.push('Loan amount must be between $1,000 and $100,000');
        }
        
        if (!this.applicationData.Purpose__c) {
            errors.push('Loan purpose is required');
        }
        
        if (!this.applicationData.Term_Months__c) {
            errors.push('Loan term is required');
        }
        
        // Applicant validation
        const applicant = this.applicationData.Applicant_Profile__r || {};
        if (!applicant.Email__c) {
            errors.push('Email is required');
        }
        
        if (errors.length > 0) {
            this.showToast('Validation Error', errors.join(', '), 'error');
            return false;
        }
        
        return true;
    }
    
    publishUpdate(eventType) {
        const payload = {
            applicationId: this.recordId,
            status: this.applicationData.Status__c,
            eventType: eventType,
            data: JSON.stringify(this.applicationData)
        };
        
        publish(this.messageContext, LOAN_APP_CHANNEL, payload);
    }
    
    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(evt);
    }
    
    // Event handlers
    handleSaveDraft() {
        const stageComponent = this.template.querySelector('c-loan-application-stage');
        if (stageComponent) {
            const dataToSave = stageComponent.applicationDataForSave;
            this.saveApplicationData(dataToSave);
        }
    }
    
    handleSubmit() {
        console.log('handleSubmit called in wizard');
        this.showToast('Info', 'Submit button clicked - processing...', 'info');
        
        const stageComponent = this.template.querySelector('c-loan-application-stage');
        console.log('Stage component found:', stageComponent);
        if (stageComponent) {
            console.log('Calling handleSubmit on stage component');
            stageComponent.handleSubmit();
        } else {
            console.log('Stage component not found!');
            this.showToast('Warning', 'Unable to find application form component', 'warning');
            // Try to call submitApplication directly with current data
            this.submitApplication(this.applicationData);
        }
    }
    
    handleOfferAccepted(event) {
        this.applicationData.Status__c = 'Funded';
        this.determineCurrentStage();
        this.showToast('Success', 'Congratulations! Your loan has been funded.', 'success');
        this.publishUpdate('accept');
    }
    
    handleOfferDeclined(event) {
        this.applicationData.Status__c = 'Cancelled';
        this.determineCurrentStage();
        this.showToast('Info', 'Loan offer has been declined.', 'info');
        this.publishUpdate('decline');
    }
}