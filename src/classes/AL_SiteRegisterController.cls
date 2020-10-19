global class AL_SiteRegisterController {

    global String name {get; set;}
    global String loginName {get; set;}
    public Region__c region {get; set;}
    //public String state {get; set;}
    //public String city {get; set;}
    //public List<String> stateList {get; set;}
    //public String selectedState {get; set;}
    //public List<String> cityList {get; }
    global String password {get; set {password = value == null ? value : value.trim(); } }

  

    global AL_SiteRegisterController () {
        //region = [SELECT State__c, City__c FROM Region__c];
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


    global PageReference registerUser() {

        Public_User__c newUser = new Public_User__c();
        newUser.name          = name;
        newUser.Login_Name__c = loginName;
        newUser.Password__c   = password;
        newUser.Name          = name == null ? loginName : name;
        //matchRegion(state, city);
        //newUser.Region__c     = region.Id;
        newUser.Region__c     = (Id)'a077R00001IXJLTQA5';

        // check for login name existance
        insert newUser; 

        return null;
    } 
}