public without sharing class InvoiceDiscountTriggerHandler {
    public static void calculateGST(List<Invoice_Discount__c> itemDiscList, Map<Id, Invoice_Discount__c> itemDiscMap) {
        Map<String, Decimal> gstCodeMap = Utility.getGSTCodeMap();
        List<Invoice_Discount__c> updateItemDisc = new List<Invoice_Discount__c>();
        for (Invoice_Discount__c lineDisc : itemDiscList) {
            if (itemDiscMap.containsKey(lineDisc.Id)) {
                Invoice_Discount__c oldItemDisc = itemDiscMap.get(lineDisc.Id);
                if (lineDisc.GST_Calculated__c == true) {
                    Invoice_Discount__c clearFlag = new Invoice_Discount__c();
                    clearFlag.Id = lineDisc.Id;
                    clearFlag.GST_Calculated__c = false;
                    updateItemDisc.add(clearFlag);
                    continue;
                }
                if (oldItemDisc.Amount__c == lineDisc.Amount__c &&
                    oldItemDisc.GST_Code__c == lineDisc.GST_Code__c &&
                    oldItemDisc.GST_Mode__c == lineDisc.GST_Mode__c) {
                    continue;
                }
            }

            if (lineDisc.Amount__c == null) {
                continue;
            }

            Invoice_Discount__c lineDiscUpdate = new Invoice_Discount__c();
            lineDiscUpdate.Id = lineDisc.Id;
            if (lineDisc.GST_Mode__c == 'Nett') {
                Decimal gstAmt = Utility.calculateGST(lineDisc.Amount__c, lineDisc.GST_Code__c, gstCodeMap, lineDisc.GST_Mode__c);
                lineDiscUpdate.GST_Amount__c = gstAmt;
                lineDiscUpdate.Amount__c = lineDisc.Amount__c - lineDiscUpdate.GST_Amount__c;
            }
            else {
                lineDiscUpdate.GST_Amount__c = Utility.calculateGST(lineDisc.Amount__c, lineDisc.GST_Code__c, gstCodeMap);
            }
            lineDiscUpdate.GST_Calculated__c = true;
            updateItemDisc.add(lineDiscUpdate);
        }

        if (updateItemDisc.size() > 0) {
            update updateItemDisc;
        }
    }
}