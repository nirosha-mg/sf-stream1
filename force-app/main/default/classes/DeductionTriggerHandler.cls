public with sharing class DeductionTriggerHandler {
    public static void calculateGST(List<Deduction__c> deductionList, Map<Id, Deduction__c> deductionMap) {
        Map<String, Decimal> gstCodeMap = Utility.getGSTCodeMap();
        List<Deduction__c> updateDeduction = new List<Deduction__c>();
        for (Deduction__c deduction : deductionList) {
            if (deductionMap.containsKey(deduction.Id)) {
                Deduction__c oldDeduction = deductionMap.get(deduction.Id);
                if (oldDeduction.Deduction_Amount__c == deduction.Deduction_Amount__c &&
                    oldDeduction.Deduction_GST_Code__c == deduction.Deduction_GST_Code__c) {
                    continue;
                }
            }

            Deduction__c deductionUpdate = new Deduction__c();
            deductionUpdate.Id = deduction.Id;
            if (deduction.Deduction_Amount__c > 0) {
                deductionUpdate.Deduction_GST_Amount__c = Utility.calculateGST(deduction.Deduction_Amount__c, deduction.Deduction_GST_Code__c, gstCodeMap);
            }
            else {
                deductionUpdate.Deduction_GST_Amount__c = 0;
            }
            updateDeduction.add(deductionUpdate);
        }

        if (updateDeduction.size() > 0) {
            update updateDeduction;
        }
    }
}