public class AddPrimaryContact implements Queueable {

public string stateup;
public Contact upContact;

public  AddPrimaryContact (Contact crtContact, String State){

this.stateup=State;
this.upContact= crtContact;

}

public void execute(QueueableContext context){

List<Account> accts = [Select Id,(Select Id,FirstName,LastName from contacts), BillingState from Account where BillingState=:stateup Limit 200];
List<Contact> InsCont = new List<Contact>();
for(Account acc: accts){

Contact createContact = upContact.clone(false,false,false,false);
insCont.add(createContact);
}

if(InsCont.size()>0){

insert InsCont;
}

}
}