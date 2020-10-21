global class AL_SiteRegisterController {

    global String name {get; set;}
    global String loginName {get; set;}
    public List<Region__c> regions {get; set;}
    public Id selectedRegion {get; set;}
    public String selectedState {get; set;}
    public String selectedCity {get; set;}
 
    //public List<SelectOption> cityOptions = new List<SelectOption>(); 
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

  public List<SelectOption> getStateOptions()
  {
      List<SelectOption> stateOptions = new List<SelectOption>();
      stateOptions.add(new SelectOption('-- None --', '-- None --'));        
    Schema.DescribeFieldResult fieldResult = Region__c.State__c.getDescribe();
       List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        for( Schema.PicklistEntry f : ple)
        {
            stateOptions.add(new SelectOption(f.getLabel(), f.getValue()));
        }       
        return stateOptions;
  }

    public List<SelectOption> getCityOptions() 
  {
         List<SelectOption> cityOptions = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult = Region__c.City__c.getDescribe();
        cityOptions.add(new SelectOption('-- None --', '-- None --'));
        if(selectedState == 'CA') {
                 cityOptions.add(new SelectOption('Los Angeles', 'Los Angeles'));
                 cityOptions.add(new SelectOption('San Francisco', 'San Francisco')); 
        }
        if(selectedState == 'IL') {
                 cityOptions.add(new SelectOption('Chicago', 'Chicago'));
                 cityOptions.add(new SelectOption('Rockford', 'Rockford')); 
        }
        if(selectedState == 'Dnipro') {
                 cityOptions.add(new SelectOption('Pavlograd', 'Pavlograd'));
                 cityOptions.add(new SelectOption('Piatikhatkyy', 'Piatikhatkyy')); 
        }         
        return cityOptions;
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

    public String getRegionId (String state, String city) {
        if(state != '-- None --' && city != '-- None --') {
           List<Region__c> selectedRegion = [SELECT id FROM Region__c 
                                            WHERE State__c =: state 
                                            AND City__c =: city];
 System.debug('** selectedRegion='+selectedRegion);
            return  selectedRegion[0].Id;
        } else { 
            return '';           
        }                                                                             
    }

    global PageReference registerUser() {
        Boolean existingUser = checkUser();
        String regionId = getRegionId(selectedState, selectedCity);

        if(existingUser != true && !String.isBlank(regionId)) {
            Public_User__c newUser = new Public_User__c();
            newUser.Login_Name__c = loginName;
            newUser.Password__c   = password;
            newUser.Name          = name == null ? loginName : name;
            newUser.Region__c     = regionId;
            
            System.debug(' ** selectedState = '+selectedState+' and selectedCity='+selectedCity+' and loginName='+loginName);
            System.debug('** newUser='+newUser);
            System.debug('** newUser.Region__c='+newUser.Region__c);
            insert newUser; 
            return new PageReference('/AL_SiteRegisterConfirm');

        } else {
            if(existingUser) {
                // show error message if login name already exists
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING,userAlreadyExistsMsg));
            }
            if(String.isBlank(regionId)) {
                // show error message if either state or city is not selected
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING,'Select both State and City'));
            }
            return null;
        }
    } 
}