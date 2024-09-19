trigger AUSF_DocumentChecklistTrigger on Document_Checklist__c (before insert, after insert, before update, after update) {
    new AUSF_DocumentChecklistTriggerHandler().run('Integration_Checklist__c', 'Integration_Checklist__c');
}