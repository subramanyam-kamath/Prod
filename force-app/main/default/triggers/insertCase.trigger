trigger insertCase on Case (before insert) {

Schema.SObjectType expected  = trigger.new.getSObjectType();

String ObjectName= String.valueOf(expected); 



Map<String, Object> FieldValue = new Map<String, Object>();

FieldValue.put('Description', 'DynamicCase');

FieldValue.put('Subject','DynamicCase');

FieldValue.put('Origin', 'Email');

FieldValue.put('Status', 'New');

FieldValue.put('Priority','High');

if(DataInsert.isFirstTime){
        
DataInsert.isFirstTime = false;
DataInsert.createSobject(ObjectName,FieldValue);  





}

}