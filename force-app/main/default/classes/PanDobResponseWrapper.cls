public class PanDobResponseWrapper {   
    public Result result;
    public String requestId;
    public ClientData clientData;
    public Integer statusCode;
    public class ClientData {
        public String caseId;
    }
    
    public class Result {
        public String dob;
        public String name;
        public String status;
    }
}