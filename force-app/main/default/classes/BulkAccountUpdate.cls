public class BulkAccountUpdate implements Database.Batchable<sObject>, Database.Stateful{

integer recordsProcessed =0;

public Database.Querylocator start (Database.BatchableContext bc){

return Database.getQueryLocator(
            'SELECT ID, BillingStreet, BillingCity, BillingState, ' +
            'BillingPostalCode, (SELECT ID, MailingStreet, MailingCity, ' +
            'MailingState, MailingPostalCode FROM Contacts) FROM Account ' +
            'Where Active__c = \'Yes\''
        );
}

public void execute (Database.BatchableContext bc, List<Account> scope){

for (Account acct : scope){

acct.Active__c='Yes';
recordsProcessed= recordsProcessed+1;

}

}

public void finish(Database.BatchableContext bc){

System.debug(recordsProcessed);
}
}