public with sharing class eCertController {
    public String emailTemplate { get; set; }
    public String recordId { get; set; }
    public String templateName { get; set; }

    public eCertController() {
        recordId = ApexPages.currentPage().getParameters().get('id');
        templateName = ApexPages.currentPage().getParameters().get('templateName');
        
        if ((!String.isBlank(recordId) && !String.isBlank(templateName)) || Test.isRunningTest()) {
            prepareTemplate();
        }
    }

    @TestVisible
    private void prepareTemplate() {
        List<EmailTemplate> template = [SELECT Id
                                FROM EmailTemplate
                                WHERE Name =: templateName];
            
        if (template.size() > 0) {
            Messaging.SingleEmailMessage contentTemplate = Messaging.renderStoredEmailTemplate(template[0].Id, null, recordId);
            emailTemplate = contentTemplate.getHtmlBody();
        }
    }
}