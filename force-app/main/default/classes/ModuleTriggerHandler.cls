public without sharing class ModuleTriggerHandler {
    public static void calculateGST(List<Module__c> moduleList, Map<Id, Module__c> moduleMap) {
        Map<String, Decimal> gstCodeMap = Utility.getGSTCodeMap();
        List<Module__c> updateModule = new List<Module__c>();
        for (Module__c module : moduleList) {
            if (moduleMap.containsKey(module.Id)) {
                Module__c oldModule = moduleMap.get(module.Id);
                if (oldModule.Full_Fee__c == module.Full_Fee__c &&
                    oldModule.GST_Code__c == module.GST_Code__c) {
                    continue;
                }
            }
            Module__c moduleUpdate = new Module__c();
            moduleUpdate.Id = module.Id;
            moduleUpdate.Full_Fee_GST_Amount__c = Utility.calculateGST(module.Full_Fee__c, module.GST_Code__c, gstCodeMap);
            updateModule.add(moduleUpdate);
            
        }

        if (updateModule.size() > 0) {
            update updateModule;
        }
    }

    public static void updateCourseModules(Map<Id, Module__c> moduleMap) {
        //Replacement to Flow Trigger
        List<Course_Module__c> courseModules = new List<Course_Module__c>();

        for (Course_Module__c cm : [SELECT Id, Module__c FROM Course_Module__c WHERE Module__c =: moduleMap.keySet()]) {
            Module__c module = moduleMap.get(cm.Module__c);
            Course_Module__c cmUpdate = new Course_Module__c();
            cmUpdate.Id = cm.Id;
            cmUpdate.Full_Fee__c = module.Full_Fee__c;
            cmUpdate.SME_Grant__c = module.SME_Grant__c;
            cmUpdate.Non_SME_Grant__c = module.Non_SME_Grant__c;
            cmUpdate.Baseline_Grant__c = module.Baseline_Grant__c;
            cmUpdate.Workfare__c = module.Workfare__c;
            cmUpdate.Mid_Career__c = module.Mid_Career__c;

            cmUpdate.Full_Fee_GST_Amount__c = module.Full_Fee_GST_Amount__c;
            cmUpdate.SME_Grant_GST_Amount__c = module.SME_Grant_GST_Amount__c;
            cmUpdate.Non_SME_Grant_GST_Amount__c = module.Non_SME_Grant_GST_Amount__c;
            cmUpdate.Baseline_Grant_GST_Amount__c = module.Baseline_Grant_GST_Amount__c;
            cmUpdate.Workfare_GST_Amount__c = module.Workfare_GST_Amount__c;
            cmUpdate.Mid_Career_GST_Amount__c = module.Mid_Career_GST_Amount__c;

            courseModules.add(cmUpdate);
        }

        if (courseModules.size() > 0) {
            update courseModules;
        }
    }
}