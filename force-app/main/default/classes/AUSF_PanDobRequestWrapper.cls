/**
* @author        Pradeep Sharma
* @date          21-June-2024
* @description   Wrapper for creating request body
* Modification Log:
  --------------------------------------------------------------------------------------------
  Developer             Date            Description
  --------------------------------------------------------------------------------------------
  Pradeep Sharma        21-June-2024    Initial Version
*/
public class AUSF_PanDobRequestWrapper {
    public AUSF_PanDobRequestWrapper(){}
    public String RequestId;
    public String OriginatingChannel;
    public String pan;
    public String consent;
    public ClientData clientData;
    public class ClientData {
        public String caseId;
    }   
}