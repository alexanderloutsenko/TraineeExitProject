@isTest
private class TestAL_SiteLoginController {
    private static Public_User__c u;
    private static PageReference pageRef;

    @testSetup static void setup() {
        // Test data setup    
		Public_User__c user = AL_TestDataFactory.createUser(false, null);// regular user
    } 
    
    private static void setUserAndPageRef() {
        // set user
        u = [SELECT Id, Login_Name__c, Password__c, Manager__c FROM Public_User__c ];
        // set page reference object
        pageRef = Page.AL_SiteLogin;
    }
    
    @isTest static void TestCheckUserPositive () {
        // set test data
        setUserAndPageRef(); 
        Test.setCurrentPage(pageRef);
        AL_SiteLoginController controller = new AL_SiteLoginController();
		controller.username = u.Login_Name__c;
        controller.password = u.Password__c;		        
        
        // Perform test
        Test.startTest();
		Boolean result = controller.checkUser();
        Test.stopTest();
        
        // validate results
        System.assertEquals(u.Id, controller.userId);
        System.assertEquals(u.Manager__c, controller.isManager);
        System.assertEquals(true, result);
    }
    
    @isTest static void TestCheckUserNegative () {
        // set test data
        setUserAndPageRef(); 
        Test.setCurrentPage(pageRef);
        AL_SiteLoginController controller = new AL_SiteLoginController();
		controller.username = u.Login_Name__c;
        controller.password = 'WrongPassword';		        
        
        // Perform test
        Test.startTest();
		Boolean result = controller.checkUser();
        Test.stopTest();
        
        // validate results
        System.assertEquals(false, result);
    }
    // test regular user's redirect after login
    @isTest static void TestLoginRegularUser () {
        // set test data
        setUserAndPageRef(); 
        Test.setCurrentPage(pageRef);
        PageReference redirectPageName = new PageReference('/AL_UserHomePage?id=' + u.Id);
        AL_SiteLoginController controller = new AL_SiteLoginController();
		controller.username = u.Login_Name__c;
        controller.password = u.Password__c;		        
        
        // Perform test
        Test.startTest();
		PageReference result = controller.login();
        Test.stopTest();
        
        // validate results
        System.assertEquals(redirectPageName.getUrl(), result.getUrl());
    } 
    // test manager's redirect after login    
    @isTest static void TestLoginManager () {
        // set test data
        setUserAndPageRef();
        u = AL_TestDataFactory.createUser(true, null);// create manager
        Test.setCurrentPage(pageRef);
        PageReference redirectPageName = new PageReference('/AL_ManagerHomePage?id=' + u.Id);
        AL_SiteLoginController controller = new AL_SiteLoginController();
		controller.username = u.Login_Name__c;
        controller.password = u.Password__c;		        
        
        // Perform test
        Test.startTest();
		PageReference result = controller.login();
        Test.stopTest();
        
        // validate results
        System.assertEquals(redirectPageName.getUrl(), result.getUrl());
    }

    // test message appearance in case of improper username/password having been entered
    @isTest static void TestLoginFailure () {
        // set test data
        setUserAndPageRef(); 
        Test.setCurrentPage(pageRef);
        PageReference redirectPageName = new PageReference('/AL_UserHomePage?id=' + u.Id);
        AL_SiteLoginController controller = new AL_SiteLoginController();
		controller.username = 'Non-existingUserName';
        controller.password = u.Password__c;		        
        
        // Perform test
        Test.startTest();
		PageReference result = controller.login();
        Test.stopTest(); 
        
        // validate results
        ApexPages.Message[] messages = ApexPages.getMessages();
        System.assertEquals(1, messages.size());//check that only 1 custom message is rendered to appear on result VF page
        System.assertEquals(controller.userNotFoundMsg, messages[0].getDetail());
        System.assertEquals(null, result); 
    }
    
    //test messages for empty required fields
    @isTest static void TestMessagesForRequiredFields () {
        // set test data
        AL_SiteLoginController controller = new AL_SiteLoginController();
		controller.username = '';
        controller.password = '';		        
        
        // Perform test
        Test.startTest();
		PageReference result = controller.login();
        Test.stopTest(); 
        
        // validate results
        ApexPages.Message[] messages = ApexPages.getMessages();
        System.assertEquals(controller.userNotFoundMsg, messages[0].getDetail());
        System.assertEquals(1, messages.size());//check that 1 custom message is rendered to appear on result VF page
        System.assertEquals(null, result); 
    }
}