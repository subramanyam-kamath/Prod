public class ContactAndLeadSearch{
public static List<List<sObject>> searchContactsAndLeads(String lstname){

List<List<sObject>> searchList = [FIND :lstname IN ALL FIELDS
                    RETURNING Contact(FirstName,LastName),Lead(FirstName,LastName)];
                    
                    return searchList;
}
}