global class CustomLoginController {

    global String username { get; set; }
    global String password {get; set;}
    global String userId {get; set;}
    global String userStartUrl = '/AL_UserHomePage';
    global String managerStartUrl = '/AL_ManagerHomePage';
    private Boolean isManager = false;
   global String userNotFoundMsg = 'You was not found within a list of registered users. Check the correctness of your login and/or password';    

    global CustomLoginController () {  }

   public Boolean checkUser() {
        Boolean userExist = false;
        //System.debug('** username='+username+' & password='+password);
        Public_User__c usr = [SELECT Id, Login_Name__c, Password__c, Manager__c
                                FROM Public_User__c
                               WHERE Login_Name__c =: username
                                 AND Password__c =: password limit 1];

        if(usr != null) {
            userExist = true;
            userId = usr.Id;
            if(usr.Manager__c) {
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