/**
 * @description       : 
 * @author            : Mark Alvin Tayag (mtayag@salesforce.com)
 * @group             : 
 * @last modified on  : 11-17-2020
 * @last modified by  : Mark Alvin Tayag (mtayag@salesforce.com)
 * Modifications Log 
 * Ver   Date         Author                                     Modification
 * 1.0   11-17-2020   Mark Alvin Tayag (mtayag@salesforce.com)   Initial Version
 * 1.1   02-01-2021   Poon Koon                                  Added in Methods to retrieve dependent picklist values
**/
public without sharing class Utility {
    
    public static Map<String, Decimal> getGSTCodeMap() {
        Map <String, Decimal> gstCodeMap = new Map<String, Decimal>();
        List<Schema.PicklistEntry> gstCodeValues = Course__c.GST_Code__c.getDescribe().getPicklistValues();
        for( Schema.PicklistEntry v : gstCodeValues) {
            try {
                //2103311230 Desmond to ensure that the value capture is before the %
                //Decimal rate = Decimal.valueOf(v.getLabel().substring(0, v.getLabel().length()-1));
                Integer i = v.getLabel().indexOf('%',0);
                Decimal rate = Decimal.valueOf(v.getLabel().substring(0, i));
                gstCodeMap.put(v.getValue(), rate);
            }
            catch (Exception e) {
                //Invalid Rate Label
                System.debug('Invalid Rate Label (expecting X.X%)');
            }
        }

        return gstCodeMap;
    }

    public static Decimal calculateGST(Decimal amount, String gstCode, Map<String, Decimal> gstCodeMap) {
        Decimal gstCodePerc = gstCodeMap.get(gstCode);
        amount = amount * (gstCodePerc/100);
        return amount.setScale(2, RoundingMode.HALF_UP);
    }

    public static Decimal calculateGST(Decimal amount, String gstCode, Map<String, Decimal> gstCodeMap, String gstMode) {
        Decimal gstCodePerc = gstCodeMap.get(gstCode);
        Decimal amountRound;
        gstCodePerc = (gstCodePerc/100);
        if (gstMode == 'Nett') {
            //2010210945 Desmond
            //amount = amount - (amount / (1 + gstCodePerc));
            amountRound = (amount / (1 + gstCodePerc));
            amountRound = amountRound.setScale(2, RoundingMode.HALF_UP);
            amount = amount - amountRound;
        }
        else {
            amount = amount * gstCodePerc;
            amount = amount.setScale(2, RoundingMode.HALF_UP);
        }
        //return amount.setScale(2, RoundingMode.UP);
        return amount;
    }
    
    /*********************************************************/
    /* 01Feb2021 - Poon Koon - Get Dependent Picklist Values */
    /*********************************************************/
    public static Map<String, List<String>> getDependentOptionsImpl(Schema.SObjectField theField, Schema.SObjectField ctrlField) {
        // validFor property cannot be accessed via a method or a property,
        // so we need to serialize the PicklistEntry object and then deserialize into a wrapper.
        List<Schema.PicklistEntry> contrEntries = ctrlField.getDescribe().getPicklistValues();
        List<PicklistEntryWrapper> depEntries =
                Utility.wrapPicklistEntries(theField.getDescribe().getPicklistValues());

        // Set up the return container - Map<ControllingValue, List<DependentValues>>
        Map<String, List<String>> objResults = new Map<String, List<String>>();
        List<String> controllingValues = new List<String>();

        for (Schema.PicklistEntry ple : contrEntries) {
            String label = ple.getLabel();
            objResults.put(label, new List<String>());
            controllingValues.add(label);
        }

        for (PicklistEntryWrapper plew : depEntries) {
            String label = plew.label;
            String value = plew.value;
            String validForBits = base64ToBits(plew.validFor);
            for (Integer i = 0; i < validForBits.length(); i++) {
                // For each bit, in order: if it's a 1, add this label to the dependent list for the corresponding controlling value
                String bit = validForBits.mid(i, 1);
                if (bit == '1') {
                    objResults.get(controllingValues.get(i)).add(label + '||' + value); //value returned updated to return both label and value, delimited by '||'
                }
            }
        }

        return objResults;
    }

    // Convert decimal to binary representation (alas, Apex has no native method :-(
    //    eg. 4 => '100', 19 => '10011', etc.
    // Method: Divide by 2 repeatedly until 0. At each step note the remainder (0 or 1).
    // These, in reverse order, are the binary.
    public static String decimalToBinary(Integer val) {
        String bits = '';
        while (val > 0) {
            Integer remainder = Math.mod(val, 2);
            val = Integer.valueOf(Math.floor(val / 2));
            bits = String.valueOf(remainder) + bits;
        }
        return bits;
    }

    // Convert a base64 token into a binary/bits representation
    // e.g. 'gAAA' => '100000000000000000000'
    public static String base64ToBits(String validFor) {
        if (String.isEmpty(validFor)) return '';

        String validForBits = '';

        for (Integer i = 0; i < validFor.length(); i++) {
            String thisChar = validFor.mid(i, 1);
            Integer val = base64Chars.indexOf(thisChar);
            String bits = decimalToBinary(val).leftPad(6, '0');
            validForBits += bits;
        }

        return validForBits;
    }


    private static final String base64Chars = '' +
            'ABCDEFGHIJKLMNOPQRSTUVWXYZ' +
            'abcdefghijklmnopqrstuvwxyz' +
            '0123456789+/';


    private static List<PicklistEntryWrapper> wrapPicklistEntries(List<Schema.PicklistEntry> PLEs) {
        return (List<PicklistEntryWrapper>)
            JSON.deserialize(JSON.serialize(PLEs), List<PicklistEntryWrapper>.class);
    }

    public class PicklistEntryWrapper {
        public String active {get; set;}
        public String defaultValue {get; set;}
        public String label {get; set;}
        public String value {get; set;}
        public String validFor {get; set;}
    }
    
}