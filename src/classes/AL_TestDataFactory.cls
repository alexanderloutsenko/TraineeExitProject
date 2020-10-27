@isTest
public with sharing class AL_TestDataFactory {
    //public static String regionId;
    //public static String ratesId;
    //public static String standReadId;
    //public static String publicUserId;
    public static String month = Datetime.now().addMonths(-1).format('MMMM');

    //create region
    public static Region__c createRegion () {
        Region__c reg = new Region__c(
            Name     = 'IL - Chicago',
            State__c = 'IL',
            City__c  = 'Chicago'
        );
        insert reg;
        //regionId = reg.Id;
        return reg;
    } 
    //create rates
    public static Rates__c createRates (String region) {
        Rates__c rate = new Rates__c(
            Electricity_Rate__c = 1,
            Gas_Rate__c         = 1,
            Water_Rate__c       = 1,
            Region__c           = region,
            Month__c	        = month,
            Close_Date__c       = null
        );
        insert rate;
        //ratesId = rate.Id;
        return rate;
    }

    //create standard readings
    public static Standard_Readings__c createStandReadings (String region) {
        Standard_Readings__c standReadings = new Standard_Readings__c(
            Electricity_Standard_Readings__c = 1,
            Gas_Standard_Readings__c         = 1,
            Water_Standard_Readings__c       = 1,
            Region__c                        = region
        );
        insert standReadings;
        //standReadId = standReadings.Id;
        return standReadings;
    }    

    // create public user
    public static Public_User__c createUser (Boolean isManager, String region) {

        Public_User__c pu = new Public_User__c();
        
        if(isManager) {
            pu.Login_Name__c  = 'Manager';
            pu.Password__c    = 'pass';
            pu.Name           = 'Zigmund Abram';
            pu.Manager__c     = true;
            pu.Region__c      = region;     
        } else {
            pu.Login_Name__c  = 'TestUser';
            pu.Password__c    = 'pass';
            pu.Name           = 'Turik Prokop';
            pu.Region__c      = region;  
        }
        insert pu;
        //publicUserId = pu.Id;
        return pu;
    }

    //create monthly payments list for view payments history testing
    public static List<Monthly_Payment__c> createPayments(Integer numPayments, String userId, String rates, String region) {
        List<Monthly_Payment__c> payments = new List<Monthly_Payment__c>();

        for(Integer i = numPayments; i > 0; i--) {
            Monthly_Payment__c p = new Monthly_Payment__c(
                Electricity_Meter_Readings__c = 500,
                Gas_Meter_Readings__c         = 10,
                Water_Meter_Readings__c       = 10,
                Payment_Closed_Date__c        = System.today().addMonths(-i), //Datetime.now().addMonths(-i),
                Payment_Month__c              = Datetime.now().addMonths(-(i+1)).format('MMMM'),
                Payment_Fullness__c           = 'Fully',
                Payment_Status__c             = 'Closed',
                Public_User__c                = userId, // use user Id received from test method as a parameter
                Rates__c                      = rates,
                Region__c                     = region,
                Sum_Already_Payed__c          = (100 + i*3)            
            );
            payments.add(p);
        }
        insert payments;
        return payments;
    }
    
    //create Monthly Payment not closed but with readings populated
    public static Monthly_Payment__c createOpenPayment(String userId, String rates, String region) {
        
        Monthly_Payment__c payment = new Monthly_Payment__c(
                Electricity_Meter_Readings__c = 500,
                Gas_Meter_Readings__c         = 10,
                Water_Meter_Readings__c       = 10,
                Payment_Month__c              = Datetime.now().addMonths(-1).format('MMMM'),
                Public_User__c                = userId, // user id from received parameter
                Rates__c                      = rates,  // rates Id based on user
                Region__c                     = region  //  region Id based on user  
            );
       
        insert payment;
        return payment;
    }
    
    public static List<SelectOption> getStateOptions() {
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
    
    public static List<SelectOption> getCityOptions(String selectedState) {
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
        return cityOptions ;
  }
}