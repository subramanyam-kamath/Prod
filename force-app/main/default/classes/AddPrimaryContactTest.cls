@isTest
public class AddPrimaryContactTest {

    @isTest static void testQueueable(){
        //<-----@testSetup
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < 50; i++){accounts.add(new Account(name = 'acc' + i, BillingState = 'New York', BillingCountry='United States')); }
        for (Integer i = 50; i < 100; i++){accounts.add(new Account(name = 'acc' + i, BillingState = 'California', BillingCountry='United States')); }
        insert accounts;
        
        String strState = 'California';
        Contact cont = new Contact(LastName = 'TstsName');
        AddPrimaryContact updater = new AddPrimaryContact(cont, strState);
        //<-----@testSetup

        //<-----@testExecution
        Test.startTest();
            System.enqueueJob(updater);
        Test.stopTest();
        //<-----@testExecution
        
        //<-----@testResult
        System.assertEquals(50, [select count() from Contact where accountID IN (SELECT id FROM Account WHERE BillingState = :strState)]);   
        //<-----@testResult
    }
}