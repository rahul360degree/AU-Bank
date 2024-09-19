/**
 * @author       Ankit Bansal
 * Class :		 AUSF_ICWAI_APIResponseWrapper
 * @date         06-Aug-2024
 * @description: Integration response wrapper for ICWAI API
 * Modification Log:
--------------------------------------------------------------------------------------------
    Developer             Date            Description
--------------------------------------------------------------------------------------------
    Ankit Bansal        06-Aug-2024    Initial Version
*/
public class AUSF_ICWAI_APIResponseWrapper{
    public AUSF_ICWAI_APIResponseWrapper(){}
    @AuraEnabled
    public result result;
    @AuraEnabled
    public String request_id;
    @AuraEnabled
    public String statusCode;//status-code
    public class result{
        @AuraEnabled
		public String ValidUpDt;
        @AuraEnabled
		public String gender ; 
        @AuraEnabled
		public String Retired ; 
        @AuraEnabled
		public String SrName ; 
        @AuraEnabled
		public String Mname ; 
        @AuraEnabled
		public String Chapter ; 
        @AuraEnabled
		public String MemRegion ; 
        @AuraEnabled
		public String CancellationDt ; 
        @AuraEnabled
		public String EffectiveDt ;
        @AuraEnabled
		public String CrtEmployer ; 
        @AuraEnabled
		public String MemCategory ; 
        @AuraEnabled
		public String FirmEftDt ; 
        @AuraEnabled
		public String ProtFirmName ; 
        @AuraEnabled
		public String dob ; 
        @AuraEnabled
		public String MemshipDt ; 
        @AuraEnabled
		public String Fname ; 
    }
}