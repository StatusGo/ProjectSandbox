global class KeywordSearchWSDl1
{      
        

    webService static string keywordOrtitle(string alphabet,string catagoryref,Boolean Officehours,string Gender,boolean istitle,string input){
       CustomerInetractionWrapperObject ciwo = (CustomerInetractionWrapperObject)JSON.deserialize(input,CustomerInetractionWrapperObject.class);
          Account acct = [Select Id, TriageNow_Mode__c from Account where Id = :ciwo.accountId and IsDeleted = false LIMIT 1];         
        WrapperForAlgorithCards  Consolidated = new WrapperForAlgorithCards();
         Consolidated.ALgorithm = new List<AlgoreturnVal>(); 
        string alphabet1; 
        if(alphabet ==  null || alphabet == ''){
            alphabet1 = 'A%';
        }else {
            alphabet1 = alphabet+'%';  
        }

        
           system.debug('Officehours'+Officehours);
                system.debug('Gender'+Gender);
       //check if algoid is send appropriately.
         
     
         set<string> catagory = new set<string>();

          boolean IsAdult =  isLicenceAvailable('Adult',Officehours,ciwo.accountId);          
          boolean IsPediatric =  isLicenceAvailable('Pediatric',Officehours,ciwo.accountId);

            if(catagoryref.contains('Both')) {
                    if(IsPediatric){
                        catagory.add('Pediatric');  
                    }

                    if(IsAdult){
                         catagory.add('Adult');   
                    }                   
                    
            }else if(catagoryref.contains('Adult') && IsAdult){
                    catagory.add('Adult');
            }else if(catagoryref.contains('Pediatric') && IsPediatric){
                    catagory.add('Pediatric');
            }else{
                logCustomerInteraction(ciwo, acct.TriageNow_Mode__c, 'Error');
                returnWrapperObject Wrapobja = new returnWrapperObject();  
                Wrapobja.Error ='This search is currently disabled for your account. Please request TriageNow administrator to enable the search.';
                return Wrapobja.Error;
            }             
           
            system.debug(catagory);
                                  
         //to bring all the 
            string APOH = 'Adult and Pediatric / OH';
            string AAH = 'Adult / AH';
            string PAH = 'Pediatric / AH';
            string Triagenowimport = 'Select id from TriageNow_Import_Database__c where';
            
            if(Officehours == true ){
                 Triagenowimport += ' Db_Alias__c = \'' +APOH+ '\'';            
            }else if(Officehours == false && catagory.contains('Pediatric') && catagory.contains('Adult')){
              list<string> ss = new List<string>();
              ss.add(AAH);
              ss.add(PAH);
             Triagenowimport += ' Db_Alias__c IN : ss';   
            }else if(Officehours == false && catagory.contains('Pediatric')){
                 Triagenowimport += ' Db_Alias__c = \'' +PAH + '\'';         
            }else if(Officehours == false && catagory.contains('Adult')) {
                 Triagenowimport += ' Db_Alias__c = \'' +AAH+ '\'';           
            }

            system.debug(Triagenowimport);

            List<TriageNow_Import_Database__c> TriagenowimportIDS  = database.query(Triagenowimport);
            system.debug('TriagenowimportIDS'+TriagenowimportIDS);

            //convert it into string 
            List<string> TNDb = new list<string>();
            for(TriageNow_Import_Database__c tt : TriagenowimportIDS){
                 TNDb.add(string.valueof(tt.get('id'))); 
            }
            
            string Result ;

           if(!istitle){ 
            List<TriageNow_AlgorithmSearchWord__c> ALgosearchword = [SELECT AD_AlgorithmID__c,AD_SearchWord__c
                                                                     FROM TriageNow_AlgorithmSearchWord__c
                                                                     WHERE AD_SearchWord__c like: alphabet1
                                                                     AND TriageNow_Import_Database__c IN:TNDb
                                                                     order by AD_SearchWord__c ASC LIMIT 1000];   

                for(TriageNow_AlgorithmSearchWord__c tt : ALgosearchword){                                                     
                    AlgoreturnVal Algoretval = new AlgoreturnVal();                           
                    Algoretval.AlgorithmID = tt.AD_AlgorithmID__c;
                    Algoretval.Title = tt.AD_SearchWord__c;
                    Consolidated.ALgorithm.add(Algoretval);
                  }    
                  system.debug(Consolidated);
            Result = JSON.Serialize(Consolidated);  


             }else if(istitle){

           List<TriageNow_Algorithm__c> ALgorithm1 = [ SELECT AlgorithmID__c,Title__c
                                                  FROM TriageNow_Algorithm__c 
                                                  WHERE Title__c like: alphabet1
                                                  AND Status__c =: 'Active'
                                                  AND category__c IN : catagory
                                                  AND TriageNow_Import_Database__c IN:TNDb
                                                  AND Gender__c like : Gender                                                   
                                                  Order by Title__c Asc LIMIT 1000];

                 for(TriageNow_Algorithm__c tt : ALgorithm1){                                                     
                    AlgoreturnVal Algoretval = new AlgoreturnVal();                           
                    Algoretval.AlgorithmID = tt.AlgorithmID__c;
                    Algoretval.Title = tt.Title__c;
                    Consolidated.ALgorithm.add(Algoretval);
                  }   
                  system.debug('algo'+Consolidated);
              Result = JSON.Serialize(Consolidated);    
             }                                      
             return Result;           
    }  


    webService static Boolean IsAccountValid(String acctId){
        List<Account> acct = [Select Id from Account where Id = :acctId and IsDeleted = false LIMIT 1];
        if(acct != null && acct.size() > 0){
            return true;
        }
        return false;
    }
    
    webService static Boolean isLicenceAvailable(String category, Boolean officeHours, String accountId) {
        Account account = [Select Id, Adult_AH_Content_Enabled__c, Adult_OH_Content_Enabled__c, Pediatric_AH_Content_Enabled__c, Pediatric_OH_Content_Enabled__c, NLP_Enabled__c, TriageNow_Mode__c from Account where Id = :accountId and IsDeleted = false LIMIT 1];

        if(account.Adult_AH_Content_Enabled__c == true && category == 'Adult' && officeHours == false){
            return true;
        } else if(account.Adult_OH_Content_Enabled__c == true && category == 'Adult' && officeHours == true){
            return true;
        } else if(account.Pediatric_AH_Content_Enabled__c == true && category ==  'Pediatric'  && officeHours == false){
            return true;
        } else if(account.Pediatric_OH_Content_Enabled__c == true && category == 'Pediatric' && officeHours == true){
            return true;
        } else if(account.NLP_Enabled__c == true && category == 'NLP'){
            return true;
        }
        return false;
    }

    webService static void logCustomerInteraction(CustomerInetractionWrapperObject ciObj, String mode, String status){
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
    
    
    //catagory will give me adult/pediatric
        //office hours: in offcie or not in offce
        //gender will give you gender       
        //this class is used to discover the TNimport databse
        //SpecificAlgoID this is used to distinguish between algoids and keyword.   
    webService static string Symptoms(string Symptom,string catagoryref,Boolean Officehours,string Gender,Boolean SpecificAlgoID, String input,boolean Hospice,integer offsetSize){        
        
        CustomerInetractionWrapperObject ciwo = (CustomerInetractionWrapperObject)JSON.deserialize(input,CustomerInetractionWrapperObject.class);
        Account acct = [Select Id, TriageNow_Mode__c from Account where Id = :ciwo.accountId and IsDeleted = false LIMIT 1];         
    
     if(Symptom!= null){       
    
                
                system.debug('Officehours'+Officehours);
                system.debug('Gender'+Gender);
       //check if algoid is send appropriately.
         
        set<string> catagory = new set<string>();

          boolean IsAdult =  isLicenceAvailable('Adult',Officehours,ciwo.accountId);          
          boolean IsPediatric =  isLicenceAvailable('Pediatric',Officehours,ciwo.accountId);

            if(catagoryref.contains('Both')){
                    if(IsPediatric){
                        catagory.add('Pediatric');  
                    }

                    if(IsAdult){
                         catagory.add('Adult');   
                    }          
            }else if(catagoryref.contains('Adult') && IsAdult){
                    catagory.add('Adult');
            }else if(catagoryref.contains('Pediatric') && IsPediatric){
                    catagory.add('Pediatric');
            }else{
                logCustomerInteraction(ciwo, acct.TriageNow_Mode__c, 'Error');
                returnWrapperObject Wrapobja = new returnWrapperObject();  
                Wrapobja.Error ='This search is currently disabled for your account. Please request TriageNow administrator to enable the search.';
                return Wrapobja.Error;
            }             
           
            system.debug(catagory);
            /**
            * Check if license exists for given account on Adult/ Pediatric, OH/AH content 
            */
            /*if(isLicenceAvailable(catagory,Officehours,ciwo.accountId) == false){
                logCustomerInteraction(ciwo, acct.TriageNow_Mode__c, 'Error');
                returnWrapperObject Wrapobja = new returnWrapperObject();  
                Wrapobja.Error ='This search is currently disabled for your account. Please request TriageNow administrator to enable the search.';
                return Wrapobja.Error;
            }*/
                        
         //to bring all the 
            string APOH = 'Adult and Pediatric / OH';
            string AAH = 'Adult / AH';
            string PAH = 'Pediatric / AH';
            string Triagenowimport = 'Select id from TriageNow_Import_Database__c where';
            
            if(Officehours == true ){
                 Triagenowimport += ' Db_Alias__c = \'' +APOH+ '\'';            
            }else if(Officehours == false && catagory.contains('Pediatric') && catagory.contains('Adult')){
              list<string> ss = new List<string>();
              ss.add(AAH);
              ss.add(PAH);
             Triagenowimport += ' Db_Alias__c IN : ss';   
            }else if(Officehours == false && catagory.contains('Pediatric')){
                 Triagenowimport += ' Db_Alias__c = \'' +PAH + '\'';         
            }else if(Officehours == false && catagory.contains('Adult')) {
                 Triagenowimport += ' Db_Alias__c = \'' +AAH+ '\'';           
            }

            system.debug(Triagenowimport);

            List<TriageNow_Import_Database__c> TriagenowimportIDS  = database.query(Triagenowimport);
            system.debug('TriagenowimportIDS'+TriagenowimportIDS);

            //convert it into string 
            List<string> TNDb = new list<string>();
            for(TriageNow_Import_Database__c tt : TriagenowimportIDS){
                 TNDb.add(string.valueof(tt.get('id'))); 
            }
            

//This section is for NLP Engine.
//This is written in this section : change the wsdl on the client           
        string result;
            
            if(SpecificAlgoID == true){
                String symptoms = Symptom;  
                WrapperForAlgorithCards Wrappp = new WrapperForAlgorithCards();
                List<string> cate = new List<string>(); 
                cate.addAll(catagory);
                Wrappp = Algomap(symptoms,cate,Gender,TNDb,offsetSize,Hospice);
                //Wrappp.Error = 'Success';
                result = JSON.Serialize(Wrappp);
                    
            }
            else{
                returnWrapperObject Wrapobj = new returnWrapperObject();  
                List<string> cate = new List<string>(); 
                cate.addAll(catagory);
                Wrapobj  = AdditionalDetails(Symptom,cate,Gender,TNDb,Hospice);
                Wrapobj.Error = 'Success';
                result = JSON.Serialize(Wrapobj);
            }           
            logCustomerInteraction(ciwo, acct.TriageNow_Mode__c, 'Success');
            return result ;
          
        }else{
              returnWrapperObject Wrapobja = new returnWrapperObject(); 
              logCustomerInteraction(ciwo, acct.TriageNow_Mode__c, 'Error');
              Wrapobja.Error ='Please Type a Search Keyword';
              return Wrapobja.Error;
            }
                
    }
  
        
        //catagory will give me adult/pediatric
        //office hours in offcie or not in offce
        //gender will give you gender

    webService static WrapperForAlgorithCards Algomap(string symptoms,List<String> catagory,string Gender, List<string> TNDb,integer offset,boolean Hospice){
             WrapperForAlgorithCards ConsolidatedObjRetObj = new WrapperForAlgorithCards();
             
    try{     
          ConsolidatedObjRetObj.ALgorithm = new List<AlgoreturnVal>();
          ConsolidatedObjRetObj.Smag = new List<SmagLink>(); 
        

          string IsActive = 'Active'; //check active records only


     List<TriageNow_AlgorithmSearchWord__c> ALgosearchword = [SELECT AD_AlgorithmID__c
                                                              FROM TriageNow_AlgorithmSearchWord__c
                                                               WHERE AD_SearchWord__c =: symptoms
                                                               AND TriageNow_Import_Database__c IN:TNDb];  

      
      System.debug('@@@@@AlgorithmID__cnoYT USED :'+ALgosearchword);

           
           //this is use to ceck for the Acerss IDS                                                  
      List<String> AcessAlgoID = new List<string>();
       for(TriageNow_AlgorithmSearchWord__c AcesAlgo : ALgosearchword){
        AcessAlgoID.add(AcesAlgo.AD_AlgorithmID__c);
        
       }    
        AcessAlgoID.sort();    
         system.debug('All the algorithm ids form ALGO SEARCH TABLE'+AcessAlgoID);
         system.debug('^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^');
     
    //string category = '%'+catagory+'%';   
    String Genderr = '\''+Gender+'\'';
    Set<String> genders = new Set<String>();
    if(Gender != null && Gender != '') {
        genders.add(Gender);
    }
         genders.add('B'); 
    
    System.debug('IsActive '+IsActive);
    //System.debug('category '+category);
    System.debug('TNDb '+TNDb);
    System.debug('Gender '+Gender);

    // 11 is taken tso to check if new record is present or not.
   Integer LimtofSoql = 11;  
string soql ='SELECT AlgorithmID__c,BackgroundXHTML__c,Copyright__c,DefinitionXHTML__c,FirstAidXHTML__c,Id,InitialAssessmentQuestions__c,Title__c,Category__c,Group__c,Type__c,System__c,Anatomy__c,VersionYear__c,Status__c,SnoMedCode__c,ICD9Code__c,Acuity__c,Gender__c,Max_Age_Months__c,Max_Age_Years__c,Min_Age_Months__c,Min_Age_Years__c,Prescription_Option__c FROM TriageNow_Algorithm__c WHERE AlgorithmID__c IN : AcessAlgoID AND Status__c =: IsActive AND category__c IN : catagory AND TriageNow_Import_Database__c IN:TNDb AND Gender__c like : genders Order by Acuity__c ASC Limit: LimtofSoql Offset: offset';

 List<TriageNow_Algorithm__c> ALgorithm1 =  database.query(soql);


    
      system.debug('ALgorith Value form ALGORITHM OBJECT'+ALgorithm1);
      system.debug('***************************************');

      //These IDS would be used for referencing all the Other tables according to the Triage now import database
      List<string> AccessAlgoIds = new List<string>();
        for(TriageNow_Algorithm__c algo : ALgorithm1){
          AccessAlgoIds.add(algo.AlgorithmID__c);
        }    
        AccessAlgoIds.sort();

         List<TriageNow_Question__c> Question =  [SELECT AD_AlgorithmID__c,SMAG_LINK_ID__c
                                                       FROM TriageNow_Question__c
                                                       WHERE AD_AlgorithmID__c IN: AccessAlgoIds
                                                       AND TriageNow_Import_Database__c IN:TNDb
                                                       AND DispositionLevel__r.Hospice__c =: Hospice                   
                                                       Order by AD_AlgorithmID__c ASC];

         system.debug('questions'+Question);
         List<SmagLink> ss =new List<Smaglink>();                                                 
         List<string> smag = new List<string>();
              for(TriageNow_Question__c QUSIDS : Question){
                 if(QUSIDS.SMAG_LINK_ID__c != 0.0 ){
                   SmagLink sstemp =  new SmagLink();
                    sstemp.Algoid = QUSIDS.AD_AlgorithmID__c;                    
                    sstemp.SmagAlgoID = string.valueof(QUSIDS.SMAG_LINK_ID__c);                   
                    smag.add(string.valueof(QUSIDS.SMAG_LINK_ID__c));
                    ss.add(sstemp);
                    //ConsolidatedObjRetObj.Smag.add(sstemp);    
                    system.debug('Added smag link in iteration'+ss);
                  }  
              }  

                //ss.sort();
                smag.sort(); 
                system.debug('Smaglinks'+smag);
     /* Webservice string SmagAlgoID{get;set;}
      Webservice string Algoid{get;set;}
      Webservice string Title{get;set;}
      webService string SFDCAlgoid{get;set;}*/
              List<TriageNow_Algorithm__c> Smaglink = [SELECT AlgorithmID__c,Title__c 
                                                  FROM TriageNow_Algorithm__c 
                                                  WHERE AlgorithmID__c IN : smag
                                                  AND Status__c =: IsActive
                                                  AND category__c IN : catagory
                                                  AND TriageNow_Import_Database__c IN:TNDb
                                                  AND Gender__c like : genders                                                   
                                                  Order by AlgorithmID__c ASC ]; 
           
              for(TriageNow_Algorithm__c Sl : Smaglink){                 
                for(SmagLink ee : ss){
                  SmagLink ssa =  new SmagLink();
                  if(Sl.AlgorithmID__c == ee.SmagAlgoID){
                      ssa.SmagAlgoID = Sl.AlgorithmID__c;
                      ssa.Algoid = ee.Algoid;
                      ssa.Title = Sl.Title__c;                    
                  ConsolidatedObjRetObj.Smag.add(ssa);        
                    }                
                   }
                }
            
            system.debug('Smag Links '+ConsolidatedObjRetObj.Smag);
     

        System.debug('ALL Algo ids in string ALGORITHM IDS  :'+AccessAlgoIds);
        system.debug('^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^');
       
            if(ALgorithm1.size() > 0 && ALgorithm1 != null ){
                                                      
            for(TriageNow_Algorithm__c alg : ALgorithm1)
              
            {
                AlgoreturnVal Algoretval = new AlgoreturnVal();              
                
                Algoretval.DefinitionXHTML = alg.DefinitionXHTML__c;
                Algoretval.ICD9Code = alg.ICD9Code__c == null ? 'NA':alg.ICD9Code__c ;
                Algoretval.Acuity = alg.Acuity__c;
                Algoretval.FirstAidXHTML = alg.FirstAidXHTML__c;
                Algoretval.BackgroundXHTML = alg.BackgroundXHTML__c;
                Algoretval.AlgorithmID = alg.AlgorithmID__c;
                Algoretval.Title = alg.Title__c;
                Algoretval.Copyright = alg.Copyright__c;
                Algoretval.Anatomy = alg.Anatomy__c;                
                Algoretval.System1 = alg.System__c;
                Algoretval.Type = alg.Type__c;
                Algoretval.Gender = alg.Gender__c;    
                Algoretval.Group1 = alg.Group__c;                
                Algoretval.VersionYear = alg.VersionYear__c;
                Algoretval.SnoMedCod = alg.SnoMedCode__c == null ? 'NA':alg.SnoMedCode__c;
                Algoretval.Min_Age_Year = string.valueof(alg.Min_Age_Years__c);
                Algoretval.Max_Age_Year = string.valueof(alg.Max_Age_Years__c);
                Algoretval.Min_Age_Month = string.valueof(alg.Min_Age_Months__c);
                Algoretval.Max_Age_Month = string.valueof(alg.Max_Age_Months__c);
                Algoretval.Prescription = alg.Prescription_Option__c;
            
                Algoretval.InitialAssessmentQuestions = alg.InitialAssessmentQuestions__c;                

                ConsolidatedObjRetObj.ALgorithm.add(Algoretval);
                System.debug('ConsolidatedObjRetObj.ALgorithm*******'+ConsolidatedObjRetObj.ALgorithm);
               // ALgorithm.addAll(AlgoretvalList);
            } 
            //system.debug('ConsolidatedObj.ALgorithm'+ConsolidatedObj.ALgorithm);                                             

              

              //If lookupfails Then populate the table and bring the ids and then hit the table with its ids

            }
        }
       catch(Exception e){
          system.debug('message'+e.getmessage());
          system.debug('message'+e.getLinenumber());
          
       }
        system.debug('ConsolidatedObjRetObj'+ConsolidatedObjRetObj);
       return ConsolidatedObjRetObj;
      
    }




webService static returnWrapperObject AdditionalDetails(string AlgorithmID,List<string> catagory,string Gender,List<string> TNDb,boolean Hospice){
    returnWrapperObject ConsolidatedObj = new returnWrapperObject();
    try{          
         ConsolidatedObj.ALgorithm = new List<AlgoreturnVal>(); 
         ConsolidatedObj.Reference = new  List<AlgoreferencerretVal>();
         ConsolidatedObj.QuestionAdvice  = new List<QuestionAdvice>();
         ConsolidatedObj.Supplement = new List<Supplement>();
         ConsolidatedObj.RelatedACI = new List<RelatedACI>();
         ConsolidatedObj.Question = new List<Question>();
         ConsolidatedObj.Smaglink = new List<Smaglink>();
            
 string IsActive = 'Active'; //check active records only    
    
         //string category = '%'+catagory+'%';   
    String Genderr = '\''+Gender+'\'';
    Set<String> genders = new Set<String>();
    if(Gender != null && Gender != '') {
        genders.add(Gender);
    }
      genders.add('B');
    
    System.debug('IsActive '+IsActive);
    //System.debug('category '+category);
    System.debug('TNDb '+TNDb);
    System.debug('Gender '+Gender);

     List<TriageNow_Algorithm__c> ALgorithm1 = [ SELECT AlgorithmID__c,BackgroundXHTML__c,Copyright__c,DefinitionXHTML__c,FirstAidXHTML__c,Id,
                                                  InitialAssessmentQuestions__c,Title__c,Category__c,Group__c,Type__c,System__c,Anatomy__c,
                                                  VersionYear__c,Status__c,SnoMedCode__c,ICD9Code__c,Acuity__c,Gender__c,Max_Age_Months__c,
                                                  Max_Age_Years__c,Min_Age_Months__c,Min_Age_Years__c,Prescription_Option__c 
                                                  FROM TriageNow_Algorithm__c 
                                                  WHERE AlgorithmID__c = : AlgorithmID
                                                  AND Status__c =: IsActive
                                                  AND category__c IN : catagory
                                                  AND TriageNow_Import_Database__c IN:TNDb
                                                  AND Gender__c like : genders                                                   
                                                  Order by Acuity__c ASC ];

      system.debug('ALgorith Value form ALGORITHM OBJECT'+ALgorithm1);
      system.debug('***************************************');

      //These IDS would be used for referencing all the Other tables according to the Triage now import database
      List<string> AccessAlgoIds = new List<string>();
        for(TriageNow_Algorithm__c algo : ALgorithm1){
          AccessAlgoIds.add(algo.AlgorithmID__c);
        }    
        AccessAlgoIds.sort();

        System.debug('ALL Algo ids in string ALGORITHM IDS  :'+AccessAlgoIds);
        system.debug('^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^');
       
            if(ALgorithm1.size() > 0 && ALgorithm1 != null ){
                                                      
            for(TriageNow_Algorithm__c alg : ALgorithm1)
              
            {
                AlgoreturnVal Algoretval = new AlgoreturnVal();
                
                Algoretval.DefinitionXHTML = alg.DefinitionXHTML__c;
                Algoretval.ICD9Code = alg.ICD9Code__c == null ? 'NA':alg.ICD9Code__c ;
                Algoretval.Acuity = alg.Acuity__c;
                Algoretval.FirstAidXHTML = alg.FirstAidXHTML__c;
                Algoretval.BackgroundXHTML = alg.BackgroundXHTML__c;
                Algoretval.AlgorithmID = alg.AlgorithmID__c;
                Algoretval.Title = alg.Title__c;
                Algoretval.Copyright = alg.Copyright__c;
                Algoretval.Anatomy = alg.Anatomy__c;                
                Algoretval.System1 = alg.System__c;
                Algoretval.Type = alg.Type__c;
                Algoretval.Gender = alg.Gender__c;    
                Algoretval.Group1 = alg.Group__c;                
                Algoretval.VersionYear = alg.VersionYear__c;
                Algoretval.SnoMedCod = alg.SnoMedCode__c == null ? 'NA':alg.SnoMedCode__c;
                Algoretval.Min_Age_Year = string.valueof(alg.Min_Age_Years__c);
                Algoretval.Max_Age_Year = string.valueof(alg.Max_Age_Years__c);
                Algoretval.Min_Age_Month = string.valueof(alg.Min_Age_Months__c);
                Algoretval.Max_Age_Month = string.valueof(alg.Max_Age_Months__c);
                Algoretval.Prescription = alg.Prescription_Option__c;
            
                Algoretval.InitialAssessmentQuestions = alg.InitialAssessmentQuestions__c;                

                ConsolidatedObj.ALgorithm.add(Algoretval);

                 
               // ALgorithm.addAll(AlgoretvalList);
            } 
            system.debug('ConsolidatedObj.ALgorithm'+ConsolidatedObj.ALgorithm);                                             

              

              //If lookupfails Then populate the table and bring the ids and then hit the table with its ids

                
            
    
              List<TriageNow_AlgorithmReference__c> Algoreference  =  [SELECT AlgorithmID__c,AD_AlgorithmID__c,ReferenceID__r.PubMedURL__c,ReferenceID__r.ReferenceAuthor__c
                                                                      ,ReferenceID__r.ReferenceSource__c,ReferenceID__r.ReferenceTitle__c 
                                                                      FROM TriageNow_AlgorithmReference__c 
                                                                      WHERE AD_AlgorithmID__c = : AlgorithmID
                                                                      AND TriageNow_Import_Database__c IN:TNDb];     

              System.debug('REferences from ALGORITHM REFERENCE : '+Algoreference);
              system.debug('***************************************');                             

              for(TriageNow_AlgorithmReference__c ref : Algoreference){
                  AlgoreferencerretVal RefValList = new  AlgoreferencerretVal();

                    
                    
                    RefValList.PubMedURL =  ref.ReferenceID__r.PubMedURL__c;
                    RefValList.ReferenceAuthor = ref.ReferenceID__r.ReferenceAuthor__c;
                    RefValList.ReferenceSource = ref.ReferenceID__r.ReferenceSource__c;
                    RefValList.ReferenceTitle = ref.ReferenceID__r.ReferenceTitle__c;    
                    RefValList.RefALgoID = ref.AD_AlgorithmID__c;        

                   ConsolidatedObj.Reference.add(RefValList);
              }

             //system.debug('ConsolidatedObj.Reference'+ConsolidatedObj.Reference);

             
               
              
               List<TriageNow_Question__c> Question =  [SELECT AD_AlgorithmID__c,AD_DispositionLevel__c,DispositionLevel__r.Hospice__c ,DispositionLevel__r.levelid__c,AlgorithmID__c,CMS__c,DispositionLevel__r.DispositionHeading__c,
                                                       Id,Information__c,Name,QuestionID__c,QuestionOrder__c,Question__c,
                                                       SMAG_LINK_ID__c,TriageNow_Import_Database__c
                                                       FROM TriageNow_Question__c
                                                       WHERE AD_AlgorithmID__c =: AlgorithmID
                                                       AND TriageNow_Import_Database__c IN:TNDb
                                                       AND DispositionLevel__r.Hospice__c =: Hospice
                                                       Order by DispositionLevel__r.levelid__c DESC , SMAG_LINK_ID__c ASC];
             

             

              

              system.debug('All the question form TRIAGE QUESTION'+Question);
              system.debug('***************************************');                                          

              for(TriageNow_Question__c qus : Question){
                 Question Quse  = new Question();                
                Quse.Question = qus.Question__c;
                Quse.QuestionAdviceOrder = qus.QuestionOrder__c;
                Quse.QusAlgoID = qus.AD_AlgorithmID__c;
                Quse.QusIDtomap = qus.QuestionID__c;
                Quse.Information = qus.Information__c;
                Quse.Smaglink = qus.SMAG_LINK_ID__c;
                Quse.DispositionHeading = qus.DispositionLevel__r.DispositionHeading__c;
                Quse.DispositionID = string.valueof(qus.DispositionLevel__r.levelid__c);               
                ConsolidatedObj.Question.add(Quse);
              }                          

              //System.debug('ConsolidatedObj.Question: '+ConsolidatedObj.Question);
              //for getting tye string IDS 
              List<string> Qusid = new List<String>();
              for(TriageNow_Question__c QUSIDS : Question){
                  Qusid.add(QUSIDS.QuestionID__c);
              }  
//--------
            //Bring the title from smag link             

          List<SmagLink> ss =new List<Smaglink>();                                                 
          List<string> smag = new List<string>();
              for(TriageNow_Question__c QUSIDS : Question){
                if(QUSIDS.SMAG_LINK_ID__c != 0.0){
                   SmagLink sstemp =  new SmagLink();
                    sstemp.Algoid = QUSIDS.AD_AlgorithmID__c;                    
                    sstemp.SmagAlgoID = string.valueof(QUSIDS.SMAG_LINK_ID__c);                   
                    smag.add(string.valueof(QUSIDS.SMAG_LINK_ID__c));
                    ss.add(sstemp);
                    //ConsolidatedObjRetObj.Smag.add(sstemp);    
                    system.debug('Added smag link in iteration'+ss);
                   } 
              }  

            
              smag.sort(); 
                  system.debug('Smag'+smag);
 
               List<TriageNow_Algorithm__c> Smaglink = [SELECT AlgorithmID__c,Title__c 
                                                  FROM TriageNow_Algorithm__c 
                                                  WHERE AlgorithmID__c IN : smag
                                                  AND Status__c =: IsActive
                                                  AND category__c IN : catagory
                                                  AND TriageNow_Import_Database__c IN:TNDb
                                                  AND Gender__c like : genders                                                   
                                                  Order by AlgorithmID__c ASC ];

                                    

              for(TriageNow_Algorithm__c Sl : Smaglink){                 
                for(SmagLink ee : ss){
                  SmagLink ssa =  new SmagLink();
                  if(Sl.AlgorithmID__c == ee.SmagAlgoID){
                      ssa.SmagAlgoID = Sl.AlgorithmID__c;
                      ssa.Algoid = ee.Algoid;
                      ssa.Title = Sl.Title__c;                    
                      ConsolidatedObj.Smaglink.add(ssa);        
                    }                
                   }
                }  
//------------
                system.debug('Smag link'+ConsolidatedObj.Smaglink);

              System.debug('ONLY QUESTION IDS : '+Qusid);
              system.debug('^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^');

             List<TriageNow_QuestionAdvice__c> QuestionAndAdvice = [SELECT AdviceID__r.Advice__c,AdviceID__r.Advice_XHTML__c,AD_AdviceID__c,AD_QuestionID__c,QuestionAdviceOrder__c
                                                                    ,QuestionID__c,TriageNow_Import_Database__c
                                                                    FROM TriageNow_QuestionAdvice__c
                                                                    WHERE AD_QuestionID__c IN : Qusid
                                                                     AND TriageNow_Import_Database__c IN:TNDb];

             system.debug('GET ADvices fron QUEStion IDS object TRIAGE QUSTION ADVICE'+QuestionAndAdvice);
             system.debug('***************************************');                                                          

             for(TriageNow_QuestionAdvice__c qusad : QuestionAndAdvice){             
                QuestionAdvice Qusadv  = new QuestionAdvice();
                Qusadv.QusID = qusad.AD_QuestionID__c;
                Qusadv.Advice = qusad.AdviceID__r.Advice_XHTML__c;   
             /*   if(Qusadv.Advice != null || Qusadv.Advice.length() < 1){
                      Qusadv.IsAdvicePresent = false;
                }else{
                      Qusadv.IsAdvicePresent = true;
                } */
                ConsolidatedObj.QuestionAdvice.add(Qusadv);
            }

                 // system.debug('ConsolidatedObj.QuestionAdvice'+ConsolidatedObj.QuestionAdvice);             

              
              List<TriageNow_AlgorithmSupplemental__c> Supplement1 = [SELECT AD_AlgorithmID__c,AD_SupplementalID__c,AlgorithmID__c,SupplementalID__r.Category__c
                                                                      ,SupplementalID__c,SupplementalID__r.Title__c,SupplementalID__r.Content_XHTML__c,TriageNow_Import_Database__c
                                                                      FROM TriageNow_AlgorithmSupplemental__c where AD_AlgorithmID__c =: AlgorithmID
                                                                       AND TriageNow_Import_Database__c IN:TNDb ];


              system.debug('get all teh subliment OBJECT SUPPLEMENT'+Supplement1);                                                        
              system.debug('***************************************');
              for(TriageNow_AlgorithmSupplemental__c supp : Supplement1 ){
                  Supplement supple = new Supplement();

                  supple.SupplementAlgoID  = supp.AD_AlgorithmID__c;
                  supple.Content = supp.SupplementalID__r.Content_XHTML__c ;   
                  supple.Title = supp.SupplementalID__r.Title__c;   
                  supple.Category = supp.SupplementalID__r.Category__c;                        

                  ConsolidatedObj.Supplement.add(supple);
              }  


              system.debug('ConsolidatedObj.Supplement'+ConsolidatedObj.Supplement);


              //only we have to hit the after care instruction  database logic for that is below 

            string TriagenowimportforACI = 'Select id from TriageNow_Import_Database__c where';

            Set<string> ssd = new Set<string>();
            ssd.addAll(Catagory);
            string pACI = 'Pediatric / ACI';
            string aACI = 'Adult / ACI';
            
            if(ssd.contains('Pediatric')){  TriagenowimportforACI += ' Db_Alias__c = \'' +pACI+ '\'';   
              }else if(ssd.contains('Adult')){
                TriagenowimportforACI += ' Db_Alias__c = \'' +aACI+ '\'';   
              }else if((ssd.contains('Adult')) && (ssd.contains('Pediatric'))){
                List<string> sss = new List<string>();
                sss.add(pACI);
                sss.add(aACI);
                TriagenowimportforACI += ' Db_Alias__c IN : sss'; 
              }
            
            system.debug('TriagenowimportforACI'+TriagenowimportforACI);            

            List<TriageNow_Import_Database__c> TNDbACI = database.query(TriagenowimportforACI);

            //system.debug('TNDbACI'+TNDbACI);
            List<string> Tnndb = new List<string>();
            for(TriageNow_Import_Database__c tt : TNDbACI){
                  Tnndb.add(string.valueof(tt.get('Id'))); 
            }
             

          

              

///this is for Related ACi
              List<TriageNow_RelatedACI__c> RelatedACI = [SELECT AD_AlgorithmID__c,AlgorithmID__c,HealthInfoTopicID__c,Name
                                                          ,Temp__c,TriageNow_Import_Database__c
                                                          FROM TriageNow_RelatedACI__c
                                                          WHERE AD_AlgorithmID__c = : AlgorithmID 
                                                          AND TriageNow_Import_Database__c  IN: TNDb ]; 

              system.debug('Get related Aci object RELATED ACI '+RelatedACI);
              system.debug('^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^');
              
              if(RelatedACI != null && RelatedACI.size()>0){
             // map<string ,List<WrapHelthInfoTopic>> HITopic  = new map<string ,List<WrapHelthInfoTopic>>(); 
              list<string> reAci = new list<string>(); //convert decimal to string for comparision.                                              
              for(TriageNow_RelatedACI__c ACi : RelatedACI ){                
                  string ddd = string.valueOf(ACi.HealthInfoTopicID__c);                  
                  reAci.add(ddd);                 
              }                                           

              System.debug('Related ACI LIST:'+reAci);
              system.debug('^^^^^^^^^^^^^^^^^^^^^^^^^^^^^');
                                  
              List<TriageNow_Advice__c> TriagenowadviceACI = [SELECT AdviceOrder__c,Advice_Txt__c,Advice__c,AlgorithmID__c,Id,Name
                                                              ,HealthInfoTopicID__c,HealthInfoTopicID__r.Title__c,HealthInfoTopicID__r.Definition__c
                                                              ,HealthInfoTopicID__r.HI_All__c,HealthInfoTopicID__r.HealthInfoTopicID__c,HealthInfoTopicID__r.CallBack__c,Temp__c,TriageNow_Import_Database__c 
                                                              FROM TriageNow_Advice__c 
                                                              WHERE  AD_HealthInfoTopicId__c IN : reAci
                                                              AND TriageNow_Import_Database__c  IN: Tnndb];                          

              system.debug('get the ACI Advice Object TRIAGE ADVICE ACI'+TriagenowadviceACI);
              system.debug('***************************************');


             for(TriageNow_Advice__c TriageACI : TriagenowadviceACI){

                 RelatedACI rAci = new RelatedACI();

                 rAci.Title = TriageACI.HealthInfoTopicID__r.Title__c;
                 rAci.Definition  = TriageACI.HealthInfoTopicID__r.Definition__c;
                 rAci.Advice = TriageACI.Advice__c;
                 rAci.Hiall = TriageACI.HealthInfoTopicID__r.HI_All__c;
                 rAci.CallBack = TriageACI.HealthInfoTopicID__r.CallBack__c;             

                 ConsolidatedObj.RelatedACI.add(rAci);
                 //system.debug('ConsolidatedObj.RelatedACIConsolidatedObj.RelatedACI'+ConsolidatedObj.RelatedACI);
             }

             system.debug('ConsolidatedObj.RelatedACI'+ConsolidatedObj.RelatedACI);


            }///this is for Related ACi            
                                                        
            }
         return ConsolidatedObj;   
       
       }
       catch(Exception e){
          system.debug('message'+e.getmessage());
          system.debug('message'+e.getLinenumber());
          
       }
       return ConsolidatedObj;
    }

     //Not Used. 
     public class WrapHelthInfoTopic{
      public string HealthInfoTopicID{get;set;}
      public string AlgoID{get;set;}

     }  

     
    global class WrapperForAlgorithCards{
        webService List<AlgoreturnVal> ALgorithm{get;set;}
        webservice List<SmagLink> Smag{get;set;}
        webservice List<ConceptID> Concept{get;set;}
    }
    
    global class CustomerInetractionWrapperObject{       
        webService String accountId{get;set;}       
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
     global class returnWrapperObject{
       
        webService String Error{get;set;}       
        webService List<AlgoreturnVal> ALgorithm{get;set;}       
        webService List<AlgoreferencerretVal> Reference{get;set;} 
        webService List<QuestionAdvice> QuestionAdvice{get;set;} 
        webService List<Question> Question{get;set;} 
        webService List<Supplement> Supplement{get;set;}
        webService List<RelatedACI> RelatedACI{get;set;}
        webservice List<SmagLink> Smaglink{get;set;}

     }

    global  class AlgoreturnVal{
        
          webService string DefinitionXHTML{get;set;} 
          webService string ICD9Code{get;set;}
          webService decimal Acuity{get;set;}
          webService string FirstAidXHTML{get;set;}
          webService string BackgroundXHTML{get;set;}       
          webService string AlgorithmID{get;set;}
          webService string Title{get;set;}
          webService string Copyright{get;set;}
          webService string InitialAssessmentQuestions{get;set;}
          webservice string Anatomy{set;get;}          
          webservice string System1{get;set;}
          webservice string Type{get;set;}
          webservice string Gender{get;set;}
          webservice string Group1{get;set;}          
          webservice string VersionYear{get;set;}
          webservice string SnoMedCod{get;set;}
          webservice string Min_Age_Year{get;set;}
          webservice string Max_Age_Year{get;set;}
          webservice string Min_Age_Month{get;set;}
          webservice string Max_Age_Month{get;set;}
          webservice boolean Prescription{get;set;}     


    }

    global class AlgoreferencerretVal{

        webService string RefALgoID{get;set;} 
         webService string PubMedURL{get;set;} 
         webService string ReferenceAuthor{get;set;} 
         webService string ReferenceSource{get;set;} 
         webService string ReferenceTitle{get;set;} 

    } 

    global class SmagLink{
      Webservice string SmagAlgoID{get;set;}
      Webservice string Algoid{get;set;}
      Webservice string Title{get;set;}
      webService string SFDCAlgoid{get;set;}
    }


    global class Question{
           webService string QusAlgoID{get;set;}
           webService string DispositionID{get;set;}
           webService string QusIDtomap{get;set;}            
           webService string Question{get;set;} 
           webService string Information{get;set;} 
           webService decimal Smaglink{get;set;} 
           webService decimal QuestionAdviceOrder{get;set;}            
           webservice string DispositionHeading{get;set;}
    } 


    global class QuestionAdvice{
           webService string QusID{get;set;} 
           webService string Advice{get;set;} 
           webService boolean IsAdvicePresent{get;set;}
    } 

    global class Supplement{
        webservice string SupplementAlgoID{get;set;}
        webservice string Content{get;set;} 
        webservice string Title{get;set;} 
        webservice string Category{get;set;} 
    }


global class ConceptID{
  webservice string ConceptID{get;set;}
  webservice string AlgorithmID{get;set;}
}

    global class RelatedACI{
        webservice string RelatedAciAlgoID{get;set;}
        webservice string Title{get;set;}
        webservice string Definition{get;set;} 
        webservice string Advice{get;set;}
        webservice string Hiall{get;set;}
        webservice string CallBack{get;set;}
    }
   

// This is for NLP Engine implementation=-----------------------------------------------------------------------------------------------------------    
     webService static string GetNLPData(List<string> Symptom,string catagoryref,Boolean Officehours,string Gender,String input,boolean hospice ,Integer Offsetsize){
        CustomerInetractionWrapperObject ciwo = (CustomerInetractionWrapperObject)JSON.deserialize(input,CustomerInetractionWrapperObject.class);
        string result;
        Account acct = [Select Id, TriageNow_Mode__c from Account where Id = :ciwo.accountId and IsDeleted = false LIMIT 1];
        
        
        try{
            
           set<string> catagory = new set<string>();

          boolean IsAdult =  isLicenceAvailable('Adult',Officehours,ciwo.accountId);          
          boolean IsPediatric =  isLicenceAvailable('Pediatric',Officehours,ciwo.accountId);

            if(catagoryref.contains('Both')){
                     if(IsPediatric){
                        catagory.add('Pediatric');  
                    }

                    if(IsAdult){
                         catagory.add('Adult');   
                    }          
            }else if(catagoryref.contains('Adult') && IsAdult){
                    catagory.add('Adult');
            }else if(catagoryref.contains('Pediatric') && IsPediatric){
                    catagory.add('Pediatric');
            }else{
                logCustomerInteraction(ciwo, acct.TriageNow_Mode__c, 'Error');
                returnWrapperObject Wrapobja = new returnWrapperObject();  
                Wrapobja.Error ='This search is currently disabled for your account. Please request TriageNow administrator to enable the search.';
                return Wrapobja.Error;
            }             
           
            system.debug(catagory);
            /**
            * Check if license exists for given account on Adult/ Pediatric, OH/AH content 
            */
           /* if(isLicenceAvailable(catagory,Officehours,ciwo.accountId) == false){
                logCustomerInteraction(ciwo, acct.TriageNow_Mode__c, 'Error');
                returnWrapperObject Wrapobja = new returnWrapperObject();  
                Wrapobja.Error ='This search is currently disabled for your account. Please request TriageNow administrator to enable the search.';
                return Wrapobja.Error;
            }*/
            
         //to bring all the 
            string APOH = 'Adult and Pediatric / OH';
            string AAH = 'Adult / AH';
            string PAH = 'Pediatric / AH';
            string Triagenowimport = 'Select id from TriageNow_Import_Database__c where';
            
             if(Officehours == true ){
                 Triagenowimport += ' Db_Alias__c = \'' +APOH+ '\'';            
            }else if(Officehours == false && catagory.contains('Pediatric') && catagory.contains('Adult')){
              list<string> ss = new List<string>();
              ss.add(AAH);
              ss.add(PAH);
             Triagenowimport += ' Db_Alias__c IN : ss';   
            }else if(Officehours == false && catagory.contains('Pediatric')){
                 Triagenowimport += ' Db_Alias__c = \'' +PAH + '\'';         
            }else if(Officehours == false && catagory.contains('Adult')) {
                 Triagenowimport += ' Db_Alias__c = \'' +AAH+ '\'';           
            }

            system.debug(Triagenowimport);

            List<TriageNow_Import_Database__c> TriagenowimportIDS  = database.query(Triagenowimport);
            system.debug('TriagenowimportIDS'+TriagenowimportIDS);

            //convert it into string 
            List<string> TNDb = new list<string>();
            for(TriageNow_Import_Database__c tt : TriagenowimportIDS){
                 TNDb.add(string.valueof(tt.get('id'))); 
            }
            
            
            
            
            if(Officehours){

                 List<TriageNow_Concept__c> ConceptWord = [SELECT Title__c
                                                           FROM TriageNow_Concept__c 
                                                           WHERE  ConceptID__c IN: Symptom
                                                           AND TriageNow_Import_Database__c IN: TNDb];

                 List<string> conceptid = new List<string>(); 
                 for(TriageNow_Concept__c tc : ConceptWord){
                      conceptid.add(tc.Title__c);
                 }                                         

                 List<TriageNow_AlgorithmSearchWord__c> ALgosearchword = [SELECT AD_AlgorithmID__c
                                                                          FROM TriageNow_AlgorithmSearchWord__c
                                                                           WHERE AD_SearchWord__c IN :conceptid
                                                                           AND TriageNow_Import_Database__c IN:TNDb];  

      
                   System.debug('@@@@@AlgorithmID__cnoYT NLP NLP NLP :'+ALgosearchword);

           
           //this is use to ceck for the Acerss IDS                                                  
            List<String> AcessAlgoID = new List<string>();
                  for(TriageNow_AlgorithmSearchWord__c AcesAlgo : ALgosearchword){
                              AcessAlgoID.add(AcesAlgo.AD_AlgorithmID__c);
                              
                  }
                  AcessAlgoID.sort();
                system.debug('All the algorithm ids form ALGO SEARCH TABLE'+AcessAlgoID);                                          
             List<string> temp = new List<string>();
             temp.addAll(catagory);
             result = AlgomapforNLP(AcessAlgoID,temp,gender,TNDb,Offsetsize,hospice);              
            }
            else{

                    List<TriageNow_AlgorithmCCC__c> AlgoCCC = [SELECT AD_AlgorithmID__c
                                                               FROM TriageNow_AlgorithmCCC__c 
                                                               where AD_ConceptID__c IN: Symptom
                                                               AND TriageNow_Import_Database__c IN:TNDb];

              List<String> AcessAlgoIDssss = new List<string>();
                  for(TriageNow_AlgorithmCCC__c AcesAlgo : AlgoCCC){
                              AcessAlgoIDssss.add(AcesAlgo.AD_AlgorithmID__c);
                  }      
                         AcessAlgoIDssss.sort();                                          
                    system.debug('All the algorithm ids form ALGO SEARCH TABLE'+AcessAlgoIDssss);                                          
                  List<string> temp = new List<string>();
                   temp.addAll(catagory);
                 result = AlgomapforNLP(AcessAlgoIDssss,temp,gender,TNDb,Offsetsize,hospice);                                                          

             } 
        } catch (Exception e) {
                system.debug('e.getCause();'+e.getCause());
                system.debug('e.getMessage()'+e.getMessage());   
                logCustomerInteraction(ciwo, acct.TriageNow_Mode__c, 'Error');
        }
        logCustomerInteraction(ciwo, acct.TriageNow_Mode__c, 'Success');
        return result;   
     }

  webService static string AlgomapforNLP(List<string> AlgoID,list<string> catagory,string Gender, List<string> TNDb,integer offset,boolean hospice){
             WrapperForAlgorithCards ConsolidatedObjRetObj = new WrapperForAlgorithCards();
      string returnresult ;     
    try{     
          ConsolidatedObjRetObj.ALgorithm = new List<AlgoreturnVal>();
         ConsolidatedObjRetObj.Smag = new List<SmagLink>(); 
         ConsolidatedObjRetObj.Concept =  new List<ConceptID>();
        

          string IsActive = 'Active'; //check active records only

    
         system.debug('^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^');
     
    //string category = '%'+catagory+'%';   
    String Genderr = '\''+Gender+'\'';
    Set<String> genders = new Set<String>();
    if(Gender != null && Gender != '') {
        genders.add(Gender);
    }
     genders.add('B');
   
    System.debug('IsActive '+IsActive);
    //System.debug('category '+category);
    System.debug('TNDb '+TNDb);
    System.debug('Gender '+Gender);

      // 11 is taken tso to check if new record is present or not.
   Integer LimtofSoql = 11;  
   string soql ='SELECT AlgorithmID__c,BackgroundXHTML__c,Copyright__c,DefinitionXHTML__c,FirstAidXHTML__c,Id,InitialAssessmentQuestions__c,Title__c,Category__c,Group__c,Type__c,System__c,Anatomy__c,VersionYear__c,Status__c,SnoMedCode__c,ICD9Code__c,Acuity__c,Gender__c,Max_Age_Months__c,Max_Age_Years__c,Min_Age_Months__c,Min_Age_Years__c,Prescription_Option__c FROM TriageNow_Algorithm__c WHERE AlgorithmID__c IN : AlgoID AND Status__c =: IsActive AND category__c IN : catagory AND TriageNow_Import_Database__c IN:TNDb AND Gender__c like : genders Order by Acuity__c ASC Limit: LimtofSoql Offset: offset';


 List<TriageNow_Algorithm__c> ALgorithm1 =  database.query(soql);


      system.debug('ALgorith Value form ALGORITHM OBJECT'+ALgorithm1);
      system.debug('***************************************');


      //this is written to bring the ICD10 information
       List<TriageNow_AlgorithmCCC__c> AlgoCCC = [SELECT AD_AlgorithmID__c,AD_ConceptID__c
                                                               FROM TriageNow_AlgorithmCCC__c 
                                                               where AD_AlgorithmID__c IN: AlgoID
                                                               AND TriageNow_Import_Database__c IN:TNDb];


        for(TriageNow_AlgorithmCCC__c TA :AlgoCCC)
        { 
           ConceptID cid = new ConceptID();
           cid.ConceptID = TA.AD_ConceptID__c;
           cid.AlgorithmID = TA.AD_AlgorithmID__c;
           ConsolidatedObjRetObj.Concept.add(cid);
        }


      //These IDS would be used for referencing all the Other tables according to the Triage now import database
      List<string> AccessAlgoIds = new List<string>();
        for(TriageNow_Algorithm__c algo : ALgorithm1){
          AccessAlgoIds.add(algo.AlgorithmID__c);
        }   
        AccessAlgoIds.sort();
  List<TriageNow_Question__c> Question =  [SELECT AD_AlgorithmID__c,SMAG_LINK_ID__c
                                                       FROM TriageNow_Question__c
                                                       WHERE AD_AlgorithmID__c IN: AccessAlgoIds
                                                       AND TriageNow_Import_Database__c IN:TNDb
                                                       AND DispositionLevel__r.Hospice__c =: hospice
                                                        Order by AD_AlgorithmID__c ASC];

         system.debug('questions'+Question);
         List<SmagLink> ss =new List<Smaglink>();                                                 
         List<string> smag = new List<string>();
              for(TriageNow_Question__c QUSIDS : Question){
                if(QUSIDS.SMAG_LINK_ID__c != 0.0){
                   SmagLink sstemp =  new SmagLink();
                    sstemp.Algoid = QUSIDS.AD_AlgorithmID__c;                    
                    sstemp.SmagAlgoID = string.valueof(QUSIDS.SMAG_LINK_ID__c);                   
                    smag.add(string.valueof(QUSIDS.SMAG_LINK_ID__c));
                    ss.add(sstemp);
                    //ConsolidatedObjRetObj.Smag.add(sstemp);    
                    system.debug('Added smag link in iteration'+ss);
                  }
              }  

                smag.sort(); 
     /* Webservice string SmagAlgoID{get;set;}
      Webservice string Algoid{get;set;}
      Webservice string Title{get;set;}
      webService string SFDCAlgoid{get;set;}*/
              List<TriageNow_Algorithm__c> Smaglink = [SELECT AlgorithmID__c,Title__c 
                                                  FROM TriageNow_Algorithm__c 
                                                  WHERE AlgorithmID__c IN : smag
                                                  AND Status__c =: IsActive
                                                  AND category__c IN : catagory
                                                  AND TriageNow_Import_Database__c IN:TNDb
                                                  AND Gender__c like : genders                                                   
                                                  Order by AlgorithmID__c ASC ]; 
           
              for(TriageNow_Algorithm__c Sl : Smaglink){
                 SmagLink ssa =  new SmagLink();
                for(SmagLink ee : ss){
                  if(Sl.AlgorithmID__c == ee.SmagAlgoID){
                      ssa.SmagAlgoID = Sl.AlgorithmID__c;
                      ssa.Algoid = ee.Algoid;
                      ssa.Title = Sl.Title__c;                    
                  ConsolidatedObjRetObj.Smag.add(ssa);        
                    }                
                   }
                }
            
            system.debug('Smag Links '+ConsolidatedObjRetObj.Smag);


        System.debug('ALL Algo ids in string ALGORITHM IDS  :'+AccessAlgoIds);
        system.debug('^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^');
       
            if(ALgorithm1.size() > 0 && ALgorithm1 != null ){
                                                      
            for(TriageNow_Algorithm__c alg : ALgorithm1)              
            {
                AlgoreturnVal Algoretval = new AlgoreturnVal();
                
                Algoretval.DefinitionXHTML = alg.DefinitionXHTML__c;
                Algoretval.ICD9Code = alg.ICD9Code__c == null ? 'NA':alg.ICD9Code__c ;
                Algoretval.Acuity = alg.Acuity__c;
                Algoretval.FirstAidXHTML = alg.FirstAidXHTML__c;
                Algoretval.BackgroundXHTML = alg.BackgroundXHTML__c;
                Algoretval.AlgorithmID = alg.AlgorithmID__c;
                Algoretval.Title = alg.Title__c;
                Algoretval.Copyright = alg.Copyright__c;
                Algoretval.Anatomy = alg.Anatomy__c;                
                Algoretval.System1 = alg.System__c;
                Algoretval.Type = alg.Type__c;
                Algoretval.Gender = alg.Gender__c;    
                Algoretval.Group1 = alg.Group__c;                
                Algoretval.VersionYear = alg.VersionYear__c;
                Algoretval.SnoMedCod = alg.SnoMedCode__c == null ? 'NA':alg.SnoMedCode__c;
                Algoretval.Min_Age_Year = string.valueof(alg.Min_Age_Years__c);
                Algoretval.Max_Age_Year = string.valueof(alg.Max_Age_Years__c);
                Algoretval.Min_Age_Month = string.valueof(alg.Min_Age_Months__c);
                Algoretval.Max_Age_Month = string.valueof(alg.Max_Age_Months__c);
                Algoretval.Prescription = alg.Prescription_Option__c;
            
                Algoretval.InitialAssessmentQuestions = alg.InitialAssessmentQuestions__c;                

                ConsolidatedObjRetObj.ALgorithm.add(Algoretval);
                System.debug('ConsolidatedObjRetObj.ALgorithm*******'+ConsolidatedObjRetObj.ALgorithm);
               // ALgorithm.addAll(AlgoretvalList);
            } 
            //system.debug('ConsolidatedObj.ALgorithm'+ConsolidatedObj.ALgorithm);                                             

              

              //If lookupfails Then populate the table and bring the ids and then hit the table with its ids

            }
        }
       catch(Exception e){
          system.debug('message'+e.getmessage());
          system.debug('message'+e.getLinenumber());
          
       }
        returnresult = JSON.Serialize(ConsolidatedObjRetObj);
        system.debug('returnresult++++++++++++++++++++++++++++++'+returnresult);
        return returnresult;
       
    }    

}