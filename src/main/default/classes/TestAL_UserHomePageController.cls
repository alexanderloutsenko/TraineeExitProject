@isTest
private class TestAL_UserHomePageController {
    
   @isTest static void TestConstructor() {
        // Test data setup
        Region__c region = AL_TestDataFactory.createRegion(); 
		Public_User__c u = AL_TestDataFactory.createUser(false, region.Id);// regular user
        // pageReference setup
        PageReference pageRef = Page.AL_UserHomePage;
		pageRef.getParameters().put('id', u.Id);  
        Test.setCurrentPage(pageRef);
        
        // Perform test
        Test.startTest();
        AL_UserHomePageController result = new AL_UserHomePageController();
        Test.stopTest();
        
        // validate results
        System.assertEquals(pageRef.getParameters().get('id'), result.userId);
  		System.assertEquals(u.id, result.pageUser.id);
  		System.assertEquals(u.Region__c, result.pageUser.Region__c);        
    } 
}