/**
* @author        Tejendra
* @date          6-August-2024
* @description   Wrapper for Import Export Certificate payload
* Modification Log:
--------------------------------------------------------------------------------------------
Developer             Date            Description
--------------------------------------------------------------------------------------------
Tejendra            6-August-2024     Initial Version - APL-202
*/
public without sharing class AUSF_ImportExportCrtificatRequestWrapper {
    public AUSF_ImportExportCrtificatRequestWrapper() {

    }
    public String RequestId;
    public String OriginatingChannel;
    public String Iec;
    public String Consent;
}