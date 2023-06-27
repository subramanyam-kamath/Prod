public class DailyLeadProcessor implements Schedulable {

public void execute(SchedulableContext ctx) {

List<Lead> findLeads = [Select Id, LeadSource from Lead where LeadSource='' Limit 200];
List<Lead> updateleads = new List<Lead>();

for(Lead uplead : findLeads){

uplead.LeadSource='Dreamforce';
updateleads.add(uplead);

}

update updateleads;

}
}