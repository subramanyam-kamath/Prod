public class LeadProcessor implements Database.Batchable<sObject>, Database.Stateful{

public Integer recordsProcessed = 0;
public Database.QueryLocator start(Database.BatchableContext bc) {
return database.getQuerylocator(
 'SELECT ID, LeadSource FROM Lead ');
 
 }
 
 public void execute(Database.BatchableContext bc, List<Lead> scope){
 
 
 List<Lead> UdpateLeads = new List<Lead>();
 
 for (Lead uplead : scope){
 
 uplead.LeadSource='Dreamforce';
 
 UdpateLeads.add(uplead);
 recordsProcessed = recordsProcessed + 1;
 }
 
 update UdpateLeads;
 
 }
 
 
 public void finish(Database.BatchableContext bc){
        System.debug(recordsProcessed + ' records processed. Shazam!');
        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors,
            JobItemsProcessed,
            TotalJobItems, CreatedBy.Email
            FROM AsyncApexJob
            WHERE Id = :bc.getJobId()];
 }
 }