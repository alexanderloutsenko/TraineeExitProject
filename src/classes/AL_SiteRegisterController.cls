/**
 * An apex class that creates a portal user
 */
public with sharing class AL_SiteRegisterController {
    
    public String name {get; set;}
    public String loginName {get; set;}
    public Region__c region {get; set;}
    public String state {get; set;}
    public String city {get; set;}
    public List<String> stateList {get; set;}
    public String selectedState {get; set;}
    public List<String> cityList {get; }
    public String password {get; set {password = value == null ? value : value.trim(); } }
    public String confirmPassword {get; set { confirmPassword = value == null ? value : value.trim(); } }
  

    public AL_SiteRegisterController () {
        region = [SELECT State__c, City__c FROM Region__c];
    }

    /*public setCity() {
        // we cannot access the dependant picklist values either through SOQL 
        //or the describeObject () method, but if you use the input type component 
        //dependant picklist then in it SFDC automatically handles that.
        city = [SELECT City__c FROM Region__c ];
    }*/

    public void matchRegion (String state, String city ){
        region = [select Id from Region__c where State__c = :state AND City__c =: city limit 1];
    }

    private boolean isValidPassword() {
        return password == confirmPassword;
    }
    
    public PageReference registerUser() {

        if (!isValidPassword()) {
          ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Passwords did not match.');
          ApexPages.addMessage(msg);
            return null;
        } 
        /*User u = new User();
        u.Username = username;
        u.Email = email;
        u.CommunityNickname = communityNickname;*/
        Public_User__c newUser = new Public_User__c();
        newUser.name          = name;
        newUser.Login_Name__c = loginName;
        newUser.Password__c   = password;
        newUser.Name          = name == null ? loginName : name;
        matchRegion(state, city);
        newUser.Region__c     = region.Id;

        // check for login name existance
        insert newUser;

        //  if First and Last Name isn't specified, we'll default it to the Login Name
        /*String userId = Site.createPortalUser(u, accountId, password);
        if (userId != null) { 
            if (password != null && password.length() > 1) {
                return Site.login(username, password, null);
            }
            else {
                PageReference page = System.Page.AL_SiteRegisterConfirm;
                page.setRedirect(true);
                return page;
            }
        } */
        return null;
    }
}