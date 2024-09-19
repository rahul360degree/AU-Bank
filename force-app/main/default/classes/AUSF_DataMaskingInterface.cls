/**
* @author        Mohit M.
* @date          18-June-2024
* @description   Implement this interface for all Data masking handlers
* Modification Log:
  --------------------------------------------------------------------------------------------
  Developer             Date            Description
  --------------------------------------------------------------------------------------------
  Mohit M.              18-June-2024    Initial Version
*/
public interface AUSF_DataMaskingInterface {

    String maskRequest(String request);

    String maskResponse(String response);
    
}