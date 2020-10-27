@isTest
private class TestAL_SendEmailController {
    private static Public_User__c u;
    private static PageReference pageRef;

    @testSetup static void setup() {
        // Test data setup    
		Public_User__c user = AL_TestDataFactory.createUser(false, null);// regular user
    } 
    
    private static void setUserAndPageRef() {
        // set user
        u = [SELECT Id FROM Public_User__c ];
        // set page reference object
        pageRef = Page.AL_SendEmail;
		pageRef.getParameters().put('id', u.Id);
    }
    
    @isTest static void TestConstructor() {
        // Test data setup
		setUserAndPageRef(); 
        Test.setCurrentPage(pageRef);
        
        // Perform test
        Test.startTest();
        AL_SendEmailController result = new AL_SendEmailController();
        Test.stopTest();
        
        // validate results
        System.assertEquals(u.Id, result.userId);
        System.assertEquals(u.Id, result.pageUser.Id);
    } 
    
    @isTest static void TestSendEmailPositive () {
        // Test data setup
		setUserAndPageRef(); 
        Test.setCurrentPage(pageRef);
        AL_SendEmailController controller = new AL_SendEmailController();
        controller.sendTo = 'alexander.loutsenko@sparkybit.com';    
        controller.replyToEmail = 'emailToReply@i.ua';
        controller.subject = 'Test email to manager';
        controller.emailBody = 'Hi, please check my payment';
        
        // Perform test        
        Test.startTest();
        PageReference result = controller.sendEmail();
        Integer invocations = Limits.getEmailInvocations();//Returns the number of email invocations (such as sendEmail) that have been called
        Test.stopTest();
        
        // validate results
        System.assertEquals(1, invocations, 'An email should be sent'); 
        System.assertEquals(null, result);        
    }
    
    @isTest static void TestSendEmailNegative () {
        // Test data setup
		setUserAndPageRef(); 
        Test.setCurrentPage(pageRef);
        AL_SendEmailController controller = new AL_SendEmailController();
        controller.sendTo = 'alexander.loutsenko*sparkybit.com@';//invalid sendTo email address    
        controller.replyToEmail = 'emailToReply@i.ua';
        controller.subject = 'Test email to manager';
        controller.emailBody = 'Hi, please check my payment';
        
        // Perform test        
        Test.startTest();
        PageReference result = controller.sendEmail();
        Integer invocations = Limits.getEmailInvocations();//Returns the number of email invocations (such as sendEmail) that have been called        
        Test.stopTest();
        
        // validate results
        ApexPages.Message[] messages = ApexPages.getMessages();
        System.assertEquals(1, messages.size());//check that only 1 message is rendered to appear on result VF page
            //System.assertEquals('Message 1', messages[0].getDetail());
        System.assertEquals(0, invocations, 'An email should not be sent'); 
        System.assertEquals(null, result);        
    }
}