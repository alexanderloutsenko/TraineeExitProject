public class AL_EnterMeterReadingsController {

    public Monthly_Payment__c metersToInsert {get; set;}
    public Monthly_Payment__c existingMeters {get; set;}
    public static Datetime dynamicMonth { get { return Datetime.now().addMonths(-1); } }
    public static String userId = System.CurrentPageReference().getParameters().get('id');
    public Public_User__c currentUser ;
    public Boolean paymentExists { get; set; }
    public static Integer count = 0;
    
    public AL_EnterMeterReadingsController () {
        currentUser = [SELECT id, 
                            Name, 
                            Region__c 
                        FROM Public_User__c 
                        WHERE id = :userId];

        //Check whether payment for last month already exists
        checkPaymentExist();
    }

    public void checkPaymentExist () {
            List<Monthly_Payment__c> payRecsByUser = [
                 SELECT Id,
                        Electricity_Meter_Readings__c,
                        Gas_Meter_Readings__c,
                        Water_Meter_Readings__c,
                        Payment_Closed_Date__c,
                        Payment_Month__c              		 
                   FROM Monthly_Payment__c
                  WHERE Public_User__c = :userId
                    AND Payment_Month__c = :dynamicMonth.format('MMMM')];
      
        if(payRecsByUser.size() > 0) {
            existingMeters = payRecsByUser[0]; // if payment already exists show meter readings in read-only mode
            System.debug('** exists meters = '+existingMeters);
            count++;
            System.debug('** count='+count);
            //paymentExists = true;
        } else {
            //initialize the object to avoid NullPointerException on Payment creation
            metersToInsert = new Monthly_Payment__c();
        }
    }
      
        public PageReference submitNewMeter () {
            metersToInsert.Payment_Month__c = dynamicMonth.format('MMMM');
            metersToInsert.Region__c = currentUser.Region__c;
            metersToInsert.Public_User__c = userId;
            List<Rates__c> rates = [
                SELECT Electricity_Rate__c, Gas_Rate__c, Water_Rate__c, Region__r.Id
                  FROM Rates__c
                 WHERE Region__c =: currentUser.Region__c
                  LIMIT 1];
            if(rates.size() > 0) {
                metersToInsert.Rates__c = rates[0].Id;
            }
            //insert new record
            insert metersToInsert;
            // nullify the object to clean up the fields on Create Payment section on the VF page
            //metersToInsert = new Monthly_Payment__c();
            checkPaymentExist();
            return new Pagereference ('/AL_EnterMeterReadings?id='+userId);
            //return null;
        }
        
        public List<Monthly_Payment__c> getMetersFromController () { //getContsFromController
            List<Monthly_Payment__c> metersList = [SELECT 
                                        Payment_Month__c , 
                                        Electricity_Meter_Readings__c,
                                        Gas_Meter_Readings__c ,
                                        Water_Meter_Readings__c
                                        FROM Monthly_Payment__c 
                                        WHERE Public_User__r.Id =: userId 
                                        ORDER BY CreatedDate DESC
                                        LIMIT 5];
            return metersList;
        }

}