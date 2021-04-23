@IsTest
public class eCertControllerTest {
    
    @IsTest
    static void emailTemplateRender(){
        
        EmailTemplate e = TestDataFactory.createEmailTemplate();

        insert e;
        Test.startTest();

        ECertController ecert = new ECertController();
        ecert.recordId = UserInfo.getUserId();
        ecert.templateName = 'Test' + UserInfo.getUserId();
        ecert.prepareTemplate();
        Test.stopTest();

        System.assertEquals(e.HtmlValue, ecert.emailTemplate);
    }
}