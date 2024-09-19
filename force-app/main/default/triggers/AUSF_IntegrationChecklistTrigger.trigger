trigger AUSF_IntegrationChecklistTrigger on Integration_Checklist__c (before insert, after insert, before update, after update) {
    new AUSF_IntegrationChecklistTriggerHandler().run('Integration_Checklist__c', 'Integration_Checklist__c');
}