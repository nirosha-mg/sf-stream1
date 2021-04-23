public without sharing class AccountUtility {
    @InvocableMethod (category='Account' description='Find Account with the same UEN or return null' label='Find Account with UEN No')
    public static List<String> findCompany(List<String> uenNo) {
        List<Account> accts = [SELECT Id FROM Account WHERE UEN_No__c =: uenNo[0] LIMIT 1];
        
        return accts.size() > 0 ? new List<String> { accts[0].Id } : new List<String>();
    }
}