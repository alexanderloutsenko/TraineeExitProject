public class AL_EnterMeterReadingsController {
    public static Datetime dynamicMonth { get { return Datetime.now().addMonths(-1); } }
    //public string pageRef = System.currentPageReference().getURL();
    public WrapPublicUserData activePublicUser { get; set; }
    public Monthly_Payment__c payRec { get; set; }
    public String selectedPaymentType { get; set; }
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
            	  SELECT Id,
                         Electricity_Meter_Readings__c,
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
    // check whether the payment record for last month already exists
    public PageReference noPaymentYet() {
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING,noPaymentYet));
        return null;
    }
    // Payment_Fullness__c picklist population
    public List<SelectOption> getOptions() {
        List<SelectOption> payOptions = new List<SelectOption>();        
        Schema.DescribeFieldResult fieldResult = Monthly_Payment__c.Payment_Fullness__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        for( Schema.PicklistEntry f : ple) {
            payOptions.add(new SelectOption(f.getLabel(), f.getValue()));
        }       
        return payOptions;
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
        return new PageReference('/AL_EnterMeterReadings?id='+activePublicUser.pubUserId);
    }

    public void checkPaymentFullness(Decimal mustPay, Decimal wantPay) {
        if(mustPay > wantPay && wantPay != 0) {
            selectedPaymentType = 'Partially';
             //System.debug('(1) if(mustPay > wantPay && wantPay != 0) = '+selectedPaymentType);                  
        } else {
            selectedPaymentType = 'Fully';
            customSum = payRec.Recommended_Payment_Sum__c;             
              //System.debug('(2) ELSE (mustPay <= wantPay) || wantPay == 0) = '+selectedPaymentType);  
        } 
    }
    
    public PageReference showMessage() {
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING,'Enter sum no less then 20$'));
        return null;        
    }

    public PageReference doPayment() {
        //first, perform REST Api with payment
        /* here will be the code to perform REST Api with payment 
        */

        //second, form Payment record to fulfill it with payment data     
        checkPaymentFullness(payRec.Recommended_Payment_Sum__c, customSum);
    
        Monthly_Payment__c payRecToUpdate = new Monthly_Payment__c();
        payRecToUpdate.Id = payRec.Id;
        if(selectedPaymentType == 'Partially') {
            payRecToUpdate.Payment_Status__c = 'Partial';// consider to get rid of this field by removing it from the object
        } else {
            payRecToUpdate.Payment_Status__c = 'Closed';// consider to get rid of this field by removing it the object
            payRecToUpdate.Payment_Closed_Date__c = Datetime.now();
        }
        payRecToUpdate.Payment_Fullness__c = selectedPaymentType;
        payRecToUpdate.Sum_Already_Payed__c = customSum;       		 
        System.debug('** '+payRecToUpdate);  
        //update Monthly_Payment__c record with payment data
        try{
            update payRecToUpdate;
        }
        catch(DmlException ex){
            ApexPages.addMessages(ex);
        }

        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING,'Your payment is successfull'));
        return null;
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