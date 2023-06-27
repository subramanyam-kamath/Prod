@isTest
private class LeadProcessorTest {
    @testSetup
    static void setup() {
        List<Lead> Leads = new List<Lead>();
        List<Lead> Leadupdate = new List<Lead>();
        
        // insert 10 accounts
        for (Integer i=0;i<200;i++) {
            Leads.add(new Lead(LAstName='Lead '+i, Company='Company'+i
             ));
        }
        insert Leads;
        
    }
    @isTest static void test() {
        Test.startTest();
        LeadProcessor LPA = new LeadProcessor();
        Id batchId = Database.executeBatch(LPA);
        Test.stopTest();
        // after the testing stops, assert records were updated properly
        System.assertEquals(200, [select count() from Lead where LeadSource = 'Dreamforce']);
    }
}