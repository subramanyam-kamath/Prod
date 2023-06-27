public class bigObjectClass implements Database.Batchable<sObject> {
    
    public Database.QueryLocator  start(Database.BatchableContext bc) {
       return Database.getQueryLocator( 
           
           'SELECT ID,Subject,TextBody	from EmailMessage'
        );
    }
    public void execute(Database.BatchableContext bc, List<EmailMessage> scope){
        
        List<Email_Messsage__b> insertEmail = new List<Email_Messsage__b>();
        
        for(EmailMessage em: scope){
            Email_Messsage__b em2 = new Email_Messsage__b();
            
            em2.Message_Body__c = em.TextBody;
            em2.Subject__c=em.Subject;
            
            insertEmail.add(em2);
            
        }
        
        database.insertImmediate(insertEmail) ;
        
    }
    public void finish(Database.BatchableContext bc){
        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors,
            JobItemsProcessed,
            TotalJobItems, CreatedBy.Email
            FROM AsyncApexJob
            WHERE Id = :bc.getJobId()];

    }


}