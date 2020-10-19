public class AL_EnterMeterReadingsController {
    public static Datetime dynamicMonth { get { return Datetime.now().addMonths(-1); } }
    public string pageRef = System.currentPageReference().getURL();
    public WrapPublicUserData activePublicUser { get; set; }
    public Monthly_Payment__c payRec { get; set; }
    public Integer electro { get; set; }
    public Integer gas { get; set; }
    public Integer water { get; set; }
    public Decimal customSum { get; set; }
    public String noPaymentYet = 'You don\'t have payment record generated for last month yet';
     
    public AL_EnterMeterReadingsController() {
        // get public user id from URL       
        String publicUserId = System.CurrentPageReference().getParameters().get('id');
        // get user data + user's region
        activePublicUser = new WrapPublicUserData([SELECT id, Name, Region__c 
                              						 FROM Public_User__c 
                             						WHERE id = :publicUserId]);
        // check whether the user already has a payment for last month
        List<Monthly_Payment__c> payRecsByUser = [
            	  SELECT Electricity_Meter_Readings__c,
                  		 Gas_Meter_Readings__c,
                  		 Water_Meter_Readings__c,
                  		 Payment_Closed_Date__c,
                  		 Payment_Month__c,
                  		 Payment_Fullness__c,
                  		 Payment_Status__c,
                  	     Public_User__c,
                  		 Rates__c,
                  		 Region__c,
                  		 Recommended_Payment_Sum__c,
                         Remaining_Sum_for_Payment__c,
						 Sum_Already_Payed__c                  		 
                 	FROM Monthly_Payment__c
                   WHERE Public_User__c = :publicUserId
                     AND Payment_Month__c = :dynamicMonth.format('MMMM')];
        
        if(payRecsByUser.size() == 0) {
           noPaymentYet(); // if no payment exists show warning and input fields for inputing meter readings                   
        } else {
           payRec = payRecsByUser[0]; // if payment already exists show meter readings in read-only mode
        }
    }
    
    public PageReference noPaymentYet () {
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING,noPaymentYet));
        return null;
    }
    
    public PageReference saveReadings() {
        Monthly_Payment__c dataToSubmit = new Monthly_Payment__c();
        dataToSubmit.Electricity_Meter_Readings__c = electro;
        dataToSubmit.Gas_Meter_Readings__c         = gas;
        dataToSubmit.Water_Meter_Readings__c       = water;        
        dataToSubmit.Payment_Month__c              = dynamicMonth.format('MMMM');
        dataToSubmit.Public_User__c 			   = activePublicUser.pubUserId;
        dataToSubmit.Region__c 					   = activePublicUser.regionId;
        dataToSubmit.Rates__c					   = activePublicUser.rateId;

        System.debug(dataToSubmit);
        // insert new payment with only meter readings 
        // and the data helping with future calculations populated
        insert dataToSubmit;
        // refresh current page
		/*PageReference pageRef = new PageReference(ApexPages.currentPage().getUrl());
		pageRef.setRedirect(true);
		return pageRef;*/
        return null;
    }
    
    public void doPayment() {
        
    }
    
        //  wrapper class
    public class WrapPublicUserData {    
    //public Public_User__c pubUser {get;set;}
    public String pubUserName {get;set;}
    public Id pubUserId {get;set;} 
    public Id regionId {get;set;}
    public String paymentMonth {get;set;}
    public Id rateId {get;set;}        
    public Id stndRdngsId {get;set;}
    
     
    	public WrapPublicUserData (Public_User__c u){     
            pubUserName = u.Name;
            pubUserId = u.Id;
            regionId = u.Region__c;
            paymentMonth = dynamicMonth.format('MMMM');
            List<Rates__c> rates = [
                     SELECT Electricity_Rate__c, Gas_Rate__c, Water_Rate__c, Region__r.Id
					   FROM Rates__c
					  WHERE Region__c =: regionId
                       LIMIT 1];
            if(rates.size() > 0) {
                rateId = rates[0].Id;
            }

            List<Standard_Readings__c> stndRdngs = [
                		 SELECT Electricity_Standard_Readings__c,
                         		Gas_Standard_Readings__c,
                         		Water_Standard_Readings__c
                		   FROM Standard_Readings__c
                          WHERE Region__c =: regionId
            			  LIMIT 1];
            if(stndRdngs.size() > 0) {
                stndRdngsId = stndRdngs[0].Id;
            }

       	}
  	}    
}