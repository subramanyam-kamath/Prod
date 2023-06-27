public class DataInsert {

public static Boolean isFirstTime = true;

public  static SObject createSobject(String ObjectName, Map<String, Object> FieldValue) {



SObject sObj = Schema.getGlobalDescribe().get(ObjectName).newSObject() ;

if(!FieldValue.isEmpty()){

for(String FieldName: FieldValue.keySet()){

sObj.put(FieldName, FieldValue.get(FieldName));
System.debug( 'The value of the field is'+''+ FieldValue.get(FieldName));

System.debug('Trigger Entered');


}

insert sObj;
System.debug('The value of the case is'+''+ sObj);
}

return sObj;





}

}