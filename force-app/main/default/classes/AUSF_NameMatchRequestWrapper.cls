/**
* @author        Tejendra
* @date          25-June-2024
* @description   Wrapper for Karza Name Match request payload
* Modification Log:
--------------------------------------------------------------------------------------------
Developer             Date            Description
--------------------------------------------------------------------------------------------
Tejendra            25-June-2024     Initial Version
*/
public without sharing class AUSF_NameMatchRequestWrapper {
    public AUSF_NameMatchRequestWrapper(){}
    public String requestId;
    public String channel;
    public String name1;
    public String name2;
    public String type;
    public String preset;
}