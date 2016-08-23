public class TriageNowLogging {

    public static void logCustomerInteraction(CustomerInetractionWrapperObject ciObj, String mode, String status){
        DateTime currentDateTime = Datetime.now();
        TriageNow_Customer_Interaction__c tnCI = new TriageNow_Customer_Interaction__c();
        tnCI.Current_App_Mode__c = mode;
        tnCI.Customer__c = ciObj.accountId;
        tnCI.Date_Time__c = currentDateTime;
        tnCI.Patient_City__c = ciObj.patientCity;      
        tnCI.Patient_DOB__c = ciObj.patientDOB;
        tnCI.Patient_Gender__c = ciObj.patientGender;       
        tnCI.Patient_State__c = ciObj.patientState;       
        tnCI.Patient_Weight_lbs__c = ciObj.patientWeightLbs;       
        tnCI.Patient_Zip_Postal_Code__c = ciObj.patientPostalCode; 
        tnCI.Relationship_to_Patient__c = ciObj.relationshipTopatient;
        tnCI.Search_By__c = ciObj.searchBy;  // 1. Chief Complaint   2. Protocol Title/Keyword
        tnCI.Search_Phrase__c = ciObj.searchText;
        tnCI.User_Email__c = ciObj.userEmail;
        tnCI.User_Id__c = ciObj.userId;
        tnCI.User_Name__c = ciObj.userName;
        tnCI.status__c = status;
        insert tnCI;
    }
    
}