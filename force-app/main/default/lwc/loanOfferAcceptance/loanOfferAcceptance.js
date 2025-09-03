import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import getApplicationData from '@salesforce/apex/LoanApplicationController.getApplicationData';
import acceptLoanOffer from '@salesforce/apex/LoanApplicationController.acceptLoanOffer';
import declineLoanOffer from '@salesforce/apex/LoanApplicationController.declineLoanOffer';

export default class LoanOfferAcceptance extends LightningElement {
    @api recordId;
    @track isLoading = false;
    @track errorMessage = '';
    @track successMessage = '';
    @track offerData = {};
    @track digitalSignature = '';
    @track termsAccepted = false;
    @track declineReason = '';
    @track showDeclineModal = false;
    
    wiredApplicationData;

    @wire(getApplicationData, { applicationId: '$recordId' })
    wiredApplication(result) {
        this.wiredApplicationData = result;
        
        if (result.data) {
            if (result.data.hasAccess && result.data.application) {
                this.processApplicationData(result.data.application);
                this.errorMessage = '';
            } else {
                this.errorMessage = result.data.error || 'Access denied';
                this.offerData = {};
            }
        } else if (result.error) {
            this.errorMessage = 'Error loading application: ' + result.error.body?.message;
            this.offerData = {};
        }
    }

    processApplicationData(application) {
        // Check if this is an approved application with offer data
        if (application.Status__c === 'Approved' && application.Approved_Amount__c) {
            this.offerData = {
                approvedAmount: application.Approved_Amount__c,
                interestRate: application.Interest_Rate__c / 100, // Convert to decimal for percentage formatting
                termMonths: 60, // Default term - could come from application data
                monthlyPayment: application.Monthly_Payment__c,
                decisionDate: application.Decision_Date__c,
                expirationDate: this.calculateExpirationDate(application.Decision_Date__c)
            };
        } else {
            this.offerData = {};
        }
    }

    calculateExpirationDate(decisionDate) {
        if (!decisionDate) return null;
        
        // Add 30 days to decision date
        const date = new Date(decisionDate);
        date.setDate(date.getDate() + 30);
        return date.toISOString();
    }

    get hasOffer() {
        return this.offerData && this.offerData.approvedAmount > 0;
    }

    get acceptDisabled() {
        return this.isLoading || 
               !this.digitalSignature.trim() || 
               !this.termsAccepted;
    }

    handleSignatureChange(event) {
        this.digitalSignature = event.target.value;
    }

    handleTermsChange(event) {
        this.termsAccepted = event.target.checked;
    }

    handleAcceptOffer() {
        if (!this.digitalSignature.trim()) {
            this.showToast('Error', 'Digital signature is required', 'error');
            return;
        }

        if (!this.termsAccepted) {
            this.showToast('Error', 'Please accept the terms and conditions', 'error');
            return;
        }

        this.processAcceptOffer();
    }

    handleDeclineOffer() {
        this.showDeclineModal = true;
    }

    handleDeclineReasonChange(event) {
        this.declineReason = event.target.value;
    }

    closeDeclineModal() {
        this.showDeclineModal = false;
        this.declineReason = '';
    }

    confirmDecline() {
        this.processDeclineOffer();
        this.closeDeclineModal();
    }

    processAcceptOffer() {
        this.clearMessages();
        this.isLoading = true;

        acceptLoanOffer({ 
            applicationId: this.recordId, 
            signature: this.digitalSignature 
        })
        .then(result => {
            if (result.success) {
                this.showSuccess(result.message || 'Loan offer accepted successfully!');
                // Refresh the application data
                return refreshApex(this.wiredApplicationData);
            } else {
                this.showError(result.message || 'Failed to accept offer');
            }
        })
        .catch(error => {
            this.showError('Error accepting offer: ' + error.body?.message);
        })
        .finally(() => {
            this.isLoading = false;
        });
    }

    processDeclineOffer() {
        this.clearMessages();
        this.isLoading = true;

        declineLoanOffer({ 
            applicationId: this.recordId, 
            reason: this.declineReason || 'No reason provided' 
        })
        .then(result => {
            if (result.success) {
                this.showSuccess(result.message || 'Loan offer declined');
                // Refresh the application data
                return refreshApex(this.wiredApplicationData);
            } else {
                this.showError(result.message || 'Failed to decline offer');
            }
        })
        .catch(error => {
            this.showError('Error declining offer: ' + error.body?.message);
        })
        .finally(() => {
            this.isLoading = false;
        });
    }

    showSuccess(message) {
        this.clearMessages();
        this.successMessage = message;
        this.showToast('Success', message, 'success');
    }

    showError(message) {
        this.clearMessages();
        this.errorMessage = message;
        this.showToast('Error', message, 'error');
    }

    clearMessages() {
        this.errorMessage = '';
        this.successMessage = '';
    }

    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }
}