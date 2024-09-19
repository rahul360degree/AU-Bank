/**
* @author        Tejendra
* @date          06-August-2024
* @description   Wrapper for Import Export Certificate API Response
* Modification Log:
  --------------------------------------------------------------------------------------------
  Developer             Date            Description
  --------------------------------------------------------------------------------------------
  Tejendra             06-August-2024    Initial Version - APL-202
*/
public without sharing class AUSF_INT_ImportExportCertResponseWrapper {
    public AUSF_INT_ImportExportCertResponseWrapper() {

    }
    @AuraEnabled
    public AUSF_INT_IntegrationResponseWrapper.ResponseWrapper responseWrapper;
    @AuraEnabled
    public cls_result result;
    @AuraEnabled
    public String statuscode;   //101
    @AuraEnabled
    public String request_id;   //dfdeec5c-ad69-42f4-9392-d210b8ad7a59
    public class cls_result {
        @AuraEnabled
        public String ie_code;  //0388066415
        @AuraEnabled
        public String party_name_and_address;   //RELIANCE INDUSTRIES LIMITED MAKER CHAMBER IV, , 3RD FLOOR,222 NARIMAN POINT Contact No: 919967062340 , MUMBAI MAHARASHTRA , MUMBAI , MAHARASHTRA, 400021
        @AuraEnabled
        public String phone_no; //9967515848
        @AuraEnabled
        public String address;  //MAKER CHAMBER IV,3RD FLOOR,222 NARIMAN POINT ContactMUMBAI MAHARASHTRA
        @AuraEnabled
        public String nature_of_concern;    //Public Limited
        @AuraEnabled
        public String iec_allotment_date;   //12-04-1988
        @AuraEnabled
        public List<cls_directors> directors;
        @AuraEnabled
        public String no_of_branches;   //296
        @AuraEnabled
        public cls_branches[] branches;
        @AuraEnabled
        public String file_number;  //MUMIECPAMEND00038637AM23
        @AuraEnabled
        public String bin_pan_extension;    //AAACR5055KFT001
        @AuraEnabled
        public String file_date;    //29-07-2022
        @AuraEnabled
        public String date_of_establishment;    //08-05-1973
        @AuraEnabled
        public String iecgate_status;   //AMENDMENT
        @AuraEnabled
        public String e_mail;   //ashokkumar.khandelwal@ril.com
        @AuraEnabled
        public String exporter_type;    //Manufacturer Exporter
        @AuraEnabled
        public String name; //RELIANCE INDUSTRIES LIMITED
        @AuraEnabled
        public String iec_status;   //Valid
        @AuraEnabled
        public String pan;  //AAACR5055K

        public AUSF_AddressSplitResponseWrapper.splitaddress splitaddress;
    }
    
    public class cls_directors {
        @AuraEnabled
        public String address;  //D-4, Varsha Park, Raghunath Bunglow,,Baner Road, Baner,,Pune
        @AuraEnabled
        public String father_name;  //ANANT TUKARAM MASHELKAR
        @AuraEnabled
        public String dir_name; //RAGHUNATH ANANT MASHELKAR
    }
    
    public class cls_branches {
        @AuraEnabled
        public String branch_code;  //20
        @AuraEnabled
        public String address;  //C/O.CHEMICAL TERMINAL TROMBAY LTD, PIRPAU INSTALLATION,NEAR BPT,PUMP H , TROMBAY MUMBAI,MAHARASHTRA,400074
    }
    }