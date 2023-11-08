HttpRequest req = new HttpRequest();
req.setEndpoint(
    URL.getOrgDomainUrl().toExternalForm() +
    '/services/data/v58.0/tooling/query/?q=Select+id,NumLinesCovered,NumLinesUncovered,ApexClassOrTriggerId,ApexClassOrTrigger.Name+from+ApexCodeCoverageAggregate+LIMIT+20'
);
req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID());
req.setHeader('Content-Type', 'application/json');
req.setMethod('GET');
Http h = new Http();
HttpResponse res = h.send(req);
system.debug('res.getBody(): '+res.getBody());
List<Object> objList = (List<Object>)((Map<String, Object>) JSON.deserializeUntyped(
    res.getBody()
)).get('records');
for (Integer i=0; i < objList.size(); i++) {
    Map<String, Object> record = (Map<String,Object>)objList[i];
    String apexClassId = (String)record.get('ApexClassOrTriggerId');
    Decimal numLinesCovered = ((Integer)record.get('NumLinesCovered'));
    Decimal totalLines = ((Integer)record.get('NumLinesUncovered')) + numLinesCovered;
    Integer codecoverage = (numLinesCovered >0)  ? (Integer.valueOf((numLinesCovered/totalLines)*100)) : 0;
    String apexname =  (([SELECT Name from ApexClass where Id=:apexClassId].size())>0) ? ([SELECT Id from ApexClass where Id=:apexClassId][0].Id) : ([Select Id from ApexTrigger where Id=:apexClassId][0].Id) ;
        if(codecoverage < 75){
            System.debug( apexname);
            
        } }
