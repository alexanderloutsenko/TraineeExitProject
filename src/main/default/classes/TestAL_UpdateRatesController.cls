@isTest
private class TestAL_UpdateRatesController {
    private static Public_User__c u;
    private static Rates__c rate;
    private static PageReference pageRef;
    
    @testSetup static void setup() {
        // Test data setup
        Region__c region = AL_TestDataFactory.createRegion(); 
		Rates__c rates = AL_TestDataFactory.createRates(region.Id);
        Public_User__c manager = AL_TestDataFactory.createUser(true, region.Id);
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

    @isTest static void TestConstructor () {
        // set test data
        setUserAndPageRef();
        setRates();
        Test.setCurrentPage(pageRef);	        
        
        // Perform test
        Test.startTest(); 
        AL_UpdateRatesController result = new AL_UpdateRatesController();
        Test.stopTest();
        
        // validate results
        System.assertEquals(u.Id, result.userId);
        System.assertEquals(u.Region__c, result.regionId);
        System.assertEquals(u.Region__r.Name, result.regionName);
        System.assertEquals(rate.Id, result.actualRates.Id);
        System.assertEquals(rate.Electricity_Rate__c, result.electro);
        System.assertEquals(rate.Gas_Rate__c, result.gas); 
        System.assertEquals(rate.Water_Rate__c, result.water); 
    }        

    @isTest static void TestCreateRate () {
        // set test data & prerequisits
        setUserAndPageRef();
        setRates();

        pageRef.getParameters().put('id', u.Id);
        Test.setCurrentPage(pageRef);	        
		PageReference redirectPage = new PageReference('/AL_ManagerHomePage?id=' + u.Id);
        
        AL_UpdateRatesController controller = new AL_UpdateRatesController();
		controller.electro = 0.5;
        controller.gas = 0.5;
        controller.water = 0.5;
        
        // Perform test
        Test.startTest();
		PageReference result = controller.createRate();
        Test.stopTest();
                
        // validate new Rates record 
        Rates__c newRates  = [SELECT Id,
                       				 Electricity_Rate__c,
                       				 Gas_Rate__c,
                       				 Water_Rate__c, 
                      				 Region__c,
                              		 Month__c,
                      				 Close_Date__c      		 
                 				FROM Rates__c
                			   WHERE Region__c =: u.Region__c
                   				 AND Close_Date__c = NULL];
        System.debug(rate.Close_Date__c);
        System.debug(rate);
        System.debug(newRates);
        System.debug(controller.actualRates.Id);
        System.debug(controller.electro);
        System.assertEquals(controller.electro, newRates.Electricity_Rate__c);
        System.assertEquals(controller.gas, newRates.Gas_Rate__c);
        System.assertEquals(controller.water, newRates.Water_Rate__c);
        System.assertEquals(Datetime.now().addMonths(0).format('MMMM'), newRates.Month__c);
        System.assertEquals(redirectPage.getUrl(), result.getUrl());
        // validate outdated Rates record
        //System.assert(rates.Close_Date__c != null);        
    }      
}