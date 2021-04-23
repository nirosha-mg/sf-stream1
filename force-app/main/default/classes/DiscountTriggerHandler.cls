public without sharing class DiscountTriggerHandler {
    public static void calculateGST(List<Discount__c> discountList, Map<Id, Discount__c> discountMap) {
        Map<String, Decimal> gstCodeMap = Utility.getGSTCodeMap();
        List<Discount__c> updateDiscount = new List<Discount__c>();
        for (Discount__c discount : discountList) {
            if (discountMap.containsKey(discount.Id)) {
                Discount__c oldDiscount = discountMap.get(discount.Id);
                if (oldDiscount.Amount__c == discount.Amount__c &&
                    oldDiscount.GST_Code__c == discount.GST_Code__c) {
                    continue;
                }
            }
            if (discount.Percentage__c == false) {            
                Discount__c discountUpdate = new Discount__c();
                discountUpdate.Id = discount.Id;
                discountUpdate.GST_Amount__c = Utility.calculateGST(discount.Amount__c, discount.GST_Code__c, gstCodeMap);
                updateDiscount.add(discountUpdate);
            }
        }

        if (updateDiscount.size() > 0) {
            update updateDiscount;
        }
    }
}