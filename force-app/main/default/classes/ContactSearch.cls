public class ContactSearch{
public static List<Contact> searchForContacts(String fsName, String LsName){

List<Contact> returnContacts= [Select ID,Name from Contact where LastName=:fsName AND MailingPostalCode=:LsName];

return returnContacts;

}
}