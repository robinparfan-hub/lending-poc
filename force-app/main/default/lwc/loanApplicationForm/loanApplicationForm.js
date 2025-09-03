import { LightningElement, api, track, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import getApplicationData from '@salesforce/apex/LoanApplicationController.getApplicationData';
import saveApplication from '@salesforce/apex/LoanApplicationController.saveApplication';

const FIELDS = [
    'Loan_Application__c.Amount_Requested__c',
    'Loan_Application__c.Purpose__c',
    'Loan_Application__c.Term_Months__c',
    'Loan_Application__c.Status__c'
];

export default class LoanApplicationForm extends NavigationMixin(LightningElement) {
    @api recordId;
    @track isLoading = false;
    @track errorMessage = '';
    @track successMessage = '';
    
    // Applicant data
    @track applicantName = '';
    @track applicantEmail = '';
    @track applicantPhone = '';
    @track applicantIncome = 0;
    @track applicantEmployment = '';
    @track applicantDOB = '';
    
    objectApiName = 'Loan_Application__c';
    
    employmentOptions = [
        { label: 'Employed', value: 'Employed' },
        { label: 'Self-Employed', value: 'Self-Employed' },
        { label: 'Unemployed', value: 'Unemployed' },
        { label: 'Retired', value: 'Retired' },
        { label: 'Student', value: 'Student' }
    ];

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredRecord({ error, data }) {
        if (data) {
            // Record loaded successfully
            this.loadApplicantData();
        } else if (error) {
            this.showError('Error loading application: ' + error.body?.message);
        }
    }

    connectedCallback() {
        if (this.recordId) {
            this.loadApplicantData();
        }
    }

    loadApplicantData() {
        if (!this.recordId) return;
        
        this.isLoading = true;
        getApplicationData({ applicationId: this.recordId })
            .then(result => {
                if (result.hasAccess && result.application) {
                    const app = result.application;
                    const applicant = app.Applicant_Profile__r;
                    
                    if (applicant) {
                        this.applicantName = applicant.Name || '';
                        this.applicantEmail = applicant.Email__c || '';
                        this.applicantPhone = applicant.Phone__c || '';
                        this.applicantIncome = applicant.Total_Income__c || 0;
                        this.applicantEmployment = applicant.Employment_Status__c || '';
                    }
                }
                this.isLoading = false;
            })
            .catch(error => {
                this.showError('Error loading applicant data: ' + error.body?.message);
                this.isLoading = false;
            });
    }

    handleApplicantFieldChange(event) {
        const field = event.target.dataset.field;
        const value = event.target.value;
        
        switch(field) {
            case 'Name':
                this.applicantName = value;
                break;
            case 'Email__c':
                this.applicantEmail = value;
                break;
            case 'Phone__c':
                this.applicantPhone = value;
                break;
            case 'Total_Income__c':
                this.applicantIncome = value;
                break;
            case 'Employment_Status__c':
                this.applicantEmployment = value;
                break;
            case 'Date_of_Birth__c':
                this.applicantDOB = value;
                break;
        }
    }

    handleSubmit(event) {
        event.preventDefault();
        this.submitApplication('Submitted');
    }

    handleSaveDraft() {
        this.submitApplication('Draft');
    }

    submitApplication(status) {
        this.clearMessages();
        this.isLoading = true;

        const fields = event.detail?.fields || this.getFieldsFromForm();
        
        const applicationData = {
            Id: this.recordId,
            Amount_Requested__c: fields.Amount_Requested__c,
            Purpose__c: fields.Purpose__c,
            Term_Months__c: fields.Term_Months__c,
            Status__c: status,
            applicant: {
                Name: this.applicantName,
                Email__c: this.applicantEmail,
                Phone__c: this.applicantPhone,
                Total_Income__c: this.applicantIncome,
                Employment_Status__c: this.applicantEmployment,
                Date_of_Birth__c: this.applicantDOB
            }
        };

        saveApplication({ applicationData: applicationData })
            .then(result => {
                if (status === 'Submitted') {
                    this.showSuccess('Application submitted successfully!');
                    // Navigate to the application record
                    this[NavigationMixin.Navigate]({
                        type: 'standard__recordPage',
                        attributes: {
                            recordId: result,
                            objectApiName: 'Loan_Application__c',
                            actionName: 'view'
                        }
                    });
                } else {
                    this.showSuccess('Draft saved successfully!');
                    if (!this.recordId) {
                        this.recordId = result;
                    }
                }
                this.isLoading = false;
            })
            .catch(error => {
                this.showError('Error saving application: ' + error.body?.message);
                this.isLoading = false;
            });
    }

    getFieldsFromForm() {
        const inputFields = this.template.querySelectorAll('lightning-input-field');
        const fields = {};
        
        if (inputFields) {
            inputFields.forEach(field => {
                fields[field.fieldName] = field.value;
            });
        }
        
        return fields;
    }

    handleSuccess(event) {
        const evt = new ShowToastEvent({
            title: 'Success',
            message: 'Application saved successfully!',
            variant: 'success'
        });
        this.dispatchEvent(evt);
        
        // Refresh the component data
        this.loadApplicantData();
    }

    handleError(event) {
        this.showError('Error: ' + event.detail?.detail || 'Unknown error occurred');
    }

    showSuccess(message) {
        this.clearMessages();
        this.successMessage = message;
        
        const evt = new ShowToastEvent({
            title: 'Success',
            message: message,
            variant: 'success'
        });
        this.dispatchEvent(evt);
    }

    showError(message) {
        this.clearMessages();
        this.errorMessage = message;
        
        const evt = new ShowToastEvent({
            title: 'Error',
            message: message,
            variant: 'error'
        });
        this.dispatchEvent(evt);
    }

    clearMessages() {
        this.errorMessage = '';
        this.successMessage = '';
    }
}