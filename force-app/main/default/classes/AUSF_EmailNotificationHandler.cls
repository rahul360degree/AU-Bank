/**
* @author        Tejendra
* @date          4-July-2024
* @description   Email Notification Handler class
* Modification Log:
--------------------------------------------------------------------------------------------
Developer             Date            Description
--------------------------------------------------------------------------------------------
Tejendra              4-July-2024    Initial Version - APL-244
*/
public without sharing class AUSF_EmailNotificationHandler {
    public AUSF_EmailNotificationHandler() {}
    /*
    @description    : sendEmailNotification - Generate Email notification service method
    @param1         : applicantId - Applicant Record Id
    @param2         : loanId - Loan Application Record Id
    @param3         : strTriggerPoint - Notification trigger point
    @return         : void
    */
    public static void sendEmailNotification(AUSF_NotificationController.LoanAppWrapper objWrapper){
        objWrapper = objWrapper == NULL ? new AUSF_NotificationController.LoanAppWrapper (null, null, null, null, null, null) : objWrapper;
        Applicant__c applicantObj = objWrapper.objApp;
        Loan_Application__c loanApplicationObj = objWrapper.objLoan;
        String  applicantId = objWrapper.applicantId;
        String loanId = objWrapper.loanApplicationId;
        String strTriggerPoint = objWrapper.strTriggerPoint;
        String toUserId = objWrapper.toUserId;
        try{
          if (applicantObj == NULL && applicantId != NULL) {
            List<Applicant__c> lstApplicant = getApplicant(applicantId);
            applicantObj = lstApplicant != NULL ? lstApplicant[0] : NULL;
            objWrapper.ObjApp = applicantObj;
            objWrapper.applicantId = applicantObj != NULL ? applicantObj.Id : NULL;
          }
          if (loanApplicationObj == NULL && loanId != NULL) {
            List<Loan_Application__c> lstApplication = getLoanDetais(loanId);
            loanApplicationObj = lstApplication != NULL ? lstApplication[0] : NULL;
            objWrapper.objLoan = loanApplicationObj;
            objWrapper.loanApplicationId = loanApplicationObj != NULL ? loanApplicationObj.Id : NULL;
          }
          List <Notification_Content__mdt> notificationList = getNotificationContent(strTriggerPoint);
          if (!notificationList.isEmpty()) {
            for (Notification_Content__mdt record: notificationList) {
                  String message = record.Email_Body__c;
                  String subject = record.Email_Subject__c;
                  message = AUSF_NotificationUtility.bindValues(objWrapper,message);
                  subject = AUSF_NotificationUtility.bindValues(objWrapper,subject);
                  DocumentWrapper documentWrapperObj;
                  String documentName = String.isNotBlank(record.Attached_Document_Name__c) ? record.Attached_Document_Name__c : '';
                  if(String.isNotBlank(documentName)){
                  String fileContent = '';
                  FileWrapper fileDetails;
                  if (String.isNotBlank(documentName) && (String.isNotBlank(loanApplicationObj.Id) || String.isNotBlank(applicantObj.Id))) {
                    fileDetails = getFileDetails(documentName, loanApplicationObj.Id, applicantObj.Id);
                    fileContent = fileDetails.baseData;
                  }
                  documentWrapperObj =  new DocumentWrapper();
                  documentWrapperObj.documentName = documentName;
                  documentWrapperObj.fileContent = fileContent;
                }
                  String toEmailId = '';
                  if (record.Notification_Internal_Or_External__c == 'External') {
                    toEmailId = applicantObj.Personal_email_ID__c;
                  }
                  else if (record.Notification_Internal_Or_External__c == 'Internal') {
                    toEmailId = toUserId;
                  }
                  Id JobId = System.enqueueJob(new AUSF_EmailNotificationQueueable(applicantObj,loanApplicationObj,message,subject,strTriggerPoint,toEmailId,documentWrapperObj));
            }
          }
    }catch (Exception ex) {
        AUSF_Log.error(ex, AUSF_Log.SeverityType.High,String.isNotBlank(applicantId) ? applicantId : loanId, String.isNotBlank(applicantId) ? 'Applicant' : 'Loan Application',AUSF_ApexConstants.AUSF_EMAIL_INTEGRATION_MASTER);
    }
  }

  /*
  @description : Method to get the File Details based on document name and loan application id from the document checklist
  @param1 : documentName
  @param2 : loanApplicationId - loan application recordId
  @param3 : applicantId - applicant recordId
  @return : FileWrapper 

  */
  public static FileWrapper getFileDetails(String documentName, String loanApplicationId, String applicantId) {
    FileWrapper wrapperInstance = new FileWrapper();
        if(String.isBlank(documentName)){
            return null;
        }
        List <Document_Checklist__c> documentList = [SELECT id, Loan_Application__c, Document_Master__r.Document_Name__c, Document_Name__c, (SELECT Id, ContentDocumentId, LinkedEntityId FROM ContentDocumentLinks ORDER BY SystemModstamp DESC LIMIT 1)
                                                      FROM Document_Checklist__c
                                                      WHERE (Loan_Application__c =: loanApplicationId OR Applicant__c =: applicantId) 
                                                      AND(Document_Name__c =: documentName OR Document_Master__r.Document_Name__c =: documentName)
                                                      ORDER BY CreatedDate DESC LIMIT 1
                                                      ];
        
        String contentDocumentId;
        String base64Data = '';
        if (documentList != null && documentList.size() > 0 && !documentList.isEmpty()) {
            if (!(documentList[0].ContentDocumentLinks).isEmpty()) {
                contentDocumentId = documentList[0].ContentDocumentLinks[0].ContentDocumentId;
            }
        }
        
        if (String.isNotBlank(contentDocumentId)) {
            ContentVersion cv = [SELECT VersionData
                                FROM ContentVersion
                                WHERE ContentDocumentId =: contentDocumentId
                                ORDER BY CreatedDate DESC LIMIT 1
                                ];
            
            base64Data = EncodingUtil.base64Encode(cv.VersionData);
            wrapperInstance.baseData = base64Data != null ? base64Data : '';
            
            if (String.isNotBlank(contentDocumentId)) {
                List<ContentDistribution> ContentDistributionList = [SELECT DistributionPublicUrl 
                                                                    FROM ContentDistribution
                                                                    WHERE ContentDocumentId = :contentDocumentId  ORDER BY CreatedDate DESC LIMIT 1];
                if(ContentDistributionList.size()>0){
                    wrapperInstance.publicURL = ContentDistributionList[0].DistributionPublicUrl != null ?  ContentDistributionList[0].DistributionPublicUrl : '';
                }
                
            }
            
        }
        return wrapperInstance;
  }

  /*
  @description : Method to Get Loan Details Based on LoanId
  @param       : loanApplicationId - Loan Application record id
  @return      : List < Loan_Application__c > 
  */
  public static List < Loan_Application__c > getLoanDetais(String loanApplicationId) {
          List < Loan_Application__c > loanList = [SELECT Id,Name FROM Loan_Application__c
                                                  WHERE Id =: loanApplicationId
                                                  ];
          return loanList;
  }

    /*
  @description : Method to Get applicant list based on applicantId
  @param       : applicantId - applicant record id
  @return      : List < Applicant__c >
  */
  public static List < Applicant__c > getApplicant(String applicantId) {
          List < Applicant__c > applicantList = [SELECT Id, Loan_Application__c,First_Name__c,Full_Name__c,Last_Name__c,Personal_email_ID__c,Mobile_Number__c 
                                                FROM Applicant__c
                                                WHERE Id =: applicantId
                                                ];
              return applicantList;
  }

    /*
  @description : Method to get the Notification Content Metadata records based on the Trigger Point  
  @param       : notificationName - notification name
  @return : List <Notification_Content__mdt>
  */

  public static List < Notification_Content__mdt > getNotificationContent(String notificationName) {
  List < Notification_Content__mdt > notificationContentList = new List < Notification_Content__mdt > ();
      notificationContentList = [SELECT id,MasterLabel,Notification_Internal_Or_External__c, Notification_Master__r.Trigger_Point__c, Notification_Master__r.Mail__c, Email__c, Email_Body__c, Email_Subject__c,Retention_Period__c, To__c, isActive__c, Attached_Document_Name__c
                                FROM Notification_Content__mdt
                                WHERE Notification_Master__r.DeveloperName =: notificationName AND Email__c = 'Yes' /*AND Notification_Master__r.Mail__c = 'Yes'*/ AND isActive__c = true
                                ];
      return notificationContentList;
  }
  public class CustomException extends Exception {}

  public class FileWrapper {
      public string baseData;
      public string publicURL;        
  }
  public class DocumentWrapper {
    public string documentName;
    public string fileContent;        
}
}