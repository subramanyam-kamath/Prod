

//comment
public class AccountDeletiontest{

public static void TestAccountDeletion(){

Account[] delAccount= AccountUtility.createAccount(2,'SfTest');


Database.DeleteResult result =  Database.delete(delAccount[0], false);



System.assertEquals(false,result.Issuccess());
System.assert(result.getErrors().Size()>0);
System.assertEquals('You cannot delete the Opportunity',result.getErrors()[0].getMessage());

}
}
