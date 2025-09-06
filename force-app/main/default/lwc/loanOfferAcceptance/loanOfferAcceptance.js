import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import getApplicationData from '@salesforce/apex/LoanApplicationController.getApplicationData';
import acceptLoanOffer from '@salesforce/apex/LoanApplicationController.acceptLoanOffer';
import declineLoanOffer from '@salesforce/apex/LoanApplicationController.declineLoanOffer';

export default class LoanOfferAcceptance extends LightningElement {
    @api recordId;
    @api applicationId; // Alias for recordId  
    @api approvedAmount;
    @api interestRate;
    @api termMonths;
    @api monthlyPayment;
    @track isLoading = false;
    @track errorMessage = '';
    @track successMessage = '';
    @track offerData = {};
    @track digitalSignature = '';
    @track termsAccepted = false;
    @track declineReason = '';
    @track showDeclineModal = false;
    
    wiredApplicationData;

    connectedCallback() {
        // Use passed attributes if available
        this.buildOfferDataFromAttributes();
    }

    buildOfferDataFromAttributes() {
        const appId = this.applicationId || this.recordId;
        console.log('buildOfferDataFromAttributes called:', {
            recordId: this.recordId,
            applicationId: this.applicationId,
            approvedAmount: this.approvedAmount,
            interestRate: this.interestRate,
            termMonths: this.termMonths,
            monthlyPayment: this.monthlyPayment
        });

        if (this.approvedAmount && this.approvedAmount > 0) {
            this.offerData = {
                approvedAmount: this.approvedAmount,
                interestRate: this.interestRate,
                termMonths: this.termMonths || 60,
                monthlyPayment: this.monthlyPayment,
                decisionDate: new Date().toISOString(), // Current date as fallback
                expirationDate: this.calculateExpirationDate(new Date().toISOString())
            };
            console.log('Offer data built from attributes:', this.offerData);
        }
    }

    get wireApplicationId() {
        return this.applicationId || this.recordId;
    }

    @wire(getApplicationData, { applicationId: '$wireApplicationId' })
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
            this.errorMessage = 'Error loading application: ' + (result.error.body && result.error.body.message ? result.error.body.message : result.error.message || 'Unknown error');
            this.offerData = {};
        }
    }

    processApplicationData(application) {
        // Check if this is an approved application with offer data
        // The approval data comes from the controller which adds these fields from the Decision__c record
        console.log('LoanOfferAcceptance processApplicationData:', {
            status: application.Status__c,
            approvedAmount: application.Approved_Amount__c,
            interestRate: application.Interest_Rate__c,
            monthlyPayment: application.Monthly_Payment__c,
            fullApplication: application
        });
        
        if ((application.Status__c === 'Approved' || application.Status__c === 'Funded') && application.Approved_Amount__c) {
            this.offerData = {
                approvedAmount: application.Approved_Amount__c,
                interestRate: application.Interest_Rate__c, // Already in percentage format from controller
                termMonths: application.Term_Months__c || 60, // Use application term or default to 60
                monthlyPayment: application.Monthly_Payment__c,
                decisionDate: application.Decision_Date__c,
                expirationDate: this.calculateExpirationDate(application.Decision_Date__c)
            };
            console.log('LoanOfferAcceptance offerData created:', this.offerData);
        } else {
            this.offerData = {};
            console.log('LoanOfferAcceptance no offer data - Status:', application.Status__c, 'Amount:', application.Approved_Amount__c);
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
            applicationId: this.applicationId || this.recordId, 
            signature: this.digitalSignature 
        })
        .then(result => {
            if (result.success) {
                this.showSuccess(result.message || 'Loan offer accepted successfully!');
                
                // Dispatch event to parent wizard
                const acceptedEvent = new CustomEvent('offeraccepted', {
                    detail: {
                        applicationId: this.applicationId || this.recordId,
                        status: 'Funded'
                    }
                });
                this.dispatchEvent(acceptedEvent);
                
                // Refresh the application data
                return refreshApex(this.wiredApplicationData);
            } else {
                this.showError(result.message || 'Failed to accept offer');
            }
        })
        .catch(error => {
            this.showError('Error accepting offer: ' + (error.body && error.body.message ? error.body.message : error.message || 'Unknown error'));
        })
        .finally(() => {
            this.isLoading = false;
        });
    }

    processDeclineOffer() {
        this.clearMessages();
        this.isLoading = true;

        declineLoanOffer({ 
            applicationId: this.applicationId || this.recordId, 
            reason: this.declineReason || 'No reason provided' 
        })
        .then(result => {
            if (result.success) {
                this.showSuccess(result.message || 'Loan offer declined');
                
                // Dispatch event to parent wizard
                const declinedEvent = new CustomEvent('offerdeclined', {
                    detail: {
                        applicationId: this.applicationId || this.recordId,
                        status: 'Cancelled'
                    }
                });
                this.dispatchEvent(declinedEvent);
                
                // Refresh the application data
                return refreshApex(this.wiredApplicationData);
            } else {
                this.showError(result.message || 'Failed to decline offer');
            }
        })
        .catch(error => {
            this.showError('Error declining offer: ' + (error.body && error.body.message ? error.body.message : error.message || 'Unknown error'));
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