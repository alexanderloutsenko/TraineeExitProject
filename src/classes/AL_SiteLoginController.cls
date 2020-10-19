global class AL_SiteLoginController {
     global String username { get; set; }
    global String password {get; set;}
    global String userId {get; set;}
    global String userStartUrl = '/AL_UserHomePage';
    global String managerStartUrl = '/AL_ManagerHomePage';
    private Boolean isManager = false;
   global String userNotFoundMsg = 'You was not found within a list of registered users. Check the correctness of your username and/or password';    

    global AL_SiteLoginController () {  }

   public Boolean checkUser() {
        Boolean userExist = false;
        //System.debug('** username='+username+' & password='+password);
        List<Public_User__c> usr = [SELECT Id, Login_Name__c, Password__c, Manager__c
                                      FROM Public_User__c
                                     WHERE Login_Name__c =: username
                                       AND Password__c =: password 
                                     LIMIT 1];

        if(usr.size() != 0) {
            userExist = true;
            userId = usr[0].Id;
            if(usr[0].Manager__c) {
                isManager = true;
            }
        } else {
            return userExist;
        }
        return userExist;
    }

       global PageReference login() {
         String redirectUrl = '';

        if(checkUser()) {
            // match the redirect page depending on user type with user's Id to pass
            if(isManager) {
                redirectUrl = managerStartUrl + '?id=' + userId;
            } else {
                redirectUrl = userStartUrl + '?id=' + userId;
            }
            // form final URL to redirect the user
            PageReference pageRef = new PageReference(redirectUrl);
            return pageRef; 
        } else {
            // show error message if user doesn't exist
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING,userNotFoundMsg));
            return null;
        }
    }
}
