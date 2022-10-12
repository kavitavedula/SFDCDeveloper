@isTest
public class AccountBatchProcessTest{
   
   
   @testSetup static void testDataSetUp() {
      Id custAccountRecId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
                      .get('Customer_Account').getRecordTypeId();
       
       List<Account> accountList = new List<Account>();
       
       Account acct1 = new Account(Name = 'TestAccount1', RecordTypeId = custAccountRecId, Phone = '4081113467');
       Account acct2 = new Account(Name = 'TestAccount2', RecordTypeId = custAccountRecId, Phone = '4081113467');
       Account acct3 = new Account(Name = 'TestAccount3', RecordTypeId = custAccountRecId, Phone = '4081113467');
       Account acct4 = new Account(Name = 'TestAccount4', RecordTypeId = custAccountRecId, Phone = '4081113467');
       
       accountList.add(acct1);
       accountList.add(acct2);
       accountList.add(acct3);
       accountList.add(acct4);
       
       insert accountList;
   }
   
   @isTest 
   static void testBatchProcess(){
       Test.StartTest();
       AccountBatchProcess accountsBatch = new AccountBatchProcess();
       Database.executebatch(accountsBatch, 200);
       Test.StopTest();    
  
   
       // Verify accounts updated
       Account[] accUpdatedList = [SELECT Id, Enterprise_Account_Status__c FROM Account where 
           RecordType.DeveloperName = 'Customer_Account'];
       
       for(Account acc : accUpdatedList)
           System.assert(acc.Enterprise_Account_Status__c.Contains('Bronze'));
   }
   
}