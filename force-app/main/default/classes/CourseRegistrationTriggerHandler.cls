public class CourseRegistrationTriggerHandler {
    
    public static void CourseRegistrationMethod(list<Course_Registration__c> newCourse){
        Map<Decimal,string> nricMap = returnNRICGrid();
        Map<Decimal,string> nricMapone = returnNRICGrid_F();
        
        for(Course_Registration__c cr:newCourse)
        {
            if(cr.NRIC_Type__c == 'Singapore Citizen/PR' || cr.NRIC_Type__c == 'FIN') {
                string nric = cr.NRIC__c;
                if(String.isNotBlank(nric)) {
                    if(nric.length() != 9) {
                        cr.NRIC__c.addError('Invalid NRIC');
                    }
                    else if(validateNRIC(nric) == true && 
                            (nric.substring(0,1)=='S'||nric.substring(0,1)=='T'||nric.substring(0,1)=='F'||nric.substring(0,1)=='G')){
                                Integer nricsum = 2*Integer.valueOf(nric.substring(1,2)) +
                                    7*Integer.valueOf(nric.substring(2, 3)) +
                                    6*Integer.valueOf(nric.substring(3, 4)) +
                                    5*Integer.valueOf(nric.substring(4, 5)) +
                                    4*Integer.valueOf(nric.substring(5,6)) +
                                    3*Integer.valueOf(nric.substring(6, 7)) +
                                    2*Integer.valueOf(nric.substring(7, 8));       
                                if(nric.substring(0,1) == 'S') {
                                    Integer nricremainder = Math.mod(nricsum , 11);   
                                    if(nricMap.containskey(nricremainder) &&  nricMap.get(nricremainder)!= null &&
                                       nricMap.get(nricremainder) != nric.substring(8, 9)) {
                                           cr.NRIC__c.addError('NRIC/FIN is not valid ');
                                       }
                                }
                                if(nric.substring(0,1) == 'T') {
                                    Integer nricremainder = Math.mod(nricsum+4, 11);               
                                    if(nricMap.containskey(nricremainder) &&  nricMap.get(nricremainder)!= null &&
                                       nricMap.get(nricremainder) != nric.substring(8, 9)) {
                                           cr.NRIC__c.addError('NRIC/FIN is not valid ');
                                       }
                                }
                                if(nric.substring(0,1) == 'F') {
                                    Integer nricremainder=Math.mod(nricsum , 11);               
                                    if(nricMapone.containskey(nricremainder) &&  nricMapone.get(nricremainder)!= null &&
                                       nricMapone.get(nricremainder) != nric.substring(8, 9)) {
                                           cr.NRIC__c.addError('NRIC/FIN is not valid ');
                                       }
                                }
                                if(nric.substring(0,1)=='G'){
                                    Integer nricremainder=Math.mod(nricsum+4, 11);               
                                    if(nricMapone.containskey(nricremainder) &&  nricMapone.get(nricremainder)!= null &&
                                       nricMapone.get(nricremainder) != nric.substring(8, 9)) {
                                           cr.NRIC__c.addError('NRIC/FIN is not valid ');
                                       }
                                }       
                            }
                }
            }}}
    
    public static Map<Decimal,string> returnNRICGrid() {
        Map<Decimal,string> nricMap = new map<Decimal,string>();
        for(NRIC_Details__mdt nr : [select Check_Digit__c,Alphabet__c from NRIC_Details__mdt where Initial_Letter__c=:'S']) {
            nricMap.put(nr.Check_Digit__c,nr.Alphabet__c);
        }
        return nricMap;
    }
    public static Map<Decimal,string> returnNRICGrid_F() {   
        Map<Decimal,string> nricMap = new map<Decimal,string>();   
        for(NRIC_Details__mdt nr : [select Check_Digit__c,Alphabet__c from NRIC_Details__mdt where Initial_Letter__c=:'F']) {
            nricMap.put(nr.Check_Digit__c,nr.Alphabet__c);
        }
        return nricMap;
    }
    
    public static boolean validateNRIC(string nricVal) {
        Boolean result = false;
        String nricRegex = '[S F T G][0-9]{7}[A-Z]';
        Pattern nricPattern = Pattern.compile(nricRegex);
        Matcher nricMatcher = nricPattern.matcher(nricVal);
        if(nricMatcher.matches()) {
            result = true;
        }
        return result;
        
    }
    
    public static void createB2BUser(list<Course_Registration__c> courseList) { 
        Map<id,course_registration__c> contactWithRegIdMap = new Map<id,course_registration__c>();
        set<String> regWithEmailSet = new set<String>();
        Map<string,id> contactEmailMap = new Map<String,id>();
        Map<id,contact> contactMapToUpdate = new Map<id,contact>();
        set<id> parentContactSet = new set<id>();
        Map<String,contact> contactMapToInsert = new Map<string,contact>();     
        List<course_registration__c> courseRegListToUpdate = new list<course_registration__c>();
        Map<id,course_registration__c> accountIdMap = new Map<id,course_registration__c>();
        List<account> accountListToUpdate = new List<account>();
        set<id> parentIds = new set<id>();
        Map<id,id> parentRegistrationMap = new Map<id,id>();
        Map<id,id> userMap = new Map<id,id>();
        
        for(Course_Registration__c cr : courseList) {
            if(cr.contact__c != null) {
                contactWithRegIdMap.put(cr.contact__c, cr);
                accountIdMap.put(cr.contact__r.accountid,cr);
            } else if(cr.Email_Address__c != null && cr.contact__c == null) {
                regWithEmailSet.add(cr.Email_Address__c);
            } 
            
            if(cr.Parent_Registration__c != null && cr.contact__c == null ) {
                parentIds.add(cr.Parent_Registration__c);
                
            }
        }      
        
        for(contact con : [select id,email from contact where email in : regWithEmailSet]) {
            contactEmailMap.put(con.email, con.id);
        }
        
        if(parentIds.size() > 0) {
            for(course_registration__c crParent : [select id,contact__c,parent_registration__c from course_registration__c 
                                                   where id in : parentIds]) {
                                                       parentContactSet.add(crParent.contact__c);
                                                       parentRegistrationMap.put(crParent.id,crParent.contact__c);
                                                   }
            
            Map<id,contact> parentContactMap = new Map<id,Contact>([select id,accountid,email from contact where id in : parentContactSet]);                   
            
            
            for(Course_Registration__c cReg : courseList) {
                set<string> emailSet = new set<string>();
                if(cReg.Parent_Registration__c != null && cReg.contact__c == null && 
                   !contactEmailMap.containskey(cReg.Email_Address__c) && 
                   !emailSet.contains(cReg.Email_Address__c)) {
                       contact con = new contact();
                       con.firstname = cReg.first_name__c;
                       con.lastname = cReg.last_name__c;
                       con.email = cReg.email_address__c;
                       con.Salutation = cReg.Salutation__c;
                       
                       if(parentRegistrationMap.containskey(cReg.parent_registration__c) && 
                          parentRegistrationMap.get(cReg.parent_registration__c) != null &&
                          parentContactMap.containskey(parentRegistrationMap.get(cReg.parent_registration__c)) && 
                          parentContactMap.get(parentRegistrationMap.get(cReg.parent_registration__c)).accountid != null) {
                              con.accountid = parentContactMap.get(parentRegistrationMap.get(cReg.parent_registration__c)).accountid;
                          } 
                       emailSet.add(cReg.email_address__c);
                       contactMapToInsert.put(con.email,con);  
                   }
            }
            
            if(contactMapToInsert.size() > 0 ) {
                insert contactMapToInsert.values();  
                for(contact c :contactMapToInsert.values()) {
                    contactEmailMap.put(c.email,c.id);
                }
            }
            
        }
        
        for(user u :[select id,contactid from user where contactid in : parentContactSet OR contactid in : contactEmailMap.values()]) {
            userMap.put(u.contactid,u.id);
        }
        // Poon Koon 3/2/2021: Added in consent fields during query
        // Poon Koon 2021-04-22: Added in marketing channel field during query
        for(Course_Registration__c crReg : [select id,contact__c,contact__r.accountid,email_address__c,attention__c,Alternative_Attention__c,
                                            Alternative_Billing_Line_1__c,Alternative_Billing_Line_2__c,Alternative_Billing_Line_3__c,
                                            Alternative_City__c,Alternative_Country__c,Alternative_Email__c,Alternative_Phone__c,
                                            Alternative_Postal_Code__c,Alternative_State__c,Billing_Address_Line_1__c,
                                            Billing_Address_Line_3__c, Billing_Address_Line_2__c,Billing_City__c,Billing_Country__c,
                                            Billing_Postal_Code__c,Billing_State__c,Date_of_Birth__c,Designation_Level__c,Designation__c,
                                            Education_Level__c,Employment_Status__c,First_Name__c,Gender__c,Last_Name__c,
                                            Mobile_No__c,Monthly_Basic_Salary__c,NRIC_Type__c,NRIC__c,Nationality__c,Office_No__c,P_O_Number__c,
                                            Persons_with_Disabilities__c,Home_No__c,Preferred_Certificate_Name__c,Primary_Email_Address__c,
                                            RMIT_Alumni__c,Race__c,Remarks__c,Residency_Status__c,Salutation__c,Secondary_Email_Address__c,
                                            Secondary_Mobile__c,Secondary_Salutation__c,job_title__c,Address_Type__c,ownerid,How_did_you_get_to_know_us__c,
                                            Sync_Learner_s_Record__c, Preferred_Contact_Method__c, Marketing_Consent_Clause__c, PDPA_Consent_Clause__c,
                                            Marketing_Channel_Email__c, Marketing_Channel_Post__c, Marketing_Channel_Telephone_call__c, Marketing_Channel_Text_Messages__c
                                            from Course_Registration__c
                                            where id in : courseList]) {
                                                if(contactEmailMap.containskey(crReg.email_address__c)) {
                                                    crReg.contact__c = contactEmailMap.get(crReg.email_address__c);                    
                                                } 
                                                if(userMap.containskey(crReg.contact__c) && userMap.get(crReg.contact__c) != null) {  
                                                    crReg.ownerid = userMap.get(crReg.contact__c);
                                                }
                                                courseRegListToUpdate.add(crReg);
                                                contactWithRegIdMap.put(crReg.contact__c, crReg);
                                                accountIdMap.put(crReg.contact__r.accountid,crReg);     
                                            }
        
        if(courseRegListToUpdate.size() > 0 ) {
            update courseRegListToUpdate;
        }         
        
        for(contact conRec : [select id,Alternative_Attention__c,Alternative_Billing_Address1__c,Alternative_Billing_Address2__c,
                              Alternative_Billing_Address3__c,Alternative_City__c,Alternative_Country__c,Alternative_Email__c,
                              Alternative_Phone__c,Alternative_PostalCode__c,Alternative_State__c,Attention__c,Billing_Address_Line_1__c,
                              Billing_Address_Line_2__c,Billing_Address_Line_3__c,Billing_City__c,Billing_Country__c,Billing_Postal_Code__c,
                              Billing_State__c,Date_of_Birth__c,Designation_Level__c,Designation__c,Education_Level__c,Email,Employment_Status__c,
                              FirstName,Gender__c,LastName,MobilePhone,Monthly_Basic_Salary__c,NRIC_Type__c,NRIC__c,Nationality__c,Office_No__c,
                              P_O_Number__c,Persons_with_Disabilities__c,Phone,Preferred_Certificate_Name__c,Primary_Email_Address__c,RMIT_Alumni__c,
                              Race__c,Remarks__c,Residency_Status__c,Salutation,Secondary_Email_Address__c,Secondary_Mobile_Number__c,
                              Secondary_Salutation__c,Title, How_did_you_get_to_know_us__c from contact where id in : contactWithRegIdMap.keyset()]) {
                                  if(contactWithRegIdMap.get(conRec.id).Sync_Learner_s_Record__c == true) {               
                                      conRec = updateContactFields(conRec,contactWithRegIdMap.get(conRec.id));
                                      contactMapToUpdate.put(conRec.id,conRec);
                                  }
                                  
                              } 
        
        if(contactMapToUpdate.size() > 0) {
            update contactMapToUpdate.values();
        }
        
        for(Account acc :[select id,Address_Type__c,Billing_Address_Line_1__c,Billing_Address_Line_2__c,Billing_Address_Line_3__c,
                          Billing_City__c,Billing_Contact_Person__c,Billing_Country__c,Billing_Postal_Code__c,Billing_State__c,
                          Preferred_Contact_Method__c,ispersonAccount from account where id in : accountIdMap.keyset()]) {
                              if(accountIdMap.get(acc.id).Sync_Learner_s_Record__c == true) {
                                  if(acc.ispersonAccount == true) {
                                      acc.Billing_Contact_Person__c = accountIdMap.get(acc.id).attention__c;
                                      acc.Address_Type__c = accountIdMap.get(acc.id).Address_Type__c;
                                      acc.Billing_Address_Line_1__c = accountIdMap.get(acc.id).Billing_Address_Line_1__c;
                                      acc.Billing_Address_Line_2__c = accountIdMap.get(acc.id).Billing_Address_Line_2__c;
                                      acc.Billing_Address_Line_3__c = accountIdMap.get(acc.id).Billing_Address_Line_3__c;
                                      acc.Billing_City__c = accountIdMap.get(acc.id).Billing_City__c;
                                      acc.Billing_Country__c = accountIdMap.get(acc.id).Billing_Country__c;
                                      acc.Billing_Postal_Code__c = accountIdMap.get(acc.id).Billing_Postal_Code__c;
                                      acc.Billing_State__c = accountIdMap.get(acc.id).Billing_State__c;
                                      acc.Preferred_Contact_Method__c = accountIdMap.get(acc.id).Preferred_Contact_Method__c;
                                  } else {
                                      acc.Billing_Contact_Person__c = accountIdMap.get(acc.id).attention__c;
                                  }
                                  accountListToUpdate.add(acc);  
                              }           
                          }
        
        if(accountListToUpdate.size() > 0) {
            update accountListToUpdate;
        }
    }
    
    public static contact updateContactFields(contact contactRec,course_registration__c courseReg) {
        contact con = contactRec;
        con.Alternative_Attention__c =  courseReg.Alternative_Attention__c;
        con.Alternative_Billing_Address1__c = courseReg.Alternative_Billing_Line_1__c;
        con.Alternative_Billing_Address2__c = courseReg.Alternative_Billing_Line_2__c;
        con.Alternative_Billing_Address3__c = courseReg.Alternative_Billing_Line_3__c;
        con.Alternative_City__c = courseReg.Alternative_City__c;
        con.Alternative_Country__c = courseReg.Alternative_Country__c;
        con.Alternative_Email__c = courseReg.Alternative_Email__c;
        con.Alternative_Phone__c = courseReg.Alternative_Phone__c;
        con.Alternative_PostalCode__c = courseReg.Alternative_Postal_Code__c;
        con.Alternative_State__c = courseReg.Alternative_State__c;
        con.Attention__c = courseReg.Attention__c;      
        con.Billing_Address_Line_1__c = courseReg.Billing_Address_Line_1__c;
        con.Billing_Address_Line_2__c = courseReg.Billing_Address_Line_2__c;
        con.Billing_Address_Line_3__c = courseReg.Billing_Address_Line_3__c;
        con.Billing_City__c = courseReg.Billing_City__c;
        con.Billing_Country__c = courseReg.Billing_Country__c;
        con.Billing_Postal_Code__c = courseReg.Billing_Postal_Code__c;
        con.Billing_State__c = courseReg.Billing_State__c;
        con.Date_of_Birth__c = courseReg.Date_of_Birth__c;
        con.Designation_Level__c = courseReg.Designation_Level__c;
        con.Designation__c = courseReg.Designation__c;
        con.Education_Level__c = courseReg.Education_Level__c;
        con.Email = courseReg.Email_address__c;
        con.Employment_Status__c = courseReg.Employment_Status__c;
        con.FirstName = courseReg.First_Name__c;
        con.Gender__c = courseReg.Gender__c;
        con.LastName = courseReg.Last_Name__c;
        con.MobilePhone = courseReg.Mobile_No__c;
        con.Monthly_Basic_Salary__c = courseReg.Monthly_Basic_Salary__c;
        con.NRIC_Type__c = courseReg.NRIC_Type__c;
        con.NRIC__c = courseReg.NRIC__c;
        con.Nationality__c = courseReg.Nationality__c;
        con.Office_No__c = courseReg.Office_No__c;
        con.P_O_Number__c = courseReg.P_O_Number__c;
        con.Persons_with_Disabilities__c = courseReg.Persons_with_Disabilities__c;
        con.Phone = courseReg.Home_No__c;
        con.Preferred_Certificate_Name__c = courseReg.Preferred_Certificate_Name__c;
        con.Primary_Email_Address__c = courseReg.Primary_Email_Address__c;
        con.RMIT_Alumni__c = courseReg.RMIT_Alumni__c;
        con.Race__c = courseReg.Race__c;
        con.Remarks__c = courseReg.Remarks__c;
        con.Residency_Status__c = courseReg.Residency_Status__c;
        con.Salutation = courseReg.Salutation__c;
        con.Secondary_Email_Address__c = courseReg.Secondary_Email_Address__c;
        con.Secondary_Mobile_Number__c = courseReg.Secondary_Mobile__c;
        con.Secondary_Salutation__c = courseReg.Secondary_Salutation__c;
        con.Title = courseReg.job_title__c;
        con.How_did_you_get_to_know_us__c = courseReg.How_did_you_get_to_know_us__c;
        // Poon Koon 3/2/2021: Sync consent fields
        con.Marketing_Consent_Clause__c = courseReg.Marketing_Consent_Clause__c;
        con.How_did_you_get_to_know_us__c = courseReg.How_did_you_get_to_know_us__c;
        con.PDPA_Consent_Clause__c = courseReg.PDPA_Consent_Clause__c;   
        // Poon Koon 2021-04-22: Sync marketing channel fields
        con.Marketing_Channel_Email__c = courseReg.Marketing_Channel_Email__c;
        con.Marketing_Channel_Post__c = courseReg.Marketing_Channel_Post__c;
        con.Marketing_Channel_Telephone_call__c = courseReg.Marketing_Channel_Telephone_call__c;
        con.Marketing_Channel_Text_Messages__c = courseReg.Marketing_Channel_Text_Messages__c;
        return con;
    }
    
    
}