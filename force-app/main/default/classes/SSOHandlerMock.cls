/*************************************************************************************************************
 * @name			SSOHandlerMock
 * @author			BLR\rohit.pal <rohit.pal@crmit.com>
 * @created			15 / 10 / 2020
 * @description		Description of your code
 *
 * Changes (version)
 * -----------------------------------------------------------------------------------------------------------
 * 				No.		Date			Author					Description
 * 				----	------------	--------------------	----------------------------------------------
 * @version		1.0		2020-10-15		BLR\rohit.pal			Changes desription
 *              1.1     2020-10-30      Alvin Tayag             Changed Response Body to { Id: xx, correlationId: xx }
**************************************************************************************************************/
@isTest
public class SSOHandlerMock implements HttpCalloutMock {
    public Integer statusCode = 201;
    public String uuid = 'xxxxx-xxxxx-xxxxx';

    public SSOHandlerMock(Integer statusCode, String uuid) {
        this.statusCode = statusCode;
        this.uuid = uuid;
    }

    public HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json;charset=UTF-8');
        response.setBody('{"id": "' + uuid + '","correlationId": "yyyy-yyyy-yyyy" }');
        response.setStatusCode(statusCode);
        return response; 
    }
}