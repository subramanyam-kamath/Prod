public without sharing class getMyLearning{


@AuraEnabled(cacheable=true)

public static list<Courses__c> getPartnerLearning(string userid2){

 List<Id> Catalog = new List<Id>();
  
id accid = [Select id, accountid from User where id=:userid2 limit 1 ].accountid;  
 
List<Multiple_Catalogs__c> multicatalog  = [Select id,Catalog__c from Multiple_Catalogs__c where Account__c=:accid WITH SYSTEM_MODE ];

for(Multiple_Catalogs__c mcc : multicatalog){

Catalog.add(mcc.Catalog__c );

}

list<Courses__c> ptnrCourselist = new list<Courses__c>([Select id,Name,Catalog_Name__c,Restricted_Account__c,Class_Audience__c,Catalog__c from Courses__c where  Catalog__r.Audience_Type__c ='All' OR Catalog__r.Audience_Type__c ='Partner' OR  Catalog__r.Audience_Type__c ='Authenticated User' OR Catalog__c=:Catalog ]);

 system.debug(ptnrCourselist);

return ptnrCourselist;


}

@AuraEnabled(cacheable=true)

public static list<Courses__c> getCustomerLearning(id userid2){

List<Id> Catalog = new List<Id>();
  
id accid = [Select id, accountid from User where id=:userid2 limit 1 ].accountid;  
 
List<Multiple_Catalogs__c> multicatalog  = [Select id,Catalog__c from Multiple_Catalogs__c where Account__c=:accid WITH SYSTEM_MODE ];

for(Multiple_Catalogs__c mcc : multicatalog){

Catalog.add(mcc.Catalog__c );

}

 list<Courses__c> custCourselist = new list<Courses__c>([Select id,Name,Catalog_Name__c,Restricted_Account__c,Class_Audience__c,Catalog__c from Courses__c where  Catalog__r.Audience_Type__c ='All' OR Catalog__r.Audience_Type__c ='Customer' OR  Catalog__r.Audience_Type__c ='Authenticated User' OR Catalog__c=:Catalog ]);
 
 return custCourselist;

}

@AuraEnabled(cacheable=true)


public static list<Courses__c> getEmployeeLearning(id userid2){

List<Id> Catalog = new List<Id>();
  
id accid = [Select id, accountid from User where id=:userid2 limit 1 ].accountid;  
 
List<Multiple_Catalogs__c> multicatalog  = [Select id,Catalog__c from Multiple_Catalogs__c where Account__c=:accid WITH SYSTEM_MODE ];

for(Multiple_Catalogs__c mcc : multicatalog){

Catalog.add(mcc.Catalog__c );

}

 list<Courses__c> custCourselist = new list<Courses__c>([Select id,Name,Catalog_Name__c,Restricted_Account__c,Class_Audience__c,Catalog__c from Courses__c where  Catalog__r.Audience_Type__c ='all' OR  Catalog__r.Audience_Type__c ='Partner' OR  Catalog__r.Audience_Type__c ='internal' OR Catalog__c=:Catalog]);
 
 return custCourselist;
}

@AuraEnabled(cacheable=true)

public static list<Courses__c> getGuestUserLearning(string userid2){


list<Courses__c> guestCourselist = new list<Courses__c>([Select id,Name,Catalog_Name__c,Restricted_Account__c,Class_Audience__c,Catalog__c from Courses__c where  Catalog__r.Audience_Type__c ='All' OR Catalog__r.Audience_Type__c ='Public']);

 

return guestCourselist;

}
}