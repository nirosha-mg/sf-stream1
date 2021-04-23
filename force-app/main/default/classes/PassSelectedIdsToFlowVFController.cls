public class PassSelectedIdsToFlowVFController {
	public string[] SelectedIDs{get;set;}
    
    public PassSelectedIdsToFlowVFController(ApexPages.StandardSetController listcontroller){
        SelectedIDs = new string[]{};
        for(Course_Registration__c acc : (Course_Registration__c[])listcontroller.getSelected()){
            SelectedIDs.add(acc.Id);
        }
    }
}