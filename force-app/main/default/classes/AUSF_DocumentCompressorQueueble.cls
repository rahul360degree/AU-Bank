public without sharing class AUSF_DocumentCompressorQueueble implements Queueable, Database.AllowsCallouts {
    public String memeberImage;
    public String applicantId ='';
    public String loanId = '';
    public String docChecklistId='';
    public String fileName = '';
    public AUSF_DocumentCompressorQueueble(String memberImage,String fileName,String applicantId,String loanId,String docChecklistId){
        this.applicantId = applicantId;
        this.loanId = loanId;
        this.docChecklistId = docChecklistId;
        this.memeberImage = memberImage;
        this.fileName = fileName;
    }
    public void execute(QueueableContext context) {
        AUSF_DocumentCompressController.getCompresssedDocument(memeberImage,fileName,applicantId,loanId,loanId);
    }
   
}