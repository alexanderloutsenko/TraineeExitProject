global with sharing class AL_SiteLoginController {
    global String username {get; set;}
    global String password {get; set;}
    global String userId {get; set;}
    global String userStartUrl = '/AL_UserHomePage';
    global String managerStartUrl = '/AL_ManagerHomePage';
    private Boolean isManager = false;
    global Boolean RegistrationEnabled {get; set;}
    global String currentUrl {get; set;}
        public PageReference pageRef ; 
    //global Boolean showLoginError = {get; set;}
    global String userNotFoundMsg = 'You was not found within a list of registered users. Check the correctness of your login and/or password';

    global AL_SiteLoginController () {}

    public Boolean checkUser() {
        Boolean userExist = false;
        System.debug('** username='+username+' & password='+password);
        Public_User__c usr = [SELECT Id, Login_Name__c, Password__c, Manager__c
                                FROM Public_User__c
                               WHERE Login_Name__c =: username
                                 AND Password__c =: password];
        if(usr != null) {
            userExist = true;
            userId = usr.Id;
            if(usr.Manager__c) {
                isManager = true;
            }
        }
        return userExist;
    }

    global PageReference login() {
        //String startUrl = System.currentPageReference().getParameters().get('startURL');
        //return Site.login(username, password, startUrl);
        String redirectUrl = '';
        
        if(checkUser()) {

            // form the URL for Login page redirect with parameters to pass
            pageRef = new PageReference('/AL_UserHomePage');  // /apex
            pageRef.setRedirect(true);
            pageRef.getParameters().put('id', userId );
            System.debug('** pageRef is ' + pageRef);
            System.debug('** URL passed from VF is ' + currentUrl);
            return pageRef;

           /* if(isManager) {
                redirectUrl = managerStartUrl + '?id=' + userId;
            } else {
                redirectUrl = userStartUrl + '?id=' + userId;
            }
            PageReference pageRef = new PageReference(redirectUrl);
            return pageRef; */
        } else {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING,userNotFoundMsg));
            RegistrationEnabled = true;
            return null;
        }

    }
    

}