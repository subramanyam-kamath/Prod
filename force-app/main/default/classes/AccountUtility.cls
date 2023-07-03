@isTest
public class AccountUtility {

 public static List<Account> createAccount(Integer Numberinfo, String GivName){

List<Account> createnewAccount = new List<Account>();

for (integer i=0; i<Numberinfo; i++){

Account newacc = new Account (Name=GivName + i);

createNewAccount.add(newacc);
}

insert createnewAccount;

List<Opportunity> createNewOpp = new List<Opportunity>();

for(Account acc : createNewAccount){

System.debug('The Account name is'+ acc.Name);
for(integer i=0; i<numberInfo; i++){

Opportunity oppNew = new Opportunity (Name=GivName+i, StageName='Prospecting', CloseDate=System.today(), AccountId=acc.id);

System.debug('The name of opp is'+ OppNew.Name);
createNewOpp.add(oppNew);
}
}

insert createNewOpp;

return createnewAccount;




}

}
