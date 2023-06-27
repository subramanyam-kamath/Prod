@isTest

public class testRestrictContactByName{

@isTest public static void testcreateContactname(){

contact ct = new contact (Firstname='test', LastName='Invalidname2');



Test.startTest();

database.saveresult result = Database.insert(ct, false);


Test.stopTest();

System.assertequals(true, result.issuccess());



}

@istest public static void updateContactname(){

contact ct2 = new contact (FirstName='test2', LastName='Invalidname2');
insert ct2;

ct2.LastName='Invalidname';

Test.startTest();

database.saveresult result2 = Database.update(ct2, false);

Test.stopTest();

System.assertequals('The Last Name "Invalidname" is not allowed for DML', result2.getErrors()[0].getmessage());


}
}