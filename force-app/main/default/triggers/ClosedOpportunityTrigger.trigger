trigger ClosedOpportunityTrigger on Opportunity (after update, after insert) {

List<Task> createnewTask = new List<Task>();

for(Opportunity opp: [Select Id, Stagename from Opportunity where stagename='Closed Won' AND Id IN:Trigger.New]){

Task newtask = new Task (Subject='Follow Up Test Task', WhatId=opp.id);

createnewTask.add(newtask);
}

if(Trigger.isafter){

if(Trigger.isinsert){
insert createnewTask;
}

else {
if(Trigger.isupdate){
insert createnewTask;}
}
}

}