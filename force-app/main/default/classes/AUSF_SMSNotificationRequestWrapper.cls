/**
* @author        Tejendra
* @date          3-July-2024
* @description   SMS Notification Request Wrapper class
* Modification Log:
--------------------------------------------------------------------------------------------
Developer             Date            Description
--------------------------------------------------------------------------------------------
Tejendra              3-July-2024    Initial Version
*/
public without sharing class AUSF_SMSNotificationRequestWrapper {
    public AUSF_SMSNotificationRequestWrapper() {

    }
        public String RequestId;
        public String Channel;
        public String GroupID;
        public String ContentType;
        public String NationalorInternational;
        public String MessageType;
        public String IsOTPMessage;
        public String LanguageId;
        public Message_cls Message;

        public class Message_cls{
            public String MobileNumber;
            public String MessageText;
        }
}