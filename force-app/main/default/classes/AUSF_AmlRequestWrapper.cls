/**
* @author        Tejendra
* @date          28-June-2024
* @description   Wrapper for AML request payload
* Modification Log:
--------------------------------------------------------------------------------------------
Developer             Date            Description
--------------------------------------------------------------------------------------------
Tejendra            28-June-2024     Initial Version
*/
public without sharing class AUSF_AmlRequestWrapper {
    public AUSF_AmlRequestWrapper(){
        fields = new List<cls_fields>();
    }
    public String AML_ACTION;
	public String batch_mode;	//O
	public String callbackurl;	//https://osb.aubank.in/Clari5CallBack/callback
	public String datetimex;	//2024-01-23 09:29:34
	public String errorCode;
	public String errorMessage;
	public List<cls_fields> fields;
	public String MATCH;
	public String referenceid;	//SFDCPROD_0b5e067fa03687fcc899d59e5
	public String refid;	//RAJ0000101010
	public String status;
	public String systemname;	//SFDC
	public String userid;	//SYS
	
	public class cls_fields {
		public String name;	//name
		public String value;	//Full Name
	}
}