public class AL_UpdateRatesController {

    public String userId;
    public String regionId;
    public String regionName { get; set; }
    public Rates__c actualRates = new Rates__c();
    public String userName { get; set; }
    public Decimal electro { get; set; }
    public Decimal gas { get; set; }
    public Decimal water { get; set; }
    public String alertMessage { get; set; }
    public String month { get { return Datetime.now().addMonths(0).format('MMMM'); } }

    public AL_UpdateRatesController () {
        // get public user id from URL       
        userId = System.CurrentPageReference().getParameters().get('id');
        // get user data + user's region data
        Public_User__c usr = [SELECT id, Name, Region__c, Region__r.Name 
                              	FROM Public_User__c 
                               WHERE id = :userId];

        regionId = usr.Region__c;
        regionName = usr.Region__r.Name;
        // get data about the rates which are currently in use in user's region
        List <Rates__c> ratesList = [SELECT Id,
                                            Electricity_Rate__c,
                                            Gas_Rate__c,
                                            Water_Rate__c, 
                                            Region__c,
                                            Close_Date__c      		 
                 	                   FROM Rates__c
                                      WHERE Region__c =: regionId
                                        AND Close_Date__c = NULL
                                   ORDER BY CreatedDate DESC];
        
        if(ratesList.size() > 0) {
            actualRates = ratesList[0]; 
            // populate controller's properties
            electro = actualRates.Electricity_Rate__c;
            gas = actualRates.Gas_Rate__c;
            water = actualRates.Water_Rate__c;
        }
    }

    public PageReference createRate () {
        List<Rates__c> dataToUpsert = new List<Rates__c>();
        //create new record
        Rates__c newRates = new Rates__c(
            Electricity_Rate__c = electro,
            Gas_Rate__c         = gas,
            Water_Rate__c       = water,
            Region__c           = regionId,
            Month__c	        = month
        );
        dataToUpsert.add(newRates);
        //close previous actual record
        System.debug('** newRates = '+newRates);
        System.debug('** actualRates = '+actualRates);
        actualRates.Close_Date__c = System.today();
        System.debug('** actualRates with Close Date is = '+actualRates);
        dataToUpsert.add(actualRates);
        try {
            upsert dataToUpsert; 
            alertMessage = 'Your region rates have been successfully updated'; 
            return new PageReference('/AL_ManagerHomePage?id=' + userId);   
        } catch (DmlException e) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING,'Your updates have not been saved'));
            return null;
        }
      
        
    }
}