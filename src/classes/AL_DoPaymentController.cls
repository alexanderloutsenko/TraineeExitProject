public class AL_DoPaymentController {
    public static Datetime dynamicMonth { get { return Datetime.now().addMonths(-1); } }
    public WrapPublicUserData activePublicUser { get; set; }
    public Monthly_Payment__c payRec { get; set; }
    public String selectedPaymentType { get; set; }
    public Boolean fullyPaid { get; set; }
    public Decimal customSum { get; set; }
    public String noPaymentYet = 'You don\'t have payment record generated for last month yet';
     
    public AL_DoPaymentController() {
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
           if(payRec.Recommended_Payment_Sum__c == payRec.Sum_Already_Payed__c || payRec.Payment_Closed_Date__c != null){
                fullyPaid = true;
           } else {
                fullyPaid = false; 
                selectedPaymentType = 'Partially';
           }
           customSum = 0;          
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

    public void checkPaymentFullness(Decimal mustPay, Decimal wantPay, Decimal alreadyPayedSum) {
        if(alreadyPayedSum == 0) {
            if(mustPay > wantPay && wantPay != 0) {
                selectedPaymentType = 'Partially';
                System.debug('(1a) if(mustPay > wantPay && wantPay != 0) = '+selectedPaymentType);
                System.debug('(1a) mustPay = '+ mustPay+' & wantPay = '+wantPay+' & alreadyPayedSum = '+alreadyPayedSum);

            } else {
                selectedPaymentType = 'Fully';
                customSum = payRec.Recommended_Payment_Sum__c;             
                System.debug('(1b) ELSE (mustPay <= wantPay) || wantPay == 0) = '+selectedPaymentType);
                System.debug('(1b) mustPay = '+ mustPay+' & wantPay = '+wantPay+' & alreadyPayedSum = '+alreadyPayedSum);  
            }
            System.debug(' ** (1c) checkPaymentFullness mehtod inside of  if(alreadyPayedSum == 0) and customSum = '+customSum);
            System.debug('(1c) mustPay = '+ mustPay+' & wantPay = '+wantPay+' & alreadyPayedSum = '+alreadyPayedSum);
        } else {
            if(mustPay > wantPay + alreadyPayedSum && wantPay != 0) {
                selectedPaymentType = 'Partially';                
                System.debug('(2a) if(mustPay > wantPay && wantPay != 0) = '+selectedPaymentType); 
                System.debug('(2a) mustPay = '+ mustPay+' & wantPay = '+wantPay+' & alreadyPayedSum = '+alreadyPayedSum);
            } else {
                selectedPaymentType = 'Fully';                         
                System.debug('(2b) ELSE (mustPay <= wantPay) || wantPay == 0) = '+selectedPaymentType);  
                System.debug('(2b) mustPay = '+ mustPay+' & wantPay = '+wantPay+' & alreadyPayedSum = '+alreadyPayedSum);
            }
            customSum = customSum + alreadyPayedSum; 
            System.debug(' ** (2c) checkPaymentFullness mehtod inside of ELSE of if(alreadyPayedSum == 0) and customSum ='+customSum);
            System.debug('(2c) mustPay = '+ mustPay+' & wantPay = '+wantPay+' & alreadyPayedSum = '+alreadyPayedSum);                       
        } 
    }
    
    public PageReference doPayment() {
        //first, perform REST Api with payment
        /* here will be the code to perform REST Api with payment 
        */

        //second, form Payment record to fulfill it with payment data     
        checkPaymentFullness(payRec.Recommended_Payment_Sum__c, customSum, payRec.Sum_Already_Payed__c);
        System.debug(':: inside doPayment method (after checkPaymentFullness() method call) - payRec.Recommended_Payment_Sum__c = '+ payRec.Recommended_Payment_Sum__c+' & customSum = '+customSum+' & payRec.Sum_Already_Payed__c = '+payRec.Sum_Already_Payed__c);
        Monthly_Payment__c payRecToUpdate = new Monthly_Payment__c();
        payRecToUpdate.Id = payRec.Id;
        payRecToUpdate.Sum_Already_Payed__c = customSum; 
        System.debug(':: before insert payRecToUpdate.Sum_Already_Payed__c = '+payRecToUpdate.Sum_Already_Payed__c+' & customSum = '+customSum); 
        if(selectedPaymentType == 'Partially') {
            payRecToUpdate.Payment_Status__c = 'Partial';// consider to get rid of this field by removing it from the object
        } else {
            payRecToUpdate.Payment_Status__c = 'Closed';// consider to get rid of this field by removing it the object
            payRecToUpdate.Payment_Closed_Date__c = Datetime.now();
        }
        payRecToUpdate.Payment_Fullness__c = selectedPaymentType;
      		 
        System.debug(':: before insert record='+payRecToUpdate);  
        //update Monthly_Payment__c record with payment data
        try{
            update payRecToUpdate;
        } catch(DmlException ex){
            ApexPages.addMessages(ex);
        }

        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING,'Your payment is successfull'));
        return new Pagereference ('/AL_DoPayment?id='+payRec.Public_User__c);
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
                     SELECT Electricity_Rate__c, Gas_Rate__c, Water_Rate__c, Region__r.Id, Close_Date__c
					   FROM Rates__c
                      WHERE Region__c =: regionId
                        AND Close_Date__c = NULL
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