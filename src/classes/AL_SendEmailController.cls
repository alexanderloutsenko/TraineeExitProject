public class AL_SendEmailController {
    
    public String userId { get; set; }
    public Public_User__c pageUser { get; set; }

    public String sendTo = 'alexander.loutsenko@sparkybit.com';
    public String replyToEmail { get; set; }
    public String subject { get; set; }
    public string emailBody { get; set; }
    public Boolean success { get; set; }
 
    public AL_SendEmailController () {
        // get user Id
        userId = System.CurrentPageReference().getParameters().get('id');
        // get user data
        pageUser = [SELECT Id,
                          Name,
                          Region__r.Name
                     FROM Public_User__c
                    WHERE Id =: userId];
    }

    public PageReference sendEmail () {

        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        string[] to = new string[] {sendTo}; 
        
        email.setToAddresses(to); 
        email.setReplyTo(replyToEmail);                    
        email.setSubject(subject);            
        email.setHtmlBody(emailBody);
        try{
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
            success = true;
        }catch(exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.error,e.getMessage()));
        }        
        return null;        
    }
}