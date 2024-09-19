/**
* @author        Tejendra
* @date          31-July-2024
* @description   Wrapper for GST Authentication payload
* Modification Log:
--------------------------------------------------------------------------------------------
Developer             Date            Description
--------------------------------------------------------------------------------------------
Tejendra            31-July-2024     Initial Version - APL-34
*/
public without sharing class AUSF_GstAuthenticationRequestWrapper {
    public AUSF_GstAuthenticationRequestWrapper() {

    }
    public String requestid;
    public String channel;
    public String consent;
    public String gstin;
}