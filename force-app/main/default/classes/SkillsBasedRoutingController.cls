public class SkillsBasedRoutingController {
    
    @InvocableMethod(label='Insert Accounts')
    /*
       Primary method to route records through Omni-Channel
    */
   
    public static void routeUsingSkills( List < sObject > listRecords ) {
    
        List < PendingServiceRouting > listPSRs = new List < PendingServiceRouting >();
        String strChannelId = '0N95j000000H8Lg';
        Map < String, Id > mapSkillId = getSkillId();
        Map < Id, sObject > mapObj = new Map < Id, sObject >( listRecords );
    
        for ( sObject obj : listRecords )        
            listPSRs.add( createPendingServiceRouting( obj, strChannelId ) );
        
        if ( listPSRs.size() > 0 ) {
        
            List < SkillRequirement > listSRs = new List < SkillRequirement >();
            insert listPSRs;
            
            for ( PendingServiceRouting objPSR : listPSRs ) {
            
                objPSR.IsReadyForRouting = TRUE;
                sObject obj = mapObj.get( objPSR.WorkItemId );
                String strSkill = ( String ) obj.get( 'Language__c' );
                SkillRequirement objSR = new SkillRequirement(
                    RelatedRecordId = objPSR.id,
                    SkillId = mapSkillId.get( strSkill ),
                    SkillLevel = 5
                );
                listSRs.add( objSR );
            
            }
            
            insert listSRs;
            
            update listPSRs;
            
        }
                
    }
    
    /*
        Method to create Pending Service Routing record for each record
    */
    static PendingServiceRouting createPendingServiceRouting( sObject obj, String strChannelId ) {
    
        PendingServiceRouting psrObj = new PendingServiceRouting(
            CapacityWeight = 1,
            IsReadyForRouting = FALSE,
            RoutingModel = 'MostAvailable',
            RoutingPriority = 1,
            RoutingType = 'SkillsBased',
            ServiceChannelId = strChannelId,
            WorkItemId = obj.Id,
            PushTimeout = 0
        );
        return psrObj;
        
    }
    
    /*
        Method to get the Channel Id based on the Entity
    */
   /* static String getChannelId( String strEntity ) {
    
        ServiceChannel channel = [ SELECT Id From ServiceChannel Where RelatedEntity =: strEntity ];
        return channel.Id;
        
    }
    
    */
    /*
        Method to get Skills. If you have several skills, use WHERE condition in the SOQL to limit it.
    */
    static Map < String, Id > getSkillId() {
    
        Map < String, Id > mapSkillId = new Map < String, Id >();
        
        for ( Skill objSkill : [ SELECT Id, DeveloperName From Skill ] )
            mapSkillId.put( objSkill.DeveloperName, objSkill.Id );
            
        return mapSkillId;
        
    }
    
}