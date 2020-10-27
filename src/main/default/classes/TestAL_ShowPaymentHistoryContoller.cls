@isTest
private class TestAL_ShowPaymentHistoryContoller {

    @testSetup static void setup() {
        // Test data setup
		Public_User__c user = AL_TestDataFactory.createUser(false, null);// regular user
        List<Monthly_Payment__c> payments = AL_TestDataFactory.createPayments(5, user.Id, null, null);
    }
    
   @isTest static void TestConstructor() {
        // Test data setup
		Public_User__c u = [SELECT Id FROM Public_User__c ];
        // pageReference setup
        PageReference pageRef = Page.AL_ShowPaymentHistory;
		pageRef.getParameters().put('id', u.Id);  
        Test.setCurrentPage(pageRef);
        
        // Perform test
        Test.startTest();
        AL_ShowPaymentHistoryContoller result = new AL_ShowPaymentHistoryContoller();
        Test.stopTest();
        
        // validate results
        System.assertEquals(5, result.payRecsByUser.size());
    }    
}