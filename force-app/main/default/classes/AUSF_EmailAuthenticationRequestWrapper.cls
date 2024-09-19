/**
* @author        Rahul Yadav.
* @date          18-June-2024
* @description   Wrapper for Email Authentication Generate request payload
* Modification Log:
  --------------------------------------------------------------------------------------------
  Developer             Date            Description
  --------------------------------------------------------------------------------------------
  Rahul Yadav.              26-June-2024    Initial Version
*/
public without sharing class AUSF_EmailAuthenticationRequestWrapper {
    public FieldsWrap Fields;
    public string RequestId;
    public string Channel;
    public RequestInfoWrap RequestInfo;
    public AUSF_EmailAuthenticationRequestWrapper(){
        RequestInfo = new RequestInfoWrap();
        Fields = new FieldsWrap();
        Fields.Applicants = new ApplicantsWrap();
        Fields.Applicants.Applicant = new ApplicantWrap();
        Fields.Applicants.Applicant.Services = new ServicesWrap();
        Fields.Applicants.Applicant.Services.Service = new ServiceWrap();
        Fields.Applicants.Applicant.Services.Service.Operations = new OperationsWrap();
        Fields.Applicants.Applicant.Services.Service.Operations.Operation = new List<OperationWrap>();
        Fields.ApplicationData = new ApplicationDataWrap();
        Fields.ApplicationData.Services = new ApplicationServicesWrap();
        Fields.ApplicationData.Services.Service = new ApplicationServiceWrap();
    }
    public class RequestInfoWrap{
        public string SolutionSetName;
        public boolean ExecuteLatestVersion;
    }
    public class FieldsWrap{
        public ApplicantsWrap Applicants;
        public ApplicationDataWrap ApplicationData;
    }
    public class ApplicantsWrap{
        public ApplicantWrap Applicant;
    }
    public class ApplicantWrap{
        public string EmailAddress;
        public ServicesWrap Services;
    }
    public class ServicesWrap{
        public ServiceWrap Service;
    }
    public class ServiceWrap{
        public string Id;
        public string Name;
        public OperationsWrap Operations;
    }
    public class OperationsWrap{
        public List<OperationWrap> Operation;
    }
    public class OperationWrap{
        public string Id;
        public string Name;
    }
    public class ApplicationDataWrap{
        public ApplicationServicesWrap Services;
    }
    public class ApplicationServicesWrap{
        public ApplicationServiceWrap Service;
    }
    public class ApplicationServiceWrap{
        public string Id;
        public string Name;
        public string Skip;
        public boolean Consent;
    }
}