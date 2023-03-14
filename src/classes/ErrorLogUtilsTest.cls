/**
 * Test class for ErrorLogUtils
 * Created : 12.31.2021 : Kevin Antonioli
 */
@isTest
private class ErrorLogUtilsTest {
  @isTest
  static void test_ExceptionErrorLog() {
    Account account = new Account(Name = 'Jenny Lemmons Magic');
    insert account;

    Test.startTest();
    account.Name = null;

    try {
      update account;
    } catch (Exception e) {
      String errorSource = 'ErrorLogUtilsTest.test_standard';
      ErrorLogUtils.createErrorLog(
        e,
        'Account update',
        errorSource,
        account.Id
      );
    }
    Test.stopTest();

    List<Error_Log__c> errorLogs = [SELECT Id FROM Error_Log__c];
    Assert.isTrue(!errorLogs.isEmpty());
  }

  @isTest
  static void test_DatabaseErrorLog() {
    Account account = new Account(Name = 'Jenny Lemmons Magic');
    Account account2 = new Account(); // intentially don't set name in order to capture a database error
    List<Account> accounts = new List<Account>{ account, account2 };

    Test.startTest();
    Database.SaveResult[] srList = Database.insert(accounts, false);
    ErrorLogUtils.processSaveResults(
      srList,
      'User update',
      'ErrorLogUtilsTest.test_DatabaseErrorLog'
    );
    Test.stopTest();

    List<Error_Log__c> errorLogs = [
      SELECT Id
      FROM Error_Log__c
      WHERE Context__c = 'User update'
    ];
    Assert.isTrue(!errorLogs.isEmpty());
  }
}