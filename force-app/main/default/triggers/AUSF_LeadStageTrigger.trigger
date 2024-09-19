trigger AUSF_LeadStageTrigger on Lead_Stage__c (before insert, after insert, before update, after update) {
    new AUSF_LeadStageTriggerHandler().run('Lead_Stage__c', 'Lead_Stage__c');
}