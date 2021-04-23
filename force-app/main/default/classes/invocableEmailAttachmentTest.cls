@isTest
public class invocableEmailAttachmentTest {

    @isTest static void sendEmailSendTo() {
    
    List<Account> accList = new List<Account>();
    List<opportunity> oppList = new List<opportunity>();
    
    Account acc = new Account();
    acc.Name = 'Knights watch';
    insert acc;
    accList.add(acc);
    
    Opportunity o = new opportunity();
    o.Name = 'Iron bank';
    o.StageName = 'Needs Analysis';
    o.AccountId = acc.Id;
    o.Amount = 2000;
    o.CloseDate = system.Date.today();
    insert o;
    oppList.add(o);
    
    attachment att = new attachment();
    att.Name = 'Test attachment';
    Blob bodyBlob = Blob.valueOf('Unit Test Attachment Body');
    att.Body = bodyBlob;
    att.ParentId = o.Id;
    insert att;
    
    string myEmail = 'anytestEmailID@gmail.com';
    string emailBody = 'this is the email body';
    string emailSubject = 'this is subject';
    List<invocableEmailAttachment.flowInput> inputList = new List<invocableEmailAttachment.flowInput>();
    List<Attachment> finalAttachmentList = [select id, name from Attachment where parentId =:o.Id];
    
    invocableEmailAttachment.flowInput input;
    input = new invocableEmailAttachment.flowInput();
    input.eMail = myEmail;
    input.ccMail = myEmail;
    input.currentRecordId = o.Id;
    input.eSubject = emailSubject;
    input.ebody = emailBody;
    inputList.add(input);
    
    invocableEmailAttachment.currentRecordID(inputList);
    
    integer invocation = limits.getEmailInvocations();
    
    system.assertEquals(1, invocation);
    system.assertEquals(1, finalAttachmentList.size());
    
    }
    
}