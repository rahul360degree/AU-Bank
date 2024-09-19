/**
* @author        Mohit M.
* @date          18-June-2024
* @description   Wrapper to contains next screen and message
* Modification Log:
  --------------------------------------------------------------------------------------------
  Developer             Date            Description
  --------------------------------------------------------------------------------------------
  Mohit M.              18-June-2024    Initial Version
*/
public class PageResponseWrapper{
    @auraEnabled
    public String nextScreen                                            {get;set;}
    @auraEnabled
    public Boolean isSuccess                                            {get;set;}
    @auraEnabled
    public String pageMessage                                           {get;set;}
    //constructor
    public PageResponseWrapper(Boolean isSuccess, String nextScreen, String pageMessage){
        this.nextScreen = nextScreen;
        this.isSuccess = isSuccess;
        this.pageMessage = pageMessage;
    }
}