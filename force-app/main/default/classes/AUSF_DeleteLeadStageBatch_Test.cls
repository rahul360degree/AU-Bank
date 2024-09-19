@isTest
public class AUSF_DeleteLeadStageBatch_Test {
    @testSetup
    static void setup() {
        // Create test data - Lead_Stage__c records created today
        List<Lead_Stage__c> leadStages = new List<Lead_Stage__c>();
        AUSF_TestDataFactory.createLeadStagerecords(leadStages,10);
        insert leadStages;
    }
    
    @isTest
    static void testBatchable() {
        // Test the batchable functionality
        Test.startTest();
        AUSF_DeleteLeadStageBatch batch = new AUSF_DeleteLeadStageBatch();
        Database.executeBatch(batch);
        Test.stopTest();
        
        // Verify that the records created today are deleted
        List<Lead_Stage__c> leadStages = [SELECT Id FROM Lead_Stage__c WHERE CreatedDate = TODAY];
        System.assertEquals(0, leadStages.size(), 'All Lead_Stage__c records created today should be deleted.');
    }
    
    @isTest
    static void testSchedulable() {
        // Test the schedulable functionality
        Test.startTest();
        String cronExp = '0 0 0 * * ?';
        AUSF_DeleteLeadStageBatch schedulableBatch = new AUSF_DeleteLeadStageBatch();
        System.schedule('Test Daily Delete Lead Stage Batch', cronExp, schedulableBatch);
        Test.stopTest();
        
        // Verify that the scheduled job is created
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
                          FROM CronTrigger WHERE CronExpression = :cronExp];
        System.assertNotEquals(null, ct, 'Scheduled job should be created.');
    }
}