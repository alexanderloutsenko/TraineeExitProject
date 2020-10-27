@isTest
private class TestAL_EnterMeterReadingsController {
    
    @testSetup static void setup() {
        // Test data setup
        Region__c region = AL_TestDataFactory.createRegion(); 
		Rates__c rates = AL_TestDataFactory.createRates(region.Id); 
        Standard_Readings__c readings = AL_TestDataFactory.createStandReadings(region.Id);    
		Public_User__c user = AL_TestDataFactory.createUser(false, region.Id);// regular user
        //List<Monthly_Payment__c> payments = AL_TestDataFactory.createPayments(5, user.Id);
        //Monthly_Payment__c payment = AL_TestDataFactory.createOpenPayment(user.Id);
    }
    
   @isTest static void TestConstructor() {
        // Test data setup
		Public_User__c u = [SELECT Id FROM Public_User__c ];
        // pageReference setup
        PageReference pageRef = Page.AL_EnterMeterReadings;
		pageRef.getParameters().put('id', u.Id);  
        Test.setCurrentPage(pageRef);
        
        // Perform test
        Test.startTest();
        AL_EnterMeterReadingsController result = new AL_EnterMeterReadingsController();
        Test.stopTest();
        
        // validate results
        System.assertEquals(u.Id, result.currentUser.Id);
    }    
    
    // check case when payment for last month doesn't exist yet
    @isTest static void TestCheckPaymentExistPositive() {
        
        // Test data setup
        Public_User__c u = [SELECT Id FROM Public_User__c ];
        // pageReference setup
        PageReference pageRef = Page.AL_EnterMeterReadings;
		pageRef.getParameters().put('id', u.Id);  
        Test.setCurrentPage(pageRef);
        // initiate tested object  
        AL_EnterMeterReadingsController controller = new AL_EnterMeterReadingsController();
        
        // Perform test
        Test.startTest();
        controller.checkPaymentExist();
        Test.stopTest();
        
        // validate results
        System.assert(controller.metersToInsert != null);
        System.assert(controller.existingMeters == null);
    } 
    
        // check case when payment for last month already exists with meter readings populated
    @isTest static void TestCheckPaymentExistNegative() {
        
        // Test data setup
        Public_User__c u = [SELECT Id, Region__c FROM Public_User__c];
        Rates__c rates = [SELECT Id, Region__c FROM Rates__c ];
        // pageReference setup
        PageReference pageRef = Page.AL_EnterMeterReadings;
		pageRef.getParameters().put('id', u.Id);  
        Test.setCurrentPage(pageRef);            
        // create payment with meter readings populated 
		Monthly_Payment__c payment = AL_TestDataFactory.createOpenPayment(u.Id, rates.Id, u.Region__c);
        // initiate tested object  
        AL_EnterMeterReadingsController controller = new AL_EnterMeterReadingsController();
            
        // Perform test
        Test.startTest();
        controller.checkPaymentExist();
        Test.stopTest();
        
        // validate results
        System.assertEquals(payment.Id, controller.existingMeters.Id);
        System.assert(controller.existingMeters != null);             
    }
    
    @isTest static void TestGetMetersFromController() {
        // Test data setup
		Public_User__c u = [SELECT Id, Region__c FROM Public_User__c ];
        Rates__c rates = [SELECT Id, Region__c FROM Rates__c ];
        List<Monthly_Payment__c> payments = AL_TestDataFactory.createPayments(5, u.Id, rates.Id, u.Region__c);
        // pageReference setup
        PageReference pageRef = Page.AL_EnterMeterReadings;
		pageRef.getParameters().put('id', u.Id);  
        Test.setCurrentPage(pageRef);
		// initiate tested object  
        AL_EnterMeterReadingsController controller = new AL_EnterMeterReadingsController();        
        
        // Perform test
        Test.startTest();
		List<Monthly_Payment__c> result = controller.getMetersFromController();
        Test.stopTest();
        
        // validate results
        System.assertEquals(5, result.size());
    } 
    
    // check case when payment for last month doesn't exist yet
    @isTest static void TestSubmitNewMeter() {
        
        // Test data setup
        Public_User__c u = [SELECT Id, Region__c FROM Public_User__c ];
        Rates__c rates = [SELECT Id, 
                          Region__c, 
                          Electricity_Rate__c,
                          Gas_Rate__c,
                          Water_Rate__c
                          FROM Rates__c 
                          WHERE Region__c =: u.Region__c ];
        // pageReference setup
        PageReference pageRef = Page.AL_EnterMeterReadings;
		pageRef.getParameters().put('id', u.Id);  
        Test.setCurrentPage(pageRef);

        Integer electro = 550;
        Integer gas = 11;
        Integer water = 22;
        Decimal totalSumForPayment = rates.Electricity_Rate__c * electro 
            					   + rates.Gas_Rate__c * gas
                                   + rates.Water_Rate__c * water; 
		Monthly_Payment__c expectedPayment = new Monthly_Payment__c (
                                              Payment_Month__c = Datetime.now().addMonths(-1).format('MMMM'),	 
                                              Region__c = u.Region__c,
                                              Public_User__c = u.Id,
                                              Rates__c = rates.Id,
                                              Electricity_Meter_Readings__c = electro,
                                              Gas_Meter_Readings__c = gas,
                                              Water_Meter_Readings__c = water
                                              );
        // initiate tested object and data for insert
        AL_EnterMeterReadingsController controller = new AL_EnterMeterReadingsController();        
        controller.metersToInsert.Electricity_Meter_Readings__c = electro;
        controller.metersToInsert.Gas_Meter_Readings__c = gas;
        controller.metersToInsert.Water_Meter_Readings__c = water;
        
        // Perform test
        Test.startTest();
        controller.submitNewMeter();
        Test.stopTest();
        
        // validate results        
        Monthly_Payment__c insertedPayment = [SELECT //Id, 
                                              Payment_Month__c,		 
                                              Region__c,
                                              Public_User__c,
                                              Rates__c,
                                              Electricity_Meter_Readings__c,
                                              Gas_Meter_Readings__c,
                                              Water_Meter_Readings__c,
                                              Recommended_Payment_Sum__c,
                                              Remaining_Sum_for_Payment__c
                                              FROM Monthly_Payment__c];     

        //System.assertEquals(expectedPayment, insertedPayment);
        System.assertEquals(totalSumForPayment, insertedPayment.Recommended_Payment_Sum__c);
        System.assertEquals(totalSumForPayment, insertedPayment.Remaining_Sum_for_Payment__c);
        System.assertEquals(expectedPayment.Electricity_Meter_Readings__c, insertedPayment.Electricity_Meter_Readings__c);
        System.assertEquals(expectedPayment.Gas_Meter_Readings__c, insertedPayment.Gas_Meter_Readings__c);
        System.assertEquals(expectedPayment.Water_Meter_Readings__c, insertedPayment.Water_Meter_Readings__c);        
        System.assertEquals(expectedPayment.Payment_Month__c, insertedPayment.Payment_Month__c);
        System.assertEquals(expectedPayment.Region__c, insertedPayment.Region__c);
        System.assertEquals(expectedPayment.Public_User__c, insertedPayment.Public_User__c);
        System.assertEquals(expectedPayment.Rates__c, insertedPayment.Rates__c);   
    } 
}