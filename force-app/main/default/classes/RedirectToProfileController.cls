public class RedirectToProfileController {
    
	@AuraEnabled
    public static String getProfileURL() {
        String redirectURL = '';
        Id userId = UserInfo.getUserId();
        User userInfo = [SELECT ContactId FROM User WHERE Id=:userId];
        if (userInfo.ContactId != null) {
	        redirectURL = '/contact/' + userInfo.ContactId;   
        }
        
        return redirectURL;
    }
}