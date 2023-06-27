@isTest(SeeAllData=true)

global class AccountManagerTest{

@isTest static void getAccountContacts() {
        
        // Set up a test request
        RestRequest request = new RestRequest();
        request.requestUri =
            'https://sfcom-d-dev-ed.my.salesforce.com/services/apexrest/Accounts/0015j00000WXEL2/contacts/';
          
        request.httpMethod = 'GET';
        RestContext.request = request;
        // Call the method to test
        Account acc = AccountManager.getAccount();
        // Verify results
        System.assert(acc.contacts != null);
        System.assertEquals('0035j00000JG1nh', acc.contacts[0].id);
    }
    }