public class AL_ManagerPaymentHistoryController {

    public String paymentId {get; set;}
    public List<Monthly_Payment__c> paymentsFromController {get; set;}
    public Monthly_Payment__c recordToUpdate {get; set;}
    public String userId {get; set;}
    public Public_User__c manager {get; set;}
    public Integer paymentAdjustment {get; set;}
    
    public AL_ManagerPaymentHistoryController() {
        // get user Id
        userId = System.CurrentPageReference().getParameters().get('id');
        // get user data
        manager = [SELECT Id,
                          Name,
                          Region__c
                     FROM Public_User__c
                     WHERE Id =: userId];
        // grab list of payments for current user based on the user's region
        paymentsFromController = [SELECT Id, Name,
                                        Payment_Closed_Date__c,
                                        Payment_Month__c,
                                        Payment_Fullness__c,
                                        Payment_Status__c,
                                        Public_User__c,
                                        Public_User__r.Name,
                                        Rates__c,
                                        Region__c,
                                        Recommended_Payment_Sum__c,
                                        Remaining_Sum_for_Payment__c,
                                        Sum_Already_Payed__c                  		 
                                    FROM Monthly_Payment__c
                                    WHERE Region__c =: manager.Region__c
                                ORDER BY CreatedDate DESC];
    }

    public PageReference fetchDetail () {
        // get record to update
        if (paymentId != null){
            recordToUpdate = [SELECT Id, Name,
                                     Payment_Closed_Date__c,
                                     Payment_Month__c,
                                     Payment_Fullness__c,
                                     Payment_Status__c,
                                     Public_User__c,
                                     Rates__c,
                                     //Region__c,
                                     Recommended_Payment_Sum__c,
                                     Remaining_Sum_for_Payment__c,
                                     Sum_Already_Payed__c                  		 
                                FROM Monthly_Payment__c
                                WHERE Id =: paymentId];
        }  
        paymentAdjustment = 0;
        System.debug('** recordToUpdate = '+recordToUpdate);         
        //PageReference pageRef = new PageReference('/AL_ManagerPaymentHistory?id='+userId);
        //return pageRef;
        return null;
    }

    public PageReference doUpdate () {
        // form data to update the record with

        // do DML call

        //nullify recordToUpdate

        return null;
    }
}