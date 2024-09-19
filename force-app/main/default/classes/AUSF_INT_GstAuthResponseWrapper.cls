/**
* @author        Tejendra
* @date          31-July-2024
* @description   Wrapper for Fetching GST Authentication Response
* Modification Log:
  --------------------------------------------------------------------------------------------
  Developer             Date            Description
  --------------------------------------------------------------------------------------------
  Tejendra             31-July-2024    Initial Version - APL-34
*/
public without sharing class AUSF_INT_GstAuthResponseWrapper {
    public AUSF_INT_GstAuthResponseWrapper() {

    }
    @AuraEnabled
    public AUSF_INT_IntegrationResponseWrapper.ResponseWrapper responseWrapper;
    @AuraEnabled
    public String requestId;    //825eb4cc-7e1b-4e7c-afab-93b0ecc0ebd8
    @AuraEnabled
    public cls_result result;
    @AuraEnabled
    public Integer statusCode;  //101
    public class cls_result {
        @AuraEnabled
        public AUSF_AddressSplitResponseWrapper.splitaddress splitaddress;
        @AuraEnabled
        public String stjCd;    //MHCG1354
        @AuraEnabled
        public String lgnm; //RELIANCE INDUSTRIES LIMITED
        @AuraEnabled
        public String stj;  //URAN_701
        @AuraEnabled
        public String dty;  //Regular
        @AuraEnabled
        public cls_adadr adadr;
        @AuraEnabled
        public String cxdt;
        @AuraEnabled
        public List<String> nba;
        @AuraEnabled
        public String gstin;    //27AAACR5055K1Z7
        @AuraEnabled
        public String lstupdt;  //01/02/2022
        @AuraEnabled
        public String rgdt; //01/07/2017
        @AuraEnabled
        public String ctb;  //Public Limited Company
        @AuraEnabled
        public cls_pradr pradr;
        @AuraEnabled
        public String tradeNam; //RELIANCE INDUSTRIES LIMITED
        @AuraEnabled
        public String sts;  //Active
        @AuraEnabled
        public String ctjCd;    //VU0404
        @AuraEnabled
        public String ctj;  //RANGE-IV
        @AuraEnabled
        public String canFlag;  //NA
        @AuraEnabled
        public String cmpRt;    //NA
        @AuraEnabled
        public String contacted;
        @AuraEnabled
        public String ppr;  //NA
    }
    public class cls_adadr {
        public String addr; //NA
        public String ntr;  //Warehouse / Depot
        public String adr;  //C/o Mumbai Aviation Fuel Farm Facility Pvt Ltd, Reliance Industries Limited, Near Terminal 1A,Chhatrapati Shivaji Maharaj International A, Santacruz East, Mumbai, Maharashtra, pin: 400099
        public String em;
        public String lastUpdatedDate;  //NA
        public String mb;
    }
    public class cls_pradr {
        public String addr; //NA
        public String ntr;  //Factory / Manufacturing, Retail Business, Input Service Distributor (ISD), Bonded Warehouse, SEZ, Works Contract, Warehouse / Depot, Service Provision, Leasing Business, Office / Sale Office, Recipient of Goods or Services, Wholesale Business, EOU / STP / EHTP
        public String adr;  //Reliance Corporate Park, 5, 5, TTC Industrial Area, Thane Belapur Road, Ghansoli, Navi Mumbai, Maharashtra, pin: 400701
        public String em;
        public String lastUpdatedDate;  //NA
        public String mb;
        public cls_splitaddress splitaddress;
    }

    public class cls_splitaddress{
        public String CO;
        public String House;
        public String Floor;
        public String Building;
        public String Complex;
        public String Street;
        public String Untagged;
        public String locality;
        public String State;
        public String District;
        public String City;
        public String Landmark;
        public String Pin;
    }
    
}