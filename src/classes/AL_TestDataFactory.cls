public with sharing class AL_TestDataFactory {
    public static String regionId;
    public static String ratesId;
    public static String standReadId;
    public static String publicUserId;
    public static String month = Datetime.now().addMonths(-1).format('MMMM');

    //create region
    public static Region__c createRegion () {
        Region__c reg = new Region__c(
            Name     = 'IL - Chicago',
            State__c = 'IL',
            City__c  = 'Chicago'
        );
        insert reg;
        regionId = reg.Id;
        return reg;
    } 
    //create rates
    public static Rates__c createRates () {
        Rates__c rate = new Rates__c(
            Electricity_Rate__c = 1,
            Gas_Rate__c         = 1,
            Water_Rate__c       = 1,
            Region__c           = regionId,
            Month__c	        = month
        );
        insert rate;
        ratesId = rate.Id;
        return rate;
    }

    //create standard readings
    public static Standard_Readings__c createStandReadings () {
        Standard_Readings__c standReadings = new Standard_Readings__c(
            Electricity_Standard_Readings__c = 1,
            Gas_Standard_Readings__c         = 1,
            Water_Standard_Readings__c       = 1,
            Region__c                        = regionId
        );
        insert standReadings;
        ratesId = standReadings.Id;
        return standReadings;
    }    

    // create public user
    public static Public_User__c createUser (Boolean isManager) {

        Public_User__c pu = new Public_User__c();
        
        if(isManager) {
            pu.Login_Name__c  = 'Manager';
            pu.Password__c    = 'pass';
            pu.Name           = 'Zigmund Abram';
            pu.Manager__c     = true;
            pu.Region__c      = regionId;     
        } else {
            pu.Login_Name__c  = 'TestUser';
            pu.Password__c    = 'pass';
            pu.Name           = 'Turik Prokop';
            pu.Region__c      = regionId;  
        }
        insert pu;
        publicUserId = pu.Id;
        return pu;
    }

    //create Monthly payment
    public static List<Monthly_Payment__c> createPayments(Integer numPayments, String userId) {
        List<Monthly_Payment__c> payments = new List<Monthly_Payment__c>();

        for(Integer i = numPayments; i > 0; i--) {
            Monthly_Payment__c p = new Monthly_Payment__c(
                Electricity_Meter_Readings__c = 500,
                Gas_Meter_Readings__c         = 10,
                Water_Meter_Readings__c       = 10,
                Payment_Closed_Date__c        = Datetime.now().addMonths(-(i+1)),
                Payment_Month__c              = Datetime.now().addMonths(-i).format('MMMM'),
                Payment_Fullness__c           = 'Fully',
                Payment_Status__c             = 'Closed',
                Public_User__c                = publicUserId,
                Rates__c                      = ratesId,
                Region__c                     = regionId,
                Sum_Already_Payed__c          = (100 + i*3)            
            );
            payments.add(p);
        }
        insert payments;
        return payments;
    }
}