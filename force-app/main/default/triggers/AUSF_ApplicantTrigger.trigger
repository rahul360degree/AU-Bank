trigger AUSF_ApplicantTrigger on Applicant__c (before insert, after insert, before update, after update) {
    new AUSF_ApplicantTriggerHandler().run('Applicant__c', 'Applicant__c');
}