/**
* @description       : 
* @author            : Devender Singh
* @group             : 
* @last modified on  : 16-03-2021
* @last modified by  : 
* Modifications Log 
* Ver   Date         Author                                     Modification
* 1.1   2021-04-13   Poon Koon                                  Code Sync with InvoiceUtility (without RMIT Discount logics)
**/
public without sharing class B2BInvoiceUtility {
    
    
    /*@InvocableMethod (Category='Invoice__c' description='Generate Invoice Recordset for a Course Registration' Label='Generate Invoice for Registration')
    public static List<String> generateInvoiceForRegistration (List<Id> courseRegId,) {
        return new List<String> { generateInvoiceForRegistration(courseRegId[0]) };
            }*/

    //MVP1.1:Added by Devender on 16 april 2021, i have added the Promo_Code__C file in the below query ---    
    public static String generateInvoiceForRegistration (Id courseRegId,List<string> listcourseRegId) {
        String invoiceId = '';
        //2021-03-26 Poon Koon: Retrieve fields for B2B registration check and Attention To name logic
        Course_Registration__c courseReg = [SELECT Id,
                                            IsMember__c,
                                            First_Name__c,
                                            Last_Name__c,
                                            Course_Run_Id__c,
                                            Course_Run_Id__r.Course__c,
                                            Course_Run_Id__r.Registration_Close_Date__c,
                                            //2021-04-13 Poon Koon: For Attention To change
                                            Contact__r.Name,
                                            Contact__r.Account.Name,
                                            Contact__r.Account.Id,
                                            //2021-04-13 Poon Koon: For Credit Term calculation
                                            Contact__r.Account.Credit_Term_Days__c,
                                            //2021-04-13 Poon Koon: For Attention To change
                                            Contact__r.Account.RecordType.Name,
                                            RMIT_Alumni__c,
                                            Course_Run_Id__r.Start_Date__c,
                                            Course_Run_Id__r.End_Date__c,
                                            Course_Run_Id__r.Fee_Code__c,
                                            Course_Run_Id__r.Department__c,
                                            Course_Run_Id__r.Cost_Center__c,
                                            //2021-04-13 Poon Koon: For discount calculation
                                            (SELECT Id FROM Learner_Fundings__r),
                                            //2021-04-13 Poon Koon: For Attention To change
                                            Parent_Registration__c,
                                            Parent_Registration__r.Contact__r.Name,
                                            Promo_Code__C
                                            FROM Course_Registration__c
                                            WHERE Id=: courseRegId];
        try {
            //Get Course Info
            Id courseId = courseReg.Course_Run_Id__r.Course__c;
            Course__c courseInfo = getCourseInfo(courseId);
           	
            if (courseInfo.Id != null) {
                Invoice__c invoice = generateInvoice(courseReg);
                //MVP 1.1 2021-04-19 Sanjay: System generated invoice
                invoice.system_Generated__c = true;
                insert invoice;
                invoiceId=invoice.Id;
                system.debug('invoice ---> '+invoice);
                List<Invoice_Line_Item__c> invoiceItems = generateLineItems(listcourseRegId,courseReg, courseInfo, invoiceId);
                
                //MVP 1.1 2021-04-19 Sanjay: Switch on custom setting to bypass validation
                Bypass_Validation_Rule__c bypassVal = Bypass_Validation_Rule__c.getOrgDefaults();
                bypassVal.Bypass_Validation__c = true;
                update bypassVal;
                
                upsert invoiceItems;
                
                //2021-03-24 Poon Koon: Check if there is no Funding, then proceed to perform discount logics
                if(courseReg.Learner_Fundings__r.size() == 0) {
                    List<Discount__c> courseEarlyBirdDiscounts = getCourseEarlyBirdDiscounts(courseId);
                        system.debug(' 57 courseEarlyBirdDiscounts --> '+courseEarlyBirdDiscounts);
                        system.debug(' 58 invoiceItems    --> '+invoiceItems.size());
                    
                    //MVP1.1:Added by Devender on 14 april 2021, Handle Promo Code Discount ---
                    List<Promo_Code__c> PromoCodeDiscounts=getPromoCodeDiscounts(courseReg.Promo_Code__C);
                    system.debug('PromoCodeDiscounts --> '+PromoCodeDiscounts);
                     system.debug('invoiceItems --> '+invoiceItems);
                    if(PromoCodeDiscounts.size() > 0 && invoiceItems.size() > 0) {
                        List<Invoice_Discount__c> invoiceDiscounts = new List<Invoice_Discount__c>();
                        for (Invoice_Line_Item__c lineItem : invoiceItems) {
                            invoiceDiscounts.addAll(generateLineDiscountsForPromoCode(PromoCodeDiscounts, lineItem));
                        }
                        if (invoiceDiscounts.size() > 0) {
                            insert invoiceDiscounts;
                        }
                    } 
                    if (PromoCodeDiscounts.size()<=0 && courseEarlyBirdDiscounts.size() > 0 && invoiceItems.size() > 0) {
                        List<Invoice_Discount__c> invoiceDiscounts = new List<Invoice_Discount__c>();
                        for (Invoice_Line_Item__c lineItem : invoiceItems) {
                            //20210311 Poon Koon - Update early bird calculation based on course run start date
                            invoiceDiscounts.addAll(generateLineDiscounts(courseEarlyBirdDiscounts, lineItem, courseReg.Course_Run_Id__r.Start_Date__c));
                        }
                        if (invoiceDiscounts.size() > 0) {
                            insert invoiceDiscounts;
                        }
                    }
                }
                
                //MVP 1.1 2021-04-19 Sanjay: Switch off bypas validation custom setting
				bypassVal.Bypass_Validation__c = false;
                update bypassVal;
                
                invoiceId = invoice.Id;
                list<Course_Registration__c> UpdatecourseRegIssued=New list<Course_Registration__c> ();
                listcourseRegId.add(courseRegId);
                for(string courseRegtarId: listcourseRegId){
                    Course_Registration__c courseRegIssued = new Course_Registration__c();
                    courseRegIssued.Id = courseRegtarId;
                    courseRegIssued.Payment_Status__c = 'Invoice Issued';
                    UpdatecourseRegIssued.add(courseRegIssued);
                }
                if(UpdatecourseRegIssued.size()>0){
                     update UpdatecourseRegIssued;
                }
               
            }
        }
        catch (Exception e) {
            //2021-03-22 Poon Koon: Update debug log        
            System.debug(e.getMessage() + '\n' + e.getStackTraceString());
            //2021-04-13 Poon Koon: To reflect B2BInvoiceUtility Class
            insert AppLogUtility.createApplicationLog(e.getMessage() + '\n' + e.getStackTraceString(), 'B2BInvoiceUtility', courseRegId);
        }
        
        
        return invoiceId;
    }
    
    private static Invoice__c generateInvoice(Course_Registration__c courseReg) {
        Id regInvoiceRT = Schema.SObjectType.Invoice__c.getRecordTypeInfosByDeveloperName().get('Registration_Invoice').getRecordTypeId();
        Invoice__c invoice = new Invoice__c();
        invoice.Course_Registration__c = courseReg.Id;
        invoice.Status__c = 'Draft';
        //2021-03-26 Poon Koon: Check if Account belongs to B2B Account
        if(courseReg.Contact__r.Account.RecordType.Name == 'B2B Account') {
            if(courseReg.Parent_Registration__c != null) {
                invoice.Attention_To__c = courseReg.Parent_Registration__r.Contact__r.Name;
            }
            else {
                invoice.Attention_To__c = courseReg.Contact__r.Name;
            }
        }
        else {
            invoice.Attention_To__c = courseReg.Contact__r.Account.Name;
        }
        invoice.Bill_Date__c = Date.today();
        // rob - 16FEB20 - increase bill due date from 7 days to 14 days
        // 2021-03-19 Poon Koon: Update Bill Due Date Calculation to use Account Credit Term (Days)
        //invoice.Bill_Due_Date__c = Date.today().addDays(7);
        //invoice.Bill_Due_Date__c = Date.today().addDays(14);
        invoice.Bill_Due_Date__c = Date.today().addDays(Integer.valueOf(courseReg.Contact__r.Account.Credit_Term_Days__c));
        
        invoice.RecordTypeId = regInvoiceRT;
        invoice.Account__c = courseReg.Contact__r.Account.Id;
        return invoice;
    }
    
    private static List<Invoice_Line_Item__c> generateLineItems(List<string> listcourseRegId,Course_Registration__c courseReg, Course__c courseInfo, Id invoiceId) {
    
        system.debug('listcourseRegId   --> '+listcourseRegId);
        system.debug('courseReg   --> '+courseReg);
        system.debug('courseInfo   --> '+courseInfo);
        system.debug('invoiceId   --> '+invoiceId);
        
        list<Invoice_Line_Item__c> lineItems = new list<Invoice_Line_Item__c>();
        
        //map<id,Invoice_Line_Item__c> mapOfInvoiceLineItem=new  map<id,Invoice_Line_Item__c>();
        Id fundedSSGCourseRT = Schema.SObjectType.Course__c.getRecordTypeInfosByDeveloperName().get('Funded_Course').getRecordTypeId();
        Id courseRT = Schema.SObjectType.Course__c.getRecordTypeInfosByDeveloperName().get('Course').getRecordTypeId();
        
        String feeCode = courseReg.Course_Run_Id__r.Fee_Code__c; //Replace with Course Run
        String department = courseReg.Course_Run_Id__r.Department__c;
        String costCenter = courseReg.Course_Run_Id__r.Cost_Center__c;
        String gstCode = courseInfo.GST_Code__c;
        String gstMode = courseInfo.GST_Mode__c; //If Full, then GST is on top of course Fee
        //If Nett, then deduct GST from course Fee
        String courseName = courseInfo.Name;
        Decimal courseFee = 0;
        Decimal gstFee = 0;
        
        
        
        if (courseInfo.RecordTypeId == fundedSSGCourseRT) {
            //Use Full Fee
            courseFee = courseInfo.Full_Fee__c;
            gstFee = courseInfo.Full_Fee_GST_Amount__c; 
        }
        else if (courseInfo.RecordTypeId == courseRT) {
            //Use Member/Non-Member Fee
            //check RMIT Fee
            //Use RMIT fee if provider == RMIT
            /*if (courseInfo.Provider__c == 'RMIT') {
courseFee = courseReg.RMIT_Alumni__c ? courseInfo.RMIT_Alumni_Fee__c : courseInfo.Non_Member_Fee__c;
gstFee = courseReg.RMIT_Alumni__c ? courseInfo.RMIT_Alumni_GST_Fee__c : courseInfo.Non_Member_GST_Fee__c;
}
else {*/
            courseFee = (courseReg.IsMember__c) ? courseInfo.Member_Fee__c : courseInfo.Non_Member_Fee__c;
            gstFee = (courseReg.IsMember__c) ? courseInfo.Member_GST_Fee__c : courseInfo.Non_Member_GST_Fee__c;
            //}
        }
        
        system.debug('listcourseRegId --> '+listcourseRegId);
        // 20210408 Poon Koon: Update SOQL to exclude Deferred and Withdrawn regs too
        List<Course_Registration__c> childRegistrations = [SELECT Id, 
                                                           First_Name__c, 
                                                           Last_Name__c,
                                                           Course_Run_Id__c,
                                                           Course_Run_Id__r.Fee_Code__c,
                                                           Course_Run_Id__r.Department__c,
                                                           Course_Run_Id__r.Cost_Center__c 
                                                           FROM Course_Registration__c 
                                                           WHERE Id IN: listcourseRegId
                                                           AND Registration_Status__c NOT IN ('Cancelled', 'Deferred', 'Withdrawn')];
        
        //AND Registration_Status__c!='Cancelled'
        
        system.debug(' 139 childRegistrations --> '+childRegistrations);
        
        /*for (Invoice_Line_Item__c InvoiceLinItm : [SELECT Id,Course_Registration__c,Invoice__c FROM Invoice_Line_Item__c  WHERE Course_Registration__c IN :listcourseRegId]) { 
mapOfInvoiceLineItem.put(InvoiceLinItm.Course_Registration__c,InvoiceLinItm);
}*/
        
        //If there are child registrations then the line items are to be based on the registrations
        if (childRegistrations.size() > 0) {
            for (Course_Registration__c reg : childRegistrations) {
                //Create Line item for Programme Fee
                Invoice_Line_Item__c lineItem = new Invoice_Line_Item__c();
                lineItem.Invoice__c = invoiceId;
                /*if(mapOfInvoiceLineItem.size()>0){
if(!mapOfInvoiceLineItem.containsKey(reg.Id))
lineItem.id= mapOfInvoiceLineItem.get(reg.Id).Id;  
}*/
                lineItem.Course_Registration__c=reg.Id;
                lineItem.Amount__c = courseFee;
                lineItem.GST_Amount__c = gstFee;
                lineItem.GST_Code__c = gstCode;
                lineItem.GST_Mode__c = gstMode;    
                lineItem.Cost_Center__c = reg.Course_Run_Id__r.Cost_Center__c;
                lineItem.Department__c = reg.Course_Run_Id__r.Department__c;
                lineItem.Fee_Code__c = reg.Course_Run_Id__r.Fee_Code__c;
                lineItem.Course_Run__c = reg.Course_Run_Id__c;
                lineItem.Participant_Name__c = reg.First_Name__c + ' ' + reg.Last_Name__c;
                //lineItem.Description__c = 'Fee for ' + courseInfo.Name + ' - ' + lineItem.Participant_Name__c;
                lineItem.Description__c = courseInfo.Course_Title__c + '\n';
                if (courseInfo.Course_Type__c != 'Self-Paced') {
                    lineItem.Description__c += courseReg.Course_Run_Id__r.Start_Date__c.format() + '-' + courseReg.Course_Run_Id__r.End_Date__c.format();
                }
                
                //MVP 1.1 2021-04-19 Sanjay: System generated invoice line item
                lineItem.system_Generated__c= true;
                
                lineItems.add(lineItem);
            }
        }
        else {
            //Create Line item for Programme Fee
            /* Invoice_Line_Item__c lineItem = new Invoice_Line_Item__c();
lineItem.Invoice__c = invoiceId;
lineItem.Amount__c = courseFee;
lineItem.GST_Amount__c = gstFee;
lineItem.GST_Code__c = gstCode;
lineItem.GST_Mode__c = gstMode;
lineItem.Course_Registration__c=childRegistrations[0].Id;
lineItem.Cost_Center__c = costCenter;
lineItem.Department__c = department;
lineItem.Fee_Code__c = feeCode;
lineItem.Course_Run__c = courseReg.Course_Run_Id__c;
lineItem.Participant_Name__c = courseReg.First_Name__c + ' ' + courseReg.Last_Name__c;
//lineItem.Description__c = 'Fee for ' + courseInfo.Name;
lineItem.Description__c = courseInfo.Course_Title__c + '\n';
if (courseInfo.Course_Type__c != 'Self-Paced') {
lineItem.Description__c += courseReg.Course_Run_Id__r.Start_Date__c.format() + '-' + courseReg.Course_Run_Id__r.End_Date__c.format();                
}
lineItems.add(lineItem);*/
        }
        
        return lineItems;
    }
    
    //Create Invoice_Discount record for Early Birds
    private static List<Invoice_Discount__c> generateLineDiscounts(List<Discount__c> courseDiscounts, Invoice_Line_Item__c lineItem, Date registrationCloseDate) {
        List<Invoice_Discount__c> discs = new List<Invoice_Discount__c>();
        
        for (Discount__c cdisc : courseDiscounts) {
            //20210311 Poon Koon - Assign zero to No_of_Days__c if it is null
            if (cdisc.No_of_Days__c == null) {
                cdisc.No_of_Days__c = 0;
            }
            //20210312 Poon Koon - Assign zero to GST_Amount__c if it is null
            if (cdisc.GST_Amount__c == null) {
                cdisc.GST_Amount__c = 0;
            }
            Integer noOfDays = Integer.valueOf(cdisc.No_of_Days__c) * -1;
             system.debug(' 221 noOfDays    							   --> '+noOfDays);
             system.debug(' 222 registrationCloseDate.addDays(noOfDays)    --> '+registrationCloseDate.addDays(noOfDays));
             system.debug(' 223 Date.today()							   --> '+Date.today());
            if (Date.today() <= registrationCloseDate.addDays(noOfDays)) {
               
                Invoice_Discount__c disc = new Invoice_Discount__c();
                disc.Amount__c = (cdisc.Percentage__c) ? 
                    (lineItem.Amount__c * (cdisc.Amount__c / 100)) : 
                (cdisc.Amount__c);
                //2021-03-22 Poon Koon: Patch Amount calculation of Invoice Discount to 2 decimal places
                disc.Amount__c = disc.Amount__c.setScale(2, RoundingMode.HALF_UP);
                    disc.GST_Amount__c = (cdisc.Percentage__c) ? 
                    (disc.Amount__c * (cdisc.GST_Amount__c / 100)) : 
                (cdisc.GST_Amount__c);
                    disc.Invoice_Line_Item__c = lineItem.Id;
                disc.GST_Code__c = cdisc.GST_Code__c;
                disc.GST_Mode__c = lineItem.GST_Mode__c;
                disc.Discount__c = cdisc.Id;
                
                //MVP 1.1 2021-04-19 Sanjay: System generated discount
                disc.System_Generated__c = true;
                
                discs.add(disc);
            }
        }
        
        return discs;
    }
    //MVP1.1:Added by Devender on 14 april 2021, i have added the Member_Total_Fee__c,Non_Member_Total_Fee__c field in the below query ---
    private static Course__c getCourseInfo (Id courseId) {
        List<Course__c> courseInfo = [SELECT Name,
                                      Fee_Code__c,
                                      Department__c,
                                      Cost_Center__c,
                                      GST_Code__c,
                                      GST_Mode__c,
                                      Full_Fee__c,
                                      Full_Fee_GST_Amount__c,
                                      Member_Fee__c,
                                      Member_GST_Fee__c,
                                      Non_Member_Fee__c,
                                      Non_Member_GST_Fee__c,
                                      RMIT_Alumni_GST_Fee__c,
                                      RMIT_Alumni_Fee__c,
                                      RecordTypeId,
                                      Provider__c,
                                      Course_Title__c,
                                      Course_Type__c,
                                      Member_Total_Fee__c,
                                      Non_Member_Total_Fee__c
                                      FROM Course__c
                                      WHERE Id=:courseId];
        
        return courseInfo.size() > 0 ? courseInfo[0] : new Course__c();
    }
    
    private static List<Discount__c> getCourseEarlyBirdDiscounts(Id courseId) {
        Id earlyBirdRT = Schema.SObjectType.Discount__c.getRecordTypeInfosByDeveloperName().get('Early_Bird').getRecordTypeId();
        
        List<Id> discIds = new List<Id>();
        for (Course_Discount__c cdisc : [SELECT Discount__c FROM Course_Discount__c WHERE Course__c =: courseId AND Discount__r.RecordTypeId =: earlyBirdRT]) {
            discIds.add(cdisc.Discount__c);
        }
        
        List<Discount__c> courseDiscounts = [SELECT Amount__c, 
                                             GST_Amount__c,
                                             Percentage__c, 
                                             No_of_Days__c, 
                                             Valid_From__c, 
                                             Valid_To__c,
                                             GST_Code__c
                                             FROM Discount__c
                                             WHERE Id =: discIds];
        
        return courseDiscounts;
    }
    // MVP1.1:Added by Devender on 14 april 2021 for apply the promo code discount START -- 
    private static List<Invoice_Discount__c> generateLineDiscountsForPromoCode(List<Promo_Code__c> PromoCodeDiscounts, Invoice_Line_Item__c lineItem) {
        List<Invoice_Discount__c> discs = new List<Invoice_Discount__c>();
        decimal dAmount=0;
        for (Promo_Code__c cPro : PromoCodeDiscounts) {
            if(cPro.Discount_Type__c=='Percent'){
                dAmount=((lineItem.Amount__c+lineItem.GST_Amount__c)*cPro.Discount_Percentage__c/100);
            }
            else
                dAmount=cPro.Discount_Amount__c; 
            decimal gst=0;
            if(lineItem.GST_Code__c=='12')
                gst=7;
            
            Invoice_Discount__c disc = new Invoice_Discount__c();
            if(gst==7){
                decimal dGstRate=100+integer.valueOf(gst);
                system.debug('final dGstRate --> '+dGstRate);
                decimal finalrate=(dGstRate/100);
                system.debug('final dGstRate /100 --> '+dAmount);
                disc.Amount__c = (dAmount/finalrate);
                disc.Amount__c = disc.Amount__c.setScale(2, RoundingMode.HALF_UP);
                disc.GST_Amount__c = dAmount-disc.Amount__c;
            }else{
                disc.Amount__c = dAmount.setScale(2, RoundingMode.HALF_UP);
                disc.GST_Amount__c =0; 
            }
            disc.Invoice_Line_Item__c = lineItem.Id;
            disc.GST_Code__c = lineItem.GST_Code__c;
            disc.GST_Mode__c = lineItem.GST_Mode__c;
            disc.Promo_Code__c=cPro.Id;
            //MVP 1.1 2021-04-19 Sanjay: System generated discount
            disc.System_Generated__c = true;
            
            discs.add(disc);
        }
        return discs;
    }
    private static List<Promo_Code__c> getPromoCodeDiscounts(Id promoCodeId) {
        List<Promo_Code__c> PromoCodes = [SELECT Id, Is_Active__c, Start_Date__c, End_Date__c, Discount_Type__c, 
                                          Discount_Amount__c, Discount_Percentage__c, Course__c, Account__c, 
                                          Applicable_on__c FROM Promo_Code__c where Id =:promoCodeId];
        return PromoCodes;
    }
}