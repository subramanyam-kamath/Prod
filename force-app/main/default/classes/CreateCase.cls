public class CreateCase{

public static HttpResponse makePostCallout(){

Http http = new Http();

HttpRequest req = new HttpRequest();

req.setEndpoint('callout:SalesforceDevorg');
req.setHeader('Content-Type', 'application/json;charset=UTF-8');
req.setMethod('POST');
req.setBody('{"subject":"mighty moose", "status":"New","Origin":"Web","Priority":"High"}');

 HttpResponse response = http.send(req);
 
  if(response.getStatusCode() != 201) {
            System.debug('The status code returned was not expected: ' +
                response.getStatusCode() + ' ' + response.getStatus());
        } else {
            System.debug(response.getBody());
        }
        return response;
}
}