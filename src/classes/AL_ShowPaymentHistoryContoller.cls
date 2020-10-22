public class AL_ShowPaymentHistoryContoller {

    public static String userId = System.CurrentPageReference().getParameters().get('id');
    public List<Monthly_Payment__c> payRecsByUser { get; set; }

    public AL_ShowPaymentHistoryContoller () {
        payRecsByUser = [SELECT Id,
                                Electricity_Meter_Readings__c,
                                Gas_Meter_Readings__c,
                                Water_Meter_Readings__c,
                                Payment_Closed_Date__c,
                                Sum_Already_Payed__c,
                                Payment_Status__c,
                                Region__c,
                                Payment_Month__c              		 
                           FROM Monthly_Payment__c
                          WHERE Public_User__c = :userId
                          Order by CreatedDate Desc];
    }

}