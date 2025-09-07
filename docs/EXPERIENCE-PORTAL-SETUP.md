# Experience Portal Setup Guide

## Overview
This guide covers setting up the Experience Portal for loan applicants to view their application status and accept/decline loan offers.

## Components Ready for Deployment

### 1. loanApplicationStatus
- **Purpose**: Displays current loan application status with progress indicator
- **Features**:
  - Email-based application lookup for guest users
  - Visual progress indicator showing application stages
  - Displays approved loan details (amount, rate, monthly payment)
  - Shows decline reasons if application was rejected

### 2. loanOfferAcceptance  
- **Purpose**: Allows applicants to accept or decline loan offers
- **Features**:
  - Email-based lookup for finding applications
  - Digital signature capture for acceptance
  - Terms and conditions checkbox
  - Customer feedback collection (1-5 star rating + comments)
  - Decline reason capture

## Setup Steps

### 1. Create Experience Site
1. Go to Setup → Digital Experiences → All Sites
2. Click "New" 
3. Select "Build Your Own (LWR)" template
4. Name: "Loan Application Portal"
5. URL: `/loans`

### 2. Add Components to Pages

#### Application Status Page
1. Create new page: "Check Application Status"
2. Add `loanApplicationStatus` component
3. URL: `/loans/status`

#### Loan Offer Page
1. Create new page: "Review Loan Offer"  
2. Add `loanOfferAcceptance` component
3. URL: `/loans/offer`

### 3. Configure Guest User Permissions

#### Object Permissions
```
Loan_Application__c:
- Read: ✓
- Fields visible:
  - Name
  - Status__c
  - Amount_Requested__c
  - Application_Date__c
  - Approved_Amount__c (if approved)
  - Interest_Rate__c (if approved)
  - Monthly_Payment__c (if approved)
  - Term_Months__c
  - Reason_Codes__c (if declined)

Applicant_Profile__c:
- Read: ✓
- Fields visible:
  - Name
  - Email__c
  - Phone__c

Decision__c:
- Read: ✓
- Fields visible:
  - Decision_Type__c
  - Approved_Amount__c
  - Interest_Rate__c
  - Monthly_Payment__c
```

#### Apex Class Access
- `LoanApplicationController`: ✓

### 4. Create Sharing Rules

#### Loan Application Sharing Rule
```
Rule Name: Share_Applications_With_Guest_Users
Criteria: Status__c != 'Draft'
Share With: Guest User
Access Level: Read Only
```

### 5. URL Parameters Support

Both components support URL parameters for direct access:

#### Direct Link with Application ID
```
https://[your-domain]/loans/status?recordId=[applicationId]
https://[your-domain]/loans/offer?recordId=[applicationId]
```

#### Email-Based Lookup
If no recordId parameter is provided, users will see an email lookup form.

## Customer Feedback Collection

### Fields Created
- `Customer_Feedback__c`: Long text area for comments
- `Customer_Rating__c`: Number field (1-5 stars)
- `Feedback_Date__c`: DateTime of feedback submission

### Feedback Flow
1. After accepting/declining offer, feedback modal appears
2. User rates experience (1-5 stars) - required
3. User can add optional comments
4. Feedback stored on Loan_Application__c record

## Security Considerations

### Data Access
- Components use `WITH SECURITY_ENFORCED` in SOQL queries
- Email lookup validates against existing applications
- No sensitive financial data exposed to unauthenticated users

### Best Practices
1. Enable reCAPTCHA on public forms
2. Set up rate limiting for email lookups
3. Monitor guest user activity logs
4. Consider requiring authentication for offer acceptance

## Testing Scenarios

### Test Case 1: Email Lookup
1. Navigate to `/loans/status` without parameters
2. Enter applicant email
3. Verify correct application loads

### Test Case 2: Direct Link Access
1. Share link with `?recordId=[id]` parameter
2. Verify application loads immediately
3. Test with invalid ID (should show error)

### Test Case 3: Offer Acceptance
1. Load approved application
2. Enter digital signature
3. Check terms checkbox
4. Accept offer
5. Verify feedback modal appears
6. Submit rating and comments

### Test Case 4: Offer Decline
1. Load approved application
2. Click decline
3. Enter decline reason
4. Verify status updates to Cancelled
5. Verify feedback modal appears

## Email Templates (Optional)

Consider creating email templates with direct links:

```html
Subject: Your Loan Application Status

Dear [Applicant Name],

Check your loan application status:
https://[your-domain]/loans/status?recordId=[applicationId]

If you have been approved, review your offer:
https://[your-domain]/loans/offer?recordId=[applicationId]
```

## Monitoring & Analytics

### Track Key Metrics
- Application view counts
- Offer acceptance rate
- Average customer rating
- Common decline reasons
- Time to decision

### Reports to Create
1. Customer Feedback Summary
2. Offer Acceptance Rate by Month
3. Average Rating by Loan Officer
4. Decline Reason Analysis

## Troubleshooting

### Common Issues

#### "Access Denied" Error
- Check guest user permissions
- Verify sharing rules are active
- Ensure Apex class access is granted

#### "No Application Found"
- Verify email matches Applicant_Profile__c.Email__c
- Check application status (excluded: Cancelled, Declined)
- Confirm sharing rule criteria

#### Feedback Not Saving
- Check field-level security for feedback fields
- Verify guest user has edit access to feedback fields only

## Next Steps

1. Customize site branding and theme
2. Add home page with application status lookup
3. Create help/FAQ page
4. Set up Google Analytics
5. Configure custom domain
6. Enable SSL certificate
7. Test on mobile devices
8. Create user documentation

## Support Contact

For portal issues, contact:
- Technical Support: [your-email]
- Application Questions: [loan-team-email]