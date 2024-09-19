/**
* @author        Tejendra
* @date          29-June-2024
* @description   Wrapper for Aml Response
* Modification Log:
  --------------------------------------------------------------------------------------------
  Developer             Date            Description
  --------------------------------------------------------------------------------------------
  Tejendra             29-June-2024    Initial Version
*/
public class AUSF_INT_DOAMLResponseWrapper {
    public AUSF_INT_DOAMLResponseWrapper() {}
    @AuraEnabled
    public AUSF_INT_IntegrationResponseWrapper.ResponseWrapper responseWrapper;
    @AuraEnabled
    public String AML_Action;
    @AuraEnabled
    public String MATCH;
    @AuraEnabled
    public status_cls status;

    public class status_cls{
       @AuraEnabled 
       public String status;
       @AuraEnabled
       public String errorDetails;
    }
}