public without sharing class InvoiceLineItemTriggerHandler {
    public static void calculateGST(List<Invoice_Line_Item__c> lineItemList, Map<Id, Invoice_Line_Item__c> lineItemMap) {
        Map<String, Decimal> gstCodeMap = Utility.getGSTCodeMap();
        List<Invoice_Line_Item__c> updateLineItem = new List<Invoice_Line_Item__c>();
        for (Invoice_Line_Item__c lineItem : lineItemList) {
            if (lineItemMap.containsKey(lineItem.Id)) {
                Invoice_Line_Item__c oldLineItem = lineItemMap.get(lineItem.Id);
                if (lineItem.GST_Calculated__c == true) {
                    Invoice_Line_Item__c clearFlag = new Invoice_Line_Item__c();
                    clearFlag.Id = lineItem.Id;
                    clearFlag.GST_Calculated__c = false;
                    updateLineItem.add(clearFlag);
                    continue;
                }
                if (oldLineItem.Amount__c == lineItem.Amount__c &&
                    oldLineItem.GST_Code__c == lineItem.GST_Code__c &&
                    oldLineItem.GST_Mode__c == lineItem.GST_Mode__c) {
                    continue;
                }
            }

            Invoice_Line_Item__c lineItemUpdate = new Invoice_Line_Item__c();
            lineItemUpdate.Id = lineItem.Id;
            
            if (lineItem.GST_Mode__c == 'Nett') {
                Decimal gstAmt = Utility.calculateGST(lineItem.Amount__c, lineItem.GST_Code__c, gstCodeMap, lineItem.GST_Mode__c);
                lineItemUpdate.GST_Amount__c = gstAmt;
                lineItemUpdate.Amount__c = lineItem.Amount__c - lineItemUpdate.GST_Amount__c;
            }
            else {
                lineItemUpdate.GST_Amount__c = Utility.calculateGST(lineItem.Amount__c, lineItem.GST_Code__c, gstCodeMap);
            }
            lineItemUpdate.GST_Calculated__c = true;
            updateLineItem.add(lineItemUpdate);
        }

        if (updateLineItem.size() > 0) {
            update updateLineItem;
        }
    }
}