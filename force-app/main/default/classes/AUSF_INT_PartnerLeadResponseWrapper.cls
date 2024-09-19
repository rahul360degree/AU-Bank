/*******************************************************************************************
* @Name         AUSF_INT_PartnerLeadResponseWrapper
* @Author       Mohit M.
* @Description  Response Wrapper for Partner Lead Inbound SF Service
* @Test Class   AUSF_INT_PartnerLeadResponseWrapper_Test
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer            Date                    Description
*-------------------------------------------------------------------------------------------
*  1.0             Mohit M.             23-July-2024            Initial Creation 
*******************************************************************************************/
public with sharing class AUSF_INT_PartnerLeadResponseWrapper {
    public class CALLBACK_DETAILS {
        public String RETURN_URL;
        public String LeadNumber;
        public String status;
        public String message;
        public String duration;
    }
}