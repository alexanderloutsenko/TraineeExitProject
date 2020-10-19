global class AL_SiteRegisterController {

    global String name {get; set;}
    global String loginName {get; set;}
    public List<Region__c> regions {get; set;}
    public Id selectedRegion {get; set;}
    global String password {get; set {password = value == null ? value : value.trim(); } }
    global String userAlreadyExistsMsg = 'Login name you are trying to submit already in use by another user';

    global AL_SiteRegisterController () { }

    public List<SelectOption> getOptions() {
        List<SelectOption> regionOptions = new List<SelectOption>();
        regions = [select Id, Name from Region__c order by Name limit 100];
        for(Region__c r : regions)
        {
            regionOptions.add(new SelectOption(r.Id, r.Name));
        }       
        return regionOptions; 
    }

    public Boolean checkUser() {
        Boolean userExist = false;
        //System.debug('** loginName is '+loginName);
        List<Public_User__c> usr = [SELECT id, Login_Name__c
                                      FROM Public_User__c
                                     WHERE Login_Name__c = :loginName 
                                     LIMIT 1];

        if(usr.size() != 0) {
            userExist = true;
        } 
     
        return userExist;
    }

    global PageReference registerUser() {

        Public_User__c newUser = new Public_User__c();
        newUser.Login_Name__c = loginName;
        newUser.Password__c   = password;
        newUser.Name          = name == null ? loginName : name;
        newUser.Region__c     = selectedRegion;
    
        // check for login name existance
        //Boolean b = checkUser(); //false;
        //System.debug('is user found in db? - '+b);
        if(checkUser()) {
            // show error message if login name already exists
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING,userAlreadyExistsMsg));
            return null;
        } else {
            insert newUser; 
            return new PageReference('/AL_SiteRegisterConfirm');
        }
    } 
}