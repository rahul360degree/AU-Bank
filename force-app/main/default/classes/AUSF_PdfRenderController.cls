public without sharing class AUSF_PdfRenderController {
    public String contentDocumentId { get; set; }
    public ContentVersion contentVersion { get; set; }
    public AUSF_PdfRenderController() {
        //contentDocumentId = ApexPages.currentPage().getParameters().get('contentDocumentId');ContentDocumentId
        contentDocumentId = '069C1000003PoWAIA0';
        if (contentDocumentId != null) {
            contentVersion = [SELECT Id, Title, VersionData, FileExtension FROM ContentVersion WHERE ContentDocumentId = :contentDocumentId LIMIT 1];
        }
    }
    public String getBase64Content() {
        return EncodingUtil.base64Encode(contentVersion.VersionData);
    }
    public String getContentType() {
        // Determine the content type based on the file extension
        String fileExtension = contentVersion.FileExtension.toLowerCase();
        if (fileExtension == 'png') {
            return 'image/png';
        } else if (fileExtension == 'jpg' || fileExtension == 'jpeg') {
            return 'image/jpeg';
        } else if (fileExtension == 'pdf') {
            return 'application/pdf';
        } else {
            return 'application/octet-stream'; // Default binary type
        }
    }
}