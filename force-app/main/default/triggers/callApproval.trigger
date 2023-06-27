trigger callApproval on Opportunity ( after update) {

for(Opportunity opp: [Select Id, Stagename from Opportunity where stagename='Negotiation/Review' AND Id IN:Trigger.New]){

System.debug('The id of the opp is'+ ''+ opp.id);

Approval.ProcessSubmitRequest req1 = 
            new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval.');
        req1.setObjectId(opp.id);
        
        // Submit on behalf of a specific submitter
        req1.setSubmitterId(UserInfo.getUserId()); 
        
        
        
      //  String Result= result.getInstanceStatus();
        
        
        // Submit the record to specific process and skip the criteria evaluation
        req1.setProcessDefinitionNameOrId('Discount_Review');
        req1.setSkipEntryCriteria(true);
        
        Approval.ProcessResult result = Approval.process(req1);
        String Result2= result.getInstanceStatus();
        
        System.debug('The result of the approval request is'+ Result2);
}
}