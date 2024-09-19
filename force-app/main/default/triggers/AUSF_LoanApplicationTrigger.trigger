trigger AUSF_LoanApplicationTrigger on Loan_Application__c (before insert, after insert, before update, after update) {
    new AUSF_LoanApplicationTriggerHandler().run('Loan_Application__c', 'Loan_Application__c');
}