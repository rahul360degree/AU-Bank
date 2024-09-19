/**
* @author        Tejendra
* @date          4-July-2024
* @description   Email Notification Request Wrapper class
* Modification Log:
--------------------------------------------------------------------------------------------
Developer             Date            Description
--------------------------------------------------------------------------------------------
Tejendra              4-July-2024    Initial Version
*/
public without sharing class AUSF_EmailNotificationRequestWrapper {
    public AUSF_EmailNotificationRequestWrapper() {

    }
    public String RequestId;
    public String Channel;
    public String TO;
    public String CC;
    public String BCC;
    public String Subject;
    public String Text;
    public String Priority;
    public Attachment_cls Attachment;

    public class Attachment_cls{
        public String FileName;
        public String FileMimeType;
        public String FileDataContent;
    }
}