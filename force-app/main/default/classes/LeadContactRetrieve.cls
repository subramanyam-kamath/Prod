@RestResource(urlMapping='/*/*')

global with sharing class LeadContactRetrieve {

@HttpGet

global static List<SObject> getContactLead (){

 RestRequest request = RestContext.request;
 RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');
               
        String Email = request.params.get('Email');

List<Sobject> Ctc = [Select Id, LastName from Contact where Email =:Email];

List<Sobject> Ltc = new List<Lead>([Select Id, LastName from Lead where Email=:Email]);

if(Ctc.Size() > 0)
{ return Ctc;}
else { return Ltc ;}

}

}