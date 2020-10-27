@isTest
private class TestAL_DoPaymentController {
    private static Public_User__c u;
    private static Rates__c rate;
    private static PageReference pageRef;    
    
    @testSetup static void setup() {
        // Test data setup
        Region__c region = AL_TestDataFactory.createRegion(); 
		Rates__c rates = AL_TestDataFactory.createRates(region.Id); 
        Standard_Readings__c readings = AL_TestDataFactory.createStandReadings(region.Id);    
		Public_User__c user = AL_TestDataFactory.createUser(false, region.Id);
        //List<Monthly_Payment__c> payments = AL_TestDataFactory.createPayments(5, user.Id, rates.Id, region.Id);      
    	Monthly_Payment__c payment = AL_TestDataFactory.createOpenPayment(user.Id, rates.Id, region.Id);
    }
    
    private static void setUserAndPageRef() {
        // set user
        u = [SELECT Id, Login_Name__c, Password__c, Manager__c, Region__c, Region__r.Name FROM Public_User__c ];
        // set page reference object
        pageRef = Page.AL_UpdateRates;
        pageRef.getParameters().put('id', u.Id);
    }
    
    private static void setRates () {
        rate = [SELECT Id,
                       Electricity_Rate__c,
                       Gas_Rate__c,
                       Water_Rate__c, 
                       Region__c,
                       Close_Date__c      		 
                  FROM Rates__c
                 WHERE Region__c =: u.Region__c
                   AND Close_Date__c = NULL
              ORDER BY CreatedDate DESC];
    }

    @isTest static void TestConstructorPositive () {
        // set test data
        setUserAndPageRef();
        //setRates();
        Test.setCurrentPage(pageRef);	        
        
        // Perform test
        Test.startTest(); 
        AL_DoPaymentController result = new AL_DoPaymentController();
        Test.stopTest();
        
        // validate results
        System.assert(result.payRec != null);
        System.assertEquals(false, result.fullyPaid);
    } 
    
    @isTest static void TestConstructorNegative () {
        // set test data
        setUserAndPageRef();
        //setRates();
        Monthly_Payment__c pay = [SELECT Id,
                                  Recommended_Payment_Sum__c,
                                  Sum_Already_Payed__c,
                                  Payment_Fullness__c,
                  		 		  Payment_Status__c,
                                  Payment_Closed_Date__c
                                  FROM Monthly_Payment__c
                                 WHERE Public_User__c =: u.id];
        pay.Sum_Already_Payed__c = pay.Recommended_Payment_Sum__c;
        pay.Payment_Fullness__c = 'Fully';
        pay.Payment_Status__c = 'Closed';
        pay.Payment_Closed_Date__c = Date.today();
        update pay;
        Test.setCurrentPage(pageRef);	        
        
        // Perform test
        Test.startTest(); 
        AL_DoPaymentController result = new AL_DoPaymentController();
        Test.stopTest();
        
        // validate results
        System.assert(result.payRec != null);
        System.assertEquals(true, result.fullyPaid);
    }  
    
    @isTest static void TestDoPaymentFully () {
        // set test data
        setUserAndPageRef();
        //setRates();
        Monthly_Payment__c pay = [SELECT Id,
                                  Recommended_Payment_Sum__c,
                                  Sum_Already_Payed__c,
                                  Payment_Fullness__c,
                  		 		  Payment_Status__c,
                                  Payment_Closed_Date__c
                                  FROM Monthly_Payment__c
                                 WHERE Public_User__c =: u.id];
        System.debug(' !! inside of test ' + pay.Sum_Already_Payed__c);
        pay.Sum_Already_Payed__c = pay.Recommended_Payment_Sum__c;
        update pay;
        Test.setCurrentPage(pageRef);	        
        AL_DoPaymentController controller = new AL_DoPaymentController();
            
        // Perform test
        Test.startTest(); 
		PageReference result = controller.doPayment();
        Test.stopTest();
        
        // validate results
        Monthly_Payment__c updatedPay = [SELECT Id,
                                  Recommended_Payment_Sum__c,
                                  Sum_Already_Payed__c,
                                  Payment_Fullness__c,
                  		 		  Payment_Status__c,
                                  Payment_Closed_Date__c
                                  FROM Monthly_Payment__c
                                 WHERE Public_User__c =: u.id];
        System.assert(updatedPay.Payment_Closed_Date__c != null);
        System.assertEquals(updatedPay.Recommended_Payment_Sum__c, updatedPay.Sum_Already_Payed__c);
        System.assertEquals('Fully', updatedPay.Payment_Fullness__c);
        System.assertEquals('Closed', updatedPay.Payment_Status__c );    
    }    
    
    @isTest static void TestDoPaymentPartially () {
        // set test data
        setUserAndPageRef();
        //setRates();
        Test.setCurrentPage(pageRef);	        
        AL_DoPaymentController controller = new AL_DoPaymentController();
        controller.customSum = 1;
            
        // Perform test
        Test.startTest(); 
		PageReference result = controller.doPayment();
        Test.stopTest();
        
        // validate results
        Monthly_Payment__c updatedPay = [SELECT Id,
                                  Recommended_Payment_Sum__c,
                                  Sum_Already_Payed__c,
                                  Payment_Fullness__c,
                  		 		  Payment_Status__c,
                                  Payment_Closed_Date__c
                                  FROM Monthly_Payment__c
                                 WHERE Public_User__c =: u.id];
        //System.assert(updatedPay.Payment_Closed_Date__c == null);
        System.assertEquals(1, updatedPay.Sum_Already_Payed__c);
        System.assertEquals('Partially', updatedPay.Payment_Fullness__c);
        System.assertEquals('Partial', updatedPay.Payment_Status__c );    
    }  
}