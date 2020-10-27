@isTest
private class TestAL_ManagerPaymentHistoryController {
    
    @testSetup static void setup() {
        // Test data setup
        Region__c region = AL_TestDataFactory.createRegion(); 
		Rates__c rates = AL_TestDataFactory.createRates(region.Id); 
        Standard_Readings__c readings = AL_TestDataFactory.createStandReadings(region.Id);    
		Public_User__c manager = AL_TestDataFactory.createUser(true, region.Id);
        List<Monthly_Payment__c> payments = AL_TestDataFactory.createPayments(5, manager.Id, rates.Id, region.Id);      
    }
    
    @isTest static void TestConstructor() {
        // Test data setup
		Public_User__c u = [SELECT Id FROM Public_User__c ];
        List<Monthly_Payment__c> pmnts = [SELECT Id FROM Monthly_Payment__c];
        // pageReference setup
        PageReference pageRef = Page.AL_ManagerPaymentHistory;
		pageRef.getParameters().put('id', u.Id);  
        Test.setCurrentPage(pageRef);
        
        // Perform test
        Test.startTest();
        AL_ManagerPaymentHistoryController result = new AL_ManagerPaymentHistoryController();
        Test.stopTest();
        
        // validate results
        System.assertEquals(u.Id, result.userId);
        System.assert(result.manager != null);
        System.assert(result.paymentsFromController.size() == 5);
    }
    
    @isTest static void TestFetchDetails() {
        // Test data setup
        Public_User__c u = [SELECT Id FROM Public_User__c ];
        List<Monthly_Payment__c> pmnts = [SELECT name FROM Monthly_Payment__c];
        String payId = pmnts[0].id;
        // pageReference setup
        PageReference pageRef = Page.AL_ManagerPaymentHistory;
		pageRef.getParameters().put('id', u.Id);  
        Test.setCurrentPage(pageRef);
		
        // initiate tested object and set Id    
        AL_ManagerPaymentHistoryController controller = new AL_ManagerPaymentHistoryController();
        controller.paymentId = pmnts[0].id;
        // Perform test
        Test.startTest();
            PageReference result = controller.fetchDetail();
        Test.stopTest();
        
        // validate results
        System.assertEquals(null, result);
        System.assert(controller.recordToUpdate != null);
    }     
}