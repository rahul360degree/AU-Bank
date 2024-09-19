public without sharing class AUSF_GST_AuthenticationResponseWrapper {
    @AuraEnabled public AUSF_INT_IntegrationResponseWrapper.ResponseWrapper responseWrapper;
    @AuraEnabled public Boolean blnIntegrationSuccess = false;
    @AuraEnabled public Boolean blnSuccess = false;
    public String requestId { get; set; }
    public Result result { get; set; }
    public Integer statusCode { get; set; }

    public class Result {
        public String stjCd { get; set; }
        public String lgnm { get; set; }
        public String stj { get; set; }
        public String dty { get; set; }
        public Address adadr { get; set; }
        public String cxdt { get; set; }
        public List<String> nba { get; set; }
        public String gstin { get; set; }
        public String lstupdt { get; set; }
        public String rgdt { get; set; }
        public String ctb { get; set; }
        public Address pradr { get; set; }
        public String tradeNam { get; set; }
        public String sts { get; set; }
        public String ctjCd { get; set; }
        public String ctj { get; set; }
        public String canFlag { get; set; }
        public String cmpRt { get; set; }
        public String contacted { get; set; }
        public String ppr { get; set; }
    }

    public class Address {
        public String addr { get; set; }
        public String ntr { get; set; }
        public String adr { get; set; }
        public String em { get; set; }
        public String lastUpdatedDate { get; set; }
        public String mb { get; set; }
    }
}