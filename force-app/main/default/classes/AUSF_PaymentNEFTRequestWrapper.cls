/**
* @author        Tejendra
* @date          10-July-2024
* @description   Wrapper for NEFT request payload
* Modification Log:
--------------------------------------------------------------------------------------------
Developer             Date            Description
--------------------------------------------------------------------------------------------
Tejendra            10-July-2024     Initial Version
*/
public without sharing class AUSF_PaymentNEFTRequestWrapper {
    public AUSF_PaymentNEFTRequestWrapper() {

    }
    public cls_SettlementRequest SettlementRequest;
    public class cls_SettlementRequest {
        public String SenderIFSC;   
        public String ReceivingCustomerName;    
        public String Narration;    
        public String Amount;   
        public String ReceiverAccountNumber;    
        public String Source;   
        public String SenderContactInfo;    
        public String SenderAccountType;    
        public String SenderAccountNumber;  
        public String ReceiverAccountType;  
        public String ReceiverIFSC; 
        public String ValueDate;    
        public String SendingCustomerName;  
        public String TransactionReferenceNumber; 
    }  
}