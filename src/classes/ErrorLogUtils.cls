/**
 * Author     : Kevin Antonioli (braveitnow@pm.me)
 * Description: Utils class for creating/managing error logs
 *              Useful ESPECIALLY for logging reportable errors for async database operations like Future, Queueable, Schedulable
 * Created    : 12.31.2021
 *
 * Revisions:
 * Date : Name : Notes
 */
public without sharing class ErrorLogUtils {
  public ErrorLogUtils() {
  }

  /**
   * @description : method to create error log, given certain params
   * @param   e             the exception that was caught (if applicable)
   * @param   databaseError database error captured from a SaveResult (if applicable)
   * @param   context       the context under which the error occurred (ex: Account insert)
   * @param   errorSource   the source (usually an apex class name.method) of the error
   * @param   referenceId   the Id of a record that the error occurred for (if applicable)
   * @param   doInsert      whether or not to insert the error log within this method
   * @return  errorLog      the error log record created by the method
   **/
  public static Error_Log__c createErrorLog(
    Exception e,
    Database.error databaseError,
    String context,
    String errorSource,
    String referenceId,
    Boolean doInsert
  ) {
    Error_Log__c errorLog = new Error_Log__c();
    errorLog.Error_Message__c = e?.getMessage();
    errorLog.Error_Message__c = databaseError != null
      ? databaseError.getMessage()
      : errorLog.Error_Message__c;
    errorLog.Error_Fields__c = databaseError == null
      ? null
      : JSON.serialize(databaseError.getFields());
    errorLog.Error_Status_Code__c = databaseError == null
      ? null
      : JSON.serialize(databaseError.getStatusCode()).left(255);
    errorLog.Stack_Trace_String__c = e?.getStackTraceString();
    errorLog.Line_Number__c = e?.getLineNumber();
    errorLog.Type__c = e?.getTypeName().Left(255);
    errorLog.Error_Source__c = errorSource?.left(255);
    errorLog.Context__c = context?.Left(255);
    errorLog.Reference_Id__c = referenceId;

    if (doInsert) {
      insert errorLog;
    }
    return errorLog;
  }

  /**
   * @description : overloaded method, create Error Log using an Exception instead of a Database.error
   * @param   all params are a subset of main method above
   * @return  Error_Log__c
   * Includes the doInsert dynamic parameter
   */
  public static Error_Log__c createErrorLog(
    Exception e,
    String context,
    String errorSource,
    String referenceId,
    Boolean doInsert
  ) {
    return createErrorLog(e, null, context, errorSource, referenceId, doInsert);
  }

  /**
   * @description: overloaded method, create Error Log using an Exception instead of a Database.error
   * @param   all params are subset of main method above
   * @return  Error_Log__c
   */
  public static Error_Log__c createErrorLog(
    Exception e,
    String context,
    String errorSource,
    String referenceId
  ) {
    return createErrorLog(e, null, context, errorSource, referenceId, true);
  }

  /**
   * @description: overloaded method, create Error Log using a database.error instead of an exception
   * @param   all params are subset of main method above
   * @return  Error_Log__c
   */
  public static Error_Log__c createErrorLog(
    Database.error databaseError,
    String context,
    String errorSource,
    String referenceId,
    Boolean doInsert
  ) {
    return createErrorLog(
      null,
      databaseError,
      context,
      errorSource,
      referenceId,
      doInsert
    );
  }

  /**
   * @description: process a list of save results for potential errors
   * @param   srList                the list of save results potentially containing errors
   * @param   context               the error context, if applicable (ex: User update)
   * @param   potentialErrorSource  the potential error source, if applicable (ex: AccountTriggerHandler.updateAccountFields)
   * @return  void
   */
  public static void processSaveResults(
    List<Database.SaveResult> srList,
    String context,
    String potentialErrorSource
  ) {
    // Iterate through each failed record:
    List<Error_Log__c> errorLogsToCreate = new List<Error_Log__c>();
    for (Database.SaveResult sr : srList) {
      if (!sr.isSuccess()) {
        // Operation failed, so get all errors and create an Error Log for each one
        for (Database.Error err : sr.getErrors()) {
          errorLogsToCreate.add(
            ErrorLogUtils.createErrorLog(
              err,
              context,
              potentialErrorSource,
              sr.getId(),
              false
            )
          );
        }
      }
    }

    if (!errorLogsToCreate.isEmpty()) {
      Database.SaveResult[] srErrorList = Database.insert(
        errorLogsToCreate,
        false
      );
    }
  }
}