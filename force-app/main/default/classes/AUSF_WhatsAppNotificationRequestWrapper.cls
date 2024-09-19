/**
* @author        Tejendra
* @date          5-July-2024
* @description   WhatsApp Notification Request Wrapper class
* Modification Log:
--------------------------------------------------------------------------------------------
Developer             Date            Description
--------------------------------------------------------------------------------------------
Tejendra              5-July-2024    Initial Version
*/
public without sharing class AUSF_WhatsAppNotificationRequestWrapper {
    public AUSF_WhatsAppNotificationRequestWrapper() {

    }
    public String authorization;	
	public cls_client_data client_data;
	public String requestId;	
	public String whatsapp_bsp;	
	public String channel;	
	public String campaign_id;	
	public class cls_client_data {
		public String name;	
		public String phone_number;	
		public String media_url;	
		public String document_filename;	
		public cls_dynamic_data dynamic_data;
	}
	public class cls_dynamic_data {
		public String key1;	
		public String key2;	
		public String key3;	
		public String key4;	
		public String key5;	
	}
}