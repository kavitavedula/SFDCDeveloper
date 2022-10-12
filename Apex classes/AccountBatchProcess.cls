global class AccountBatchProcess implements Database.Batchable<sObject> {

    public static final String CUSTOMER_ACCOUNT = 'Customer_Account';
    
    // Start Method
    global Database.QueryLocator start(Database.BatchableContext BC) {
        // collect the batches of records or objects to be passed to execute
         
        String query = 'SELECT Id, Enterprise_Account_Status__c FROM Account where ' + 
            'RecordType.DeveloperName = : CUSTOMER_ACCOUNT';
        return Database.getQueryLocator(query);
    }
    // Execute Method
    global void execute(Database.BatchableContext BC, List<Account> accList) {
       
        // process each batch of records
        for(Account acc : accList) {
            if(acc.Enterprise_Account_Status__c == null)
                acc.Enterprise_Account_Status__c = 'Bronze';
        }
        try {
            // Update the Account Record
            update accList;
        
        } catch(Exception e) {
            System.debug(e);
        }
        
    }   
    
    global void finish(Database.BatchableContext BC) { 
        // Get the ID of the AsyncApexJob representing this batch job
        // from Database.BatchableContext.
        // Query the AsyncApexJob object to retrieve the current job's information.
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
          TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id = :BC.getJobId()];
          
        // Send an email to the Apex job's submitter notifying of job completion.
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {a.CreatedBy.Email};
        mail.setToAddresses(toAddresses);
        mail.setSubject('Apex Sharing Recalculation ' + a.Status);
        mail.setPlainTextBody
        ('The batch Apex job processed ' + a.TotalJobItems +
         ' batches with '+ a.NumberOfErrors + ' failures.');
         Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}