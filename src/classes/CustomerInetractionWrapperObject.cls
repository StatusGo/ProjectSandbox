global class CustomerInetractionWrapperObject{       
        webService String AccountId{get;set;}       
        webService String patientCity{get;set;}       
        webService Date patientDOB{get;set;}
        webService String patientGender{get;set;}       
        webService String patientState{get;set;}       
        webService Double patientWeightLbs{get;set;}       
        webService String patientPostalCode{get;set;}
        webService String relationshipTopatient{get;set;}
        webService String searchBy{get;set;}  // 1. Chief Complaint   2. Protocol Title/Keyword
        webService String searchText{get;set;}
        webService String userEmail{get;set;}
        webService String userId{get;set;}
        webService String userName{get;set;}
    }