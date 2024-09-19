@isTest
    public class AUSF_LeadStageTriggerService_Test {
    @testSetup
    static void setupTestData() {
            // Create test data for Loan Application
            List<Lead_Stage__c> leadStages = new List<Lead_Stage__c>();
            leadStages = AUSF_TestDataFactory.createLeadStagerecords(leadStages,1);
        	insert leadStages;
        }
    
    @isTest
    static void testPopulateSourcingChannelAndName() {
        // Retrieve the test data
        List<Lead_Stage__c> leadStages = [SELECT Id, Sourcing_Channel__c, Sourcing_Channel_Name__c FROM Lead_Stage__c];
        
        // Mock the current user's profile
        Test.startTest();
        new AUSF_LeadStageTriggerService().populateSourcingChannelAndName(leadStages);
        Test.stopTest();
        List<Lead_Stage__c> leadStagesExp = [SELECT Id, Sourcing_Channel__c, Sourcing_Channel_Name__c FROM Lead_Stage__c];
        // Verify the results
        for (Lead_Stage__c leadStage : leadStagesExp) {
            System.assertEquals(leadStage.Sourcing_Channel__c, 'DSA', 'Sourcing Channel should be updated to DSA Profile');
        }
    }
}