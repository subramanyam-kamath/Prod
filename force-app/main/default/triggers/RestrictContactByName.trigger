trigger RestrictContactByName on Contact ( before update) {
    
   for(Contact ctc: Trigger.new){
   
  Contact ctc2 = Trigger.oldMap.get('0035j00000neK7n');
  
  set<Id> catpureId= Trigger.oldMap.keySet();
  
  System.debug('The value of the id is'+ catpureId + ctc.LastName);
  
  if(ctc2.Level__c  =='Secondary'&& ctc.Level__c=='Secondary'){
  
  ctc.addError('You cant modify this contact');
  
  }
  }


}