public class AL_UserHomePageController {

    public String userId {get; set;}
    public Public_User__c pageUser {get; set;}
    public String month { get { return Datetime.now().addMonths(-1).format('MMMM'); } }

    public AL_UserHomePageController () {
        // get user Id
        userId = System.CurrentPageReference().getParameters().get('id');
        // get user data
        pageUser = [SELECT Id,
                          Name,
                          Region__r.Name
                     FROM Public_User__c
                    WHERE Id =: userId];
    }

}