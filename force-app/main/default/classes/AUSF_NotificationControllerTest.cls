@isTest
public class AUSF_NotificationControllerTest {
    
    @testSetup
    static void createdata(){
        
        // create notification master
        list<Notification_Master__mdt> lstNM = new list<Notification_Master__mdt>();
        Notification_Master__mdt NM1 = new Notification_Master__mdt(Chatter_Notification__c='Yes',Label='TestNM1',Push_Notification__c='Yes',Whatsapp__c='Yes',Trigger_Point__c='Yes',Mail__c='Yes'); 
        //insert NM1;
            // create notification content
            // create loan application
            // create applicant
            
            }
    
    
}