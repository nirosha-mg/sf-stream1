/*************************************************************************************************************
 * @name			PaymentController
 * @author			BLR\rohit.pal <rohit.pal@crmit.com> Salesforce
 * @created			06 / 10 / 2020
 * @description		Description of your code
 *
 * Changes (version)
 * -----------------------------------------------------------------------------------------------------------
 * 				No.		Date			Author					Description
 * 				----	------------	--------------------	----------------------------------------------
 * @version		1.0		2020-10-06		BLR\rohit.pal			Changes desription
 *              1.1     2020-10-21      Alvin Tayag             Changed helper method to private, removed createRecipt 
 *                                                              and replaced with handlePayment, added emptyReturn handling to helper methods
 *              1.2     2020-01-28      Rob/Poon Koon           Added in methods for getting course info and payment options
 *              1.3     2021-03-25      Poon Koon               1. Add in method to generate signature for request signing
 *                                                              2. Add in method to get ePayment Account No
**************************************************************************************************************/
public without sharing class PaymentController {
    /**
   * @description 
   * @author Rohit Pal | 10-06-2020 
   * @param  null 
   * @return Payment_Gateway__mdt 
   **/
    //2021-03-30 Poon Koon: Get self signed cert name
    @AuraEnabled
    public static Payment_Gateway__mdt getPaymentGateway(){
        
        return [SELECT Id,
                       MasterLabel,
                       Payment_Gateway_URL__c,
                       Payment_Gateway_Return_URL__c,
                       Self_Signed_Cert_Name__c 
                FROM Payment_Gateway__mdt];
    }
    
    @AuraEnabled
    public static List<String> handlePayment (String paymentRecordId) {
        List<String> result = new List<String>();
        if(string.isBlank(paymentRecordId)) {
            result.add('Invalid Record');
            result.add('');
            return result;
        }
        try {
            Payment__c paymentRecord = getPaymentRecord(paymentRecordId);
            if (paymentRecord.Transaction_Status__c == 'Success' && !paymentRecord.Receipt_Created__c) {
                //Create Receipt
                Receipt__c receipt = new Receipt__c();
                Invoice__c invoice = getInvoiceRecord(paymentRecord.Invoice__c);
                receipt.Payment__c = paymentRecord.Id;
                receipt.Amount__c = invoice.Nett_Amount__c - invoice.Advance_Amount__c;
                receipt.GST_Amount__c = invoice.Nett_GST_Amount__c - invoice.Advance_GST_Amount__c;
                insert receipt;

                Payment__c payment = new Payment__c();
                payment.Id = paymentRecordId;
                payment.Receipt_Created__c = true;

                update payment;

                result.add('Success');
                result.add(receipt.Id);
            }
            else if (paymentRecord.Transaction_Status__c == 'Success' && paymentRecord.Receipt_Created__c) {
                //Just show success message and get Receipt Record
                Receipt__c receipt = getReceiptRecord(paymentRecordId);
                result.add('Success');
                result.add(receipt.Id != null ? receipt.Id : paymentRecordId);
            }
            else if (paymentRecord.Transaction_Status__c == 'Failure') {
                //Show error message
                result.add('Failure');
                result.add(paymentRecord.Id);
            }
            else {
                //Catch all Failure
                result.add('Failure');
                result.add(paymentRecord.Id);
            }
        }
        catch (Exception e) {
            result.add('Failure');
            result.add('');
        }

        return result;
    }

    /**
    * @description 
    * @author Rohit Pal | 10-08-2020 
    * @param strPaymentId 
    * @return string 
    **/
    @AuraEnabled
    public static formInformationWrapper getInvoiceRecordInformation(string strInvoiceId){
        formInformationWrapper objformInformationWrapper;
        Invoice__c objInvoice = new Invoice__c();
        Payment__c objPayment = new Payment__c();  

        if(string.isNotBlank(strInvoiceId)){
            objInvoice = getInvoiceRecord(strInvoiceId);
            if (objInvoice.Status__c == 'Paid') {
                objformInformationWrapper = new formInformationWrapper(objInvoice, null);
            }
            else {
                String paymentId = createPaymentRecord(strInvoiceId);
                objPayment = [SELECT Id,
                                    Name,
                                    Invoice__c,
                                    ePayment_Account_No__c
                            FROM Payment__c 
                            WHERE Id =: paymentId limit 1];
                objformInformationWrapper = new formInformationWrapper(objInvoice, objPayment);
            }
        }
        return objformInformationWrapper;
    }

    /**
    * @description 
    * @author Rohit Pal | 10-08-2020 
    * @param strInvoiceId 
    * @return Invoice__c 
    **/
    private static Invoice__c getInvoiceRecord(string strInvoiceId){
        try {
            return [SELECT Id,
                            Name,
                            Amount__c,
                            GST_Amount__c,
                            Nett_Amount__c,
                            Nett_GST_Amount__c,
                            Final_Amount__c,
                            Course_Registration__c,
                            Status__c,
                            Advance_Amount__c,
                            Advance_GST_Amount__c,
                            Course_Registration__r.Course_Run_Id__r.Course__r.Provider__c
                    FROM Invoice__c 
                    WHERE Id =: strInvoiceId limit 1];
        }
        catch (Exception e) {
            return new Invoice__c();
        }
    }
    /**
    * @description 
    * @author Rohit Pal | 10-08-2020 
    * @param strPaymentId 
    * @return Invoice__c 
    **/
    private static Payment__c getPaymentRecord(string strPaymentId){
        try {
        return [SELECT Id,
                        Name,
                        Invoice__c,
                        Transaction_Status__c,
                        Receipt_Created__c
                FROM Payment__c 
                WHERE Id =: strPaymentId limit 1];
        }
        catch (Exception e) {
            return new Payment__c();
        }
    }

    
    private static Receipt__c getReceiptRecord(string strPaymentId){
        //Handle Empty returns
        try {
            return [SELECT Id
                    FROM Receipt__c 
                    WHERE Payment__c =: strPaymentId limit 1];
        }
        catch (Exception e) {
            return new Receipt__c();
        }
    }
    
    //2021-04-01 Poon Koon: To get account no based on course provider
    private static string createPaymentRecord(string strInvoiceId){
        Payment__c objPayment = new Payment__c();
        if(string.isNotBlank(strInvoiceId)){
            invoice__c objInvoice = getInvoiceRecord(strInvoiceId);
            objPayment.ePayment_Account_No__c = getEPaymentAccountNo(objInvoice.Course_Registration__r.Course_Run_Id__r.Course__r.Provider__c);
            objPayment.Transaction_Date__c = system.now();
            objPayment.Invoice__c = objInvoice.id;
            objPayment.Course_Registration__c = objInvoice.Course_Registration__c;
            insert objPayment;
            return objPayment.Id;
        }
        return '';
    }

    //2021-04-01 Poon Koon: To get account no based on course provider
    private static string getEPaymentAccountNo(string strCourseProvider){
        ePayment_Account_No__mdt mdtEPaymentAccountNo = new ePayment_Account_No__mdt();
        if(string.isNotBlank(strCourseProvider)){
            mdtEPaymentAccountNo = [SELECT Id, ePayment_Account_No__c FROM ePayment_Account_No__mdt WHERE Course_Provider__c =: strCourseProvider];
            return mdtEPaymentAccountNo.ePayment_Account_No__c;
        }
        return '';
    }

    /*************************************************************************************************************
     * @name			PaymentController
     * @author			BLR\rohit.pal <rohit.pal@crmit.com> Salesforce
     * @created			08 / 10 / 2020
     * @description		Description of your code
     *
     * Changes (version)
     * -----------------------------------------------------------------------------------------------------------
     * 				No.		Date			Author					Description
     * 				----	------------	--------------------	----------------------------------------------
     * @version		1.0		2020-10-08		BLR\rohit.pal			Changes desription
     *
    **************************************************************************************************************/
    public class formInformationWrapper{

        @AuraEnabled
        public Invoice__c objInvoice {get;set;}
        @AuraEnabled
        public Payment__c objPayment {get;set;}

        public formInformationWrapper(Invoice__c objInvoice  , Payment__c objPayment){
            this.objInvoice = objInvoice;
            this.objPayment = objPayment;
        }
    }
    
    /**************************************************/
    /* 28Jan2021 - Rob - Payment Option Configuration */
    /**************************************************/

    @AuraEnabled
    public static formInformationWrapper1 getCourseRecordInformation(string strInvoiceId){
        formInformationWrapper1 objformInformationWrapper1;
        Course__c objCourse = new Course__c();
        
        String strCourseRegId = getCourseRegId (strInvoiceId);
        String strCourseId = getCourseId (strCourseRegId);

        objCourse = [SELECT Mode_Of_Study__c, Payment_Option__c
                    FROM Course__c
                    WHERE Id =: strCourseId limit 1];
        
        List<picklistValuesWrapper> paymentOptions = getPaymentOptions(objCourse.Mode_Of_Study__c);
        
        objformInformationWrapper1 = new formInformationWrapper1(objCourse, paymentOptions);
        return objformInformationWrapper1;
    }

    public class formInformationWrapper1{

        @AuraEnabled
        public Course__c objCourse {get;set;}
        @AuraEnabled
        public List<picklistValuesWrapper> paymentOptions {get; set;}

        public formInformationWrapper1(Course__c objCourse, List<picklistValuesWrapper> paymentOptions){
            this.objCourse = objCourse;
            this.paymentOptions = paymentOptions;
        }
    }

    public class picklistValuesWrapper{
        @AuraEnabled
        public String label {get; set;}
        @AuraEnabled
        public String value {get; set;}

        public picklistValuesWrapper(String label, String value){
            this.label = label;
            this.value = value;
        }
    }

	/** get CourseRegID **/
	private static string getCourseRegID(string strInvoiceId){
        Course_Registration__c objCourseRegId = new Course_Registration__c();
        Invoice__c objInvoice1 = getInvoiceRecord(strInvoiceId);
        objCourseRegId.Id = objInvoice1.Course_Registration__c;
        return objCourseRegId.Id;
    }
    
    /** get CourseID **/
    private static string getCourseID(string strCourseRegId){
        Course__c objCourseId = new Course__c();
        Course_Registration__c objCourseReg = getCourseRegRecord(strCourseRegId);
        objCourseId.Id = objCourseReg.Course_Run_Id__r.Course__c;
        return objCourseId.Id;
    }

    /** get CourseRegRecord **/
    private static Course_Registration__c getCourseRegRecord(string strCourseRegId){
        //Handle Empty returns
        try {
            return [SELECT Course_Run_Id__r.Course__c
                    FROM Course_Registration__c 
                    WHERE Id =: strCourseRegId limit 1];
        }
        catch (Exception e) {
            return new Course_Registration__c();
        }
    }

    /** get PaymentOptions */
    private static List<picklistValuesWrapper> getPaymentOptions(string strModeOfStudy){
        List<picklistValuesWrapper> listPaymentOptions = New List<picklistValuesWrapper>();
        Map<String, List<String>> mapDependentOptions = Utility.getDependentOptionsImpl(Schema.getGlobalDescribe().get('Course__c').getDescribe().fields.getMap().get('Payment_Option__c'), Schema.getGlobalDescribe().get('Course__c').getDescribe().fields.getMap().get('Mode_Of_Study__c'));
        List<String> listOptions= mapDependentOptions.get(strModeOfStudy);
        for(String option: listOptions) {
            picklistValuesWrapper paymentOption = new picklistValuesWrapper(option.Split('\\|\\|')[0], option.Split('\\|\\|')[1]);
            listPaymentOptions.add(paymentOption);
        }
        return listPaymentOptions;
    }
    
    //2021-03-25 Poon Koon: Method to generate signature
    @AuraEnabled
    public static string generateSignature(string strJSONString, string strCertName){
        Blob data = Blob.valueOf(strJSONString);
        String strSignature = EncodingUtil.base64Encode(System.Crypto.signWithCertificate('RSA-SHA512', data, strCertName));
        return strSignature;
    }
}