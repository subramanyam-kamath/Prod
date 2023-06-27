@istest private class DailyLeadProcessorTest{

public static String stringdate = '0 0 0 13 8 ? 2022';
static testmethod void testschedulejob(){

List<Lead> insertLead = new List<Lead>();

for(integer i=0; i<200; i++){

Lead createNew = new Lead (LastName='Test'+i, company='TestCompany'+i);

insertLead.add(createNew);
}

insert insertLead;

Test.startTest();

DailyLeadProcessor reminder = new DailyLeadProcessor();
String Jobid= System.schedule('ProcessLeadSource',stringdate, reminder);

Test.stopTest();

System.assertEquals(200, [Select count() from Lead where LeadSource='Dreamforce']);

System.assertequals('Dreamforce', [Select Id, LeadSource from Lead where LeadSource='Dreamforce'][0].LeadSource);

}
}