# ErrorLogUtils
This package contains an Apex Class and Custom Object to log errors in the database. ESPECIALLY useful for catching errors in async operations such as Future, Queueable, and Schedulable.

<a href="https://githubsfdeploy.herokuapp.com/app/githubdeploy/kevina-code/ErrorLogUtils?ref=master">
  <img src="https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/src/main/webapp/resources/img/deploy.png" alt="Deploy to Salesforce" />
</a>


Usage:
1. Scenario: inserting records in an async context where 'all or nothing' parameter is set to false.
```java
Database.SaveResult[] srList = Database.update(accounts, false);
ErrorLogUtils.processSaveResults(
  srList,              
  'Account update',  /*context*/
  'AccountTriggerHandler.SomeFutureMethod' /*class name and method*/
);
```

2. Scenario: handling exceptions in an async context such as Future, Queueable, Schedulable
```java
try {
  // do something, like insert records
  insert records;
} catch (exception e) {
  ErrorLogUtils.createErrorLog(
    e,
    'Some context',
    'PaymentTriggerHandler.generateSummaryOfPaymentPdf',
     null /* optionally pass a comma dilimited list of record ids here, such as in the case of a failed records update */
  );
}
```

![image](https://user-images.githubusercontent.com/124932501/224376964-b88a6b31-9187-45d8-8a58-696aab9a9db8.png)
