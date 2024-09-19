/**
* @author        Enuganti Ram
* Class :		 AUSF_DelegatedAuthMock
* Test Class	 
* @date          23-June-2024
* @description   LDAP service used for authentication
* Modification Log:
--------------------------------------------------------------------------------------------
Developer             Date            Description
--------------------------------------------------------------------------------------------
Enuganti Ram        23-June-2024    Initial Version
*/

public class AUSF_DelegatedAuthMock implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) 
    {

        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/xml');
        res.setBody('');
        res.setStatusCode(200);
        System.assertEquals('POST', req.getMethod());
        return res;
    }

}