public class contactTriggerHandler {
    public static void contactMethod(list<Contact> newContact){
        Map<Decimal,string> nricMap = returnNRICGrid();
        Map<Decimal,string> nricMapone = returnNRICGrid_F();
       
        for(Contact cr:newContact)
        {
            if(cr.NRIC_Type__c == 'Singapore Citizen/PR' || cr.NRIC_Type__c == 'FIN') {
                string nric = cr.NRIC__c;
                if(nric != NULL) {
                if(nric.length() != 9) {
                    cr.NRIC__c.addError('Invalid NRIC');
                }
                else if(CourseRegistrationTriggerHandler.validateNRIC(nric) == true && 
                       (nric.substring(0,1)=='S'||nric.substring(0,1)=='T'||nric.substring(0,1)=='F'||nric.substring(0,1)=='G')){
                    Integer nricsum = 2*Integer.valueOf(nric.substring(1,2)) +
                                    7*Integer.valueOf(nric.substring(2, 3)) +
                                    6*Integer.valueOf(nric.substring(3, 4)) +
                                    5*Integer.valueOf(nric.substring(4, 5)) +
                                    4*Integer.valueOf(nric.substring(5,6)) +
                                    3*Integer.valueOf(nric.substring(6, 7)) +
                        2*Integer.valueOf(nric.substring(7, 8));       
                    if(nric.substring(0,1)=='S'){
                    Integer nricremainder=Math.mod(nricsum , 11);   
                    if(nricMap.containskey(nricremainder) &&  nricMap.get(nricremainder)!= null &&
                       nricMap.get(nricremainder) != nric.substring(8, 9)) {
                         cr.NRIC__c.addError('NRIC/FIN is not valid ');
                    }
                 }
                    if(nric.substring(0,1)=='T'){
                    Integer nricremainder=Math.mod(nricsum+4, 11);               
                    if(nricMap.containskey(nricremainder) &&  nricMap.get(nricremainder)!= null &&
                       nricMap.get(nricremainder) != nric.substring(8, 9)) {
                         cr.NRIC__c.addError('NRIC/FIN is not valid ');
                    }
                 }
                    if(nric.substring(0,1)=='F'){
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
    
    public static void createSSOUser(List<Contact> contacts) {
        List<User> userList = new List<User>();
        Id b2bLearnerRT = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('B2B_Learner').getRecordTypeId();
        List<Profile> b2bLearner = [SELECT Id FROM Profile WHERE Name = 'B2B Learner' LIMIT 1];
        if (b2bLearner.size() > 0) {
            Id userProfileId = b2bLearner[0].Id;
            for (Contact contact : contacts) {
                if(!contact.Self_Registration__c && contact.RecordTypeId == b2bLearnerRT) {
                    User user = SSOHandler.prepareUser(contact.FirstName, contact.LastName, contact.Email, contact.Id, userProfileId);
                    userList.add(user);
                }
            }
        }

        if (userList.size() > 0) {
            List<Id> userIds = new List<Id>();
            for (Database.SaveResult res : Database.insert(userList)) {
                if (res.success) {
                    userIds.add(res.getId());
                }
            }
            if (userIds.size() > 0) {
                System.enqueueJob(new SSOQueueable(userIds));
            }
        }
    }
}