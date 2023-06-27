public class CreateBulkAccounts {

    public static void insertAccts(integer value){
        
        //Integer value2 = value;
        
       List<Account> insertAcct = new List<Account>();
        
        for(integer i=1; i<=value ; i++){
            
            Account myAcct = new Account();
            
            myAcct.Name= 'BulckInsert'+ i;
                myAcct.AccountNumber= String.valueOf(i);
            insertAcct.add(myAcct);
            
            System.debug('The name of the Account is'+ MyAcct.Name);

        }
        
    }
}