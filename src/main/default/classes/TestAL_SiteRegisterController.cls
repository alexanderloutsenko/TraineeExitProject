@isTest
private class TestAL_SiteRegisterController {

    @testSetup static void setup() {
        // Test data setup
        Region__c region = AL_TestDataFactory.createRegion(); 
		Public_User__c user = AL_TestDataFactory.createUser(false, region.Id);
    }
    
    @isTest static void TestGetStateOptions () {
        // set test data
	    List<SelectOption> states = AL_TestDataFactory.getStateOptions();    
		AL_SiteRegisterController controller = new AL_SiteRegisterController();       
        // Perform test
        Test.startTest();
		List<SelectOption> result = controller.getStateOptions();
        Test.stopTest();
        
        // validate results
        System.assertEquals(states, result);
    } 
    
    @isTest static void TestGetCityOptions() {
        // set test data
	    List<SelectOption> cities = AL_TestDataFactory.getCityOptions('CA');    
		AL_SiteRegisterController controller = new AL_SiteRegisterController();
        controller.selectedState = 'CA';
        // Perform test
        Test.startTest();
		List<SelectOption> result = controller.getCityOptions();
        Test.stopTest();
        
        // validate results
        System.assertEquals(cities, result);
    } 
    // check case when login name already exists in db
    @isTest static void TestCheckUserPositive () {
        // set test data
		Public_User__c u = [SELECT id, Login_Name__c FROM Public_User__c ];
        AL_SiteRegisterController controller = new AL_SiteRegisterController();
		controller.loginName = u.Login_Name__c;
        controller.password = 'anyPassword';
        controller.selectedState = 'IL';
        controller.selectedCity = 'Chicago';
        
        // Perform test
        Test.startTest();
		Boolean result = controller.checkUser();
        Test.stopTest();
        
        // validate results
        System.assertEquals(true, result);
    }
    // check case when login name doesn't exist in db
    @isTest static void TestCheckUserNegative () {
        // set test data
		Public_User__c u = [SELECT id, Login_Name__c FROM Public_User__c];
        AL_SiteRegisterController controller = new AL_SiteRegisterController();
		controller.loginName = 'non-existingLoginName';
        controller.password = 'anyPassword';
        controller.selectedState = 'IL';
        controller.selectedCity = 'Chicago';	        
        
        // Perform test
        Test.startTest();
		Boolean result = controller.checkUser();
        Test.stopTest();
        
        // validate results
        System.assertEquals(false, result);
    }

    @isTest static void TestGetRegionPositive () {
        // set test data
		Region__c reg = [SELECT id, State__c, City__c FROM Region__c ];
        AL_SiteRegisterController controller = new AL_SiteRegisterController();
        controller.selectedState = 'IL';
        controller.selectedCity = 'Chicago';	        
        
        // Perform test
        Test.startTest();
		String result = controller.getRegionId(controller.selectedState, controller.selectedCity);
        Test.stopTest();
        
        // validate results
        System.assertEquals(reg.Id, result);
    }
    
    @isTest static void TestGetRegionNegative () {
        // set test data
		Region__c reg = [SELECT id, State__c, City__c FROM Region__c ];
        AL_SiteRegisterController controller = new AL_SiteRegisterController();
        controller.selectedState = 'IL';
        controller.selectedCity = '-- None --';	        
        
        // Perform test
        Test.startTest();
		String result = controller.getRegionId(controller.selectedState, controller.selectedCity);
        Test.stopTest();
        
        // validate results
        System.assertEquals('', result);
    }
    // check registerUser method
    @isTest static void TestRegisterUserPositive () {
        // set test data
        AL_SiteRegisterController controller = new AL_SiteRegisterController();
		controller.loginName = 'NewUserToRegister';
        controller.password = 'anyPassword';
        controller.selectedState = 'IL';
        controller.selectedCity = 'Chicago';
        PageReference pref = new PageReference('/AL_SiteRegisterConfirm');
        
        // Perform test
        Test.startTest();
		PageReference result = controller.registerUser();
        Test.stopTest();
        Public_User__c newlyRegisteredUser = [SELECT id, 
                                              		 Login_Name__c, 
                                              		 Password__c, 
                                              		 Region__c 
                                                FROM Public_User__c
                                               WHERE Login_Name__c =: controller.loginName];
        Region__c reg = [SELECT id 
                           FROM Region__c 
						  WHERE State__c =: controller.selectedState 
                            AND City__c  =: controller.selectedCity];
        // validate results
        System.assertEquals(pref.getUrl(), result.getUrl());
        System.assertEquals(controller.loginName, newlyRegisteredUser.Login_Name__c);
        System.assertEquals(controller.password, newlyRegisteredUser.Password__c);  
        System.assertEquals(controller.loginName, newlyRegisteredUser.Login_Name__c);
        System.assertEquals(reg.Id, newlyRegisteredUser.Region__c);        
    }
    // check page message when login name already exists in db
    @isTest static void TestRegisterUserWhenLoginExists () {
        // set test data
		Public_User__c u = [SELECT id, Login_Name__c FROM Public_User__c ];
        AL_SiteRegisterController controller = new AL_SiteRegisterController();
		controller.loginName = u.Login_Name__c;
        controller.password = 'anyPassword';
        controller.selectedState = 'IL';
        controller.selectedCity = 'Chicago';	        
        
        // Perform test
        Test.startTest();
		PageReference result = controller.registerUser();
        Test.stopTest();
        
        // validate results
        ApexPages.Message[] messages = ApexPages.getMessages();
        System.assertEquals(1, messages.size());//check that only 1 custom message is rendered to appear on result VF page
        System.assertEquals(controller.userAlreadyExistsMsg, messages[0].getDetail());
        System.assertEquals(null, result); 
    }
    
    // check message when picklist is blank
    @isTest static void TestRegisterUserWithRequiredFieldEmpty () {
        // set test data
        AL_SiteRegisterController controller = new AL_SiteRegisterController();
		controller.loginName = 'non-existingLoginName';
        controller.password = 'anyPassword';
        controller.selectedState = 'IL';
        controller.selectedCity = '-- None --';	        
        
        // Perform test
        Test.startTest();
		PageReference result = controller.registerUser();
        Test.stopTest();
        
        // validate results
        ApexPages.Message[] messages = ApexPages.getMessages();
        System.assertEquals(1, messages.size());//check that only 1 custom message is rendered to appear on result VF page
        System.assertEquals(controller.emptyRequiredFieldMsg, messages[0].getDetail());
        System.assertEquals(null, result); 
    }
}