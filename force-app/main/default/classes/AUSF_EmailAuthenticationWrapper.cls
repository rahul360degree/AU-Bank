/**
* @author        Rahul Yadav
* @date          25-June-2024
* @description   In this class we have created response of the email authentication
* Modification Log:
  --------------------------------------------------------------------------------------------
  Developer             Date            Description
  --------------------------------------------------------------------------------------------
  Rahul Yadav                      25-June-2024    Initial Version
*/
public without sharing class AUSF_EmailAuthenticationWrapper {
        @AuraEnabled public AUSF_INT_IntegrationResponseWrapper.ResponseWrapper responseWrapper;
        @AuraEnabled public Boolean blnIntegrationSuccess = false;
        @AuraEnabled public Boolean blnSuccess = false;
        @AuraEnabled Public String strMessage;
        @AuraEnabled public string Status;
        @AuraEnabled public ResponseInfoWrap ResponseInfo;
        @AuraEnabled public FieldsWrap Fields;
        public AUSF_EmailAuthenticationWrapper(){
            ResponseInfo = new ResponseInfoWrap();
            Fields = new FieldsWrap();
            Fields.Applicants = new ApplicantsWrap();
            Fields.ApplicationData = new ApplicationDataWrap();
            Fields.Applicants.Applicant = new ApplicantWrap();
            Fields.Applicants.Applicant.Services = new ServicesWrap();
            Fields.Applicants.Applicant.Services.Service = new List<ServiceWrap>();
            Fields.Applicants.Applicant.Services.Service = new List<ServiceWrap>();
        }
    public class ResponseInfoWrap{
        @AuraEnabled public integer ApplicationId;
        @AuraEnabled public string SolutionSetInstanceId;
    }
    public class FieldsWrap{
        @AuraEnabled public ApplicantsWrap Applicants;
        @AuraEnabled public ApplicationDataWrap ApplicationData;
        @AuraEnabled public integer ApplicationId;
        @AuraEnabled public string Decision;
    }
    public class ApplicantsWrap{
        @AuraEnabled public ApplicantWrap Applicant;
    }
    public class ApplicationDataWrap{
        @AuraEnabled public ApplicationServicesWrap Services;
    }
    public class ApplicationServicesWrap{
        @AuraEnabled public ApplicationServiceWrap Service;
    }
    public class ApplicationServiceWrap{
        @AuraEnabled public boolean Consent;
        @AuraEnabled public string Skip;
        @AuraEnabled public string Id;
        @AuraEnabled public string Name;
    }
    public class ApplicantWrap{
        @AuraEnabled public ServicesWrap Services;
        @AuraEnabled public string ApplicantIdentifier;
        @AuraEnabled public string EmailAddress;
        
    }
    public class ServicesWrap{
        @AuraEnabled public List<ServiceWrap> Service;
    }
    public class ServiceWrap{
        @AuraEnabled public string Status;
        @AuraEnabled public string Id;
        @AuraEnabled public OperationsWrap Operations;
        @AuraEnabled public string Name;
    }
    public class OperationsWrap{
        @AuraEnabled public ParamsWrap Params;
        @AuraEnabled public List<OperationWrap> Operation;
    }
    public class ParamsWrap{
        @AuraEnabled public List<ParamWrap> Param;
    }
    public class ParamWrap{
        @AuraEnabled public string Value;
        @AuraEnabled public string Name;
    }
    public class OperationWrap{
        @AuraEnabled public string Status;
        @AuraEnabled public DataWrap Data;
        @AuraEnabled public string Id;
        @AuraEnabled public string Name;
    }
    public class DataWrap{
        @AuraEnabled public ResponseWrap Response; 
    }
    public class ResponseWrap{
        @AuraEnabled public string RawResponse;
    }
    public class RawResponseWrap{
        @AuraEnabled public EmailvalidationWrap email_validation;
    }
    public class EmailvalidationWrap{
        @AuraEnabled public integer status_code;
        @AuraEnabled public string status;
    }
}