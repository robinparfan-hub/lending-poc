import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import getApplicationData from '@salesforce/apex/LoanApplicationController.getApplicationData';
import acceptLoanOffer from '@salesforce/apex/LoanApplicationController.acceptLoanOffer';
import declineLoanOffer from '@salesforce/apex/LoanApplicationController.declineLoanOffer';
import getApplicationIdByEmail from '@salesforce/apex/LoanApplicationController.getApplicationIdByEmail';

export default class LoanApplicationStatus extends LightningElement {
    @api recordId;
    @track applicationData;
    @track isLoading = false;
    @track errorMessage = '';
    
    // Modal properties
    @track showModal = false;
    @track isAcceptModal = false;
    @track isDeclineModal = false;
    @track digitalSignature = '';
    @track declineReason = '';
    
    // Email lookup properties
    @track showEmailLookup = false;
    @track lookupEmail = '';
    @track isLookingUp = false;
    
    wiredApplicationData;
    
    connectedCallback() {
        // Check if we have a recordId from URL parameters
        const urlParams = new URLSearchParams(window.location.search);
        const urlRecordId = urlParams.get('recordId') || urlParams.get('id');
        
        if (urlRecordId) {
            this.recordId = urlRecordId;
        } else if (!this.recordId) {
            // No record ID available, show email lookup
            this.showEmailLookup = true;
        }
    }

    @wire(getApplicationData, { applicationId: '$recordId' })
    wiredApplication(result) {
        this.wiredApplicationData = result;
        
        if (result.data) {
            if (result.data.hasAccess) {
                this.applicationData = result.data.application;
                this.errorMessage = '';
            } else {
                this.errorMessage = result.data.error || 'Access denied';
                this.applicationData = null;
            }
        } else if (result.error) {
            this.errorMessage = 'Error loading application: ' + result.error.body?.message;
            this.applicationData = null;
        }
    }

    get currentStep() {
        if (!this.applicationData) return 'draft';
        
        const status = this.applicationData.Status__c;
        switch(status) {
            case 'Draft': return 'draft';
            case 'Submitted': return 'submitted';
            case 'Under Review': return 'review';
            case 'Pending Documentation': return 'review';
            case 'Approved': return 'decision';
            case 'Declined': return 'decision';
            case 'Funded': return 'final';
            case 'Cancelled': return 'final';
            default: return 'draft';
        }
    }

    get statusVariant() {
        if (!this.applicationData) return 'slds-theme_default';
        
        const status = this.applicationData.Status__c;
        switch(status) {
            case 'Approved': return 'success';
            case 'Funded': return 'success';
            case 'Declined': return 'error';
            case 'Cancelled': return 'error';
            case 'Submitted': return 'warning';
            case 'Under Review': return 'warning';
            case 'Pending Documentation': return 'warning';
            default: return 'inverse';
        }
    }

    get showApprovedDetails() {
        return this.applicationData && 
               this.applicationData.Status__c === 'Approved' && 
               this.applicationData.Approved_Amount__c;
    }

    get showDeclinedDetails() {
        return this.applicationData && 
               this.applicationData.Status__c === 'Declined';
    }

    get showOfferActions() {
        return this.showApprovedDetails && 
               this.applicationData.Status__c !== 'Funded' && 
               this.applicationData.Status__c !== 'Cancelled';
    }

    get modalTitle() {
        return this.isAcceptModal ? 'Accept Loan Offer' : 'Decline Loan Offer';
    }

    get confirmButtonLabel() {
        return this.isAcceptModal ? 'Accept Loan' : 'Decline Offer';
    }

    get confirmButtonVariant() {
        return this.isAcceptModal ? 'brand' : 'destructive';
    }

    get confirmDisabled() {
        return this.isAcceptModal && !this.digitalSignature.trim();
    }

    handleAcceptOffer() {
        this.isAcceptModal = true;
        this.isDeclineModal = false;
        this.digitalSignature = '';
        this.showModal = true;
    }

    handleDeclineOffer() {
        this.isAcceptModal = false;
        this.isDeclineModal = true;
        this.declineReason = '';
        this.showModal = true;
    }

    handleSignatureChange(event) {
        this.digitalSignature = event.target.value;
    }

    handleDeclineReasonChange(event) {
        this.declineReason = event.target.value;
    }

    closeModal() {
        this.showModal = false;
        this.isAcceptModal = false;
        this.isDeclineModal = false;
        this.digitalSignature = '';
        this.declineReason = '';
    }

    confirmAction() {
        if (this.isAcceptModal) {
            this.processAcceptOffer();
        } else if (this.isDeclineModal) {
            this.processDeclineOffer();
        }
    }

    processAcceptOffer() {
        if (!this.digitalSignature.trim()) {
            this.showToast('Error', 'Digital signature is required', 'error');
            return;
        }

        this.isLoading = true;
        acceptLoanOffer({ 
            applicationId: this.recordId, 
            signature: this.digitalSignature 
        })
        .then(result => {
            if (result.success) {
                this.showToast('Success', result.message, 'success');
                this.closeModal();
                // Refresh the application data
                return refreshApex(this.wiredApplicationData);
            } else {
                this.showToast('Error', result.message || 'Failed to accept offer', 'error');
            }
        })
        .catch(error => {
            this.showToast('Error', 'Error accepting offer: ' + error.body?.message, 'error');
        })
        .finally(() => {
            this.isLoading = false;
        });
    }

    processDeclineOffer() {
        this.isLoading = true;
        declineLoanOffer({ 
            applicationId: this.recordId, 
            reason: this.declineReason || 'No reason provided' 
        })
        .then(result => {
            if (result.success) {
                this.showToast('Success', result.message, 'success');
                this.closeModal();
                // Refresh the application data
                return refreshApex(this.wiredApplicationData);
            } else {
                this.showToast('Error', result.message || 'Failed to decline offer', 'error');
            }
        })
        .catch(error => {
            this.showToast('Error', 'Error declining offer: ' + error.body?.message, 'error');
        })
        .finally(() => {
            this.isLoading = false;
        });
    }

    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(evt);
    }
    
    // Email lookup methods
    handleEmailChange(event) {
        this.lookupEmail = event.target.value;
    }
    
    handleEmailLookup() {
        if (!this.lookupEmail || !this.lookupEmail.includes('@')) {
            this.showToast('Error', 'Please enter a valid email address', 'error');
            return;
        }
        
        this.isLookingUp = true;
        this.errorMessage = '';
        
        getApplicationIdByEmail({ email: this.lookupEmail })
            .then(applicationId => {
                if (applicationId) {
                    this.recordId = applicationId;
                    this.showEmailLookup = false;
                    // Refresh the wired data with new record ID
                    return refreshApex(this.wiredApplicationData);
                } else {
                    this.errorMessage = 'No application found for this email address';
                }
            })
            .catch(error => {
                this.errorMessage = error.body?.message || 'Error looking up application';
            })
            .finally(() => {
                this.isLookingUp = false;
            });
    }
}