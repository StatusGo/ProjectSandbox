global class SearchWebServiceForTriage
{
    public static Map<String,AlgoDetails> MapAlgoChiefdataSort = new Map<String,AlgoDetails>();
    public static Map<String,AlgoDetails> MapAlgoKeyworddataSort = new Map<String,AlgoDetails>();
    public static Map<String,AlgoDetails> MapAlgoTitleddataSort = new Map<String,AlgoDetails>();
    
    webService static string keywordOrtitle(string alphabet,string DefaultVersionYear ,string catagoryref,Boolean Officehours,string Gender,boolean istitle,string input,Integer Age){
        CustomerInetractionWrapperObject ciwo = (CustomerInetractionWrapperObject)JSON.deserialize(input,CustomerInetractionWrapperObject.class);
        List<AlgoDetails> lstAlgos = new List<AlgoDetails>();
        AlgoDetails  Consolidated;
        
        string alphabet1; 
        if(alphabet ==  null || alphabet == ''){ alphabet1 = 'A%';
        }else {
            alphabet1 = alphabet+'%';  
        }
        List<String> lstGender = new List<String>();
        if(Gender != null && Gender != '' && Gender !='B'){
            lstGender.add(Gender);
        }
        lstGender.add('B');
            
        system.debug('Officehours'+Officehours);
        system.debug('Gender'+Gender);
        system.debug('Age'+Age);
        
        //check if algoid is send appropriately.
        set<string> catagory = new set<string>();

        boolean IsAdult =  isLicenceAvailable('Adult',Officehours,ciwo.accountId);          
        boolean IsPediatric =  isLicenceAvailable('Pediatric',Officehours,ciwo.accountId);
        system.debug(IsAdult);
        system.debug(IsPediatric);

        if(catagoryref.contains('Both')) {
                if(IsPediatric){
                    catagory.add('Pediatric');  
                }
                if(IsAdult){
                     catagory.add('Adult');   
                }                   
                system.debug(catagory);
        }else if(catagoryref.contains('Adult') && IsAdult){
                catagory.add('Adult');
                system.debug(catagory);
        }else if(catagoryref.contains('Pediatric') && IsPediatric){
                catagory.add('Pediatric');
                system.debug(catagory);
        }else{
            Consolidated = new AlgoDetails();  
            Consolidated.Response_Status ='Error';
            Consolidated.Response_Message ='This search is currently disabled for your account. Please request TriageNow administrator to enable the search.';
            system.debug(Consolidated);
            return JSON.Serialize(Consolidated);
        }             
           
        system.debug(catagory);
        String versionyear = DefaultVersionYear; 
        System.debug('DefaultVersionYear'+DefaultVersionYear);
        List<string> TNDb = getTNDb(catagory, DefaultVersionYear, Officehours);         
        String Result ;
        if(!istitle){ 
            List<TriageNow_AlgorithmSearchWord__c> ALgosearchword = [SELECT AD_AlgorithmID__c,AD_SearchWord__c
                                                                     FROM TriageNow_AlgorithmSearchWord__c
                                                                     WHERE AD_SearchWord__c like: alphabet1
                                                                     AND TriageNow_Import_Database__c IN:TNDb
                                                                     order by AD_SearchWord__c ASC];   

            for(TriageNow_AlgorithmSearchWord__c tt : ALgosearchword){
                Consolidated = new AlgoDetails();           
                Consolidated.AlgorithmID = tt.AD_AlgorithmID__c;
                Consolidated.Title = tt.AD_SearchWord__c;
                lstAlgos.add(Consolidated);
            }    
            system.debug('lstAlgos: '+lstAlgos);
            Result = JSON.Serialize(lstAlgos);  
        } else{
            List<TriageNow_Algorithm__c> ALgorithm1 = [ SELECT AlgorithmID__c,Title__c
                                                  FROM TriageNow_Algorithm__c 
                                                  WHERE Title__c like: alphabet1
                                                  AND Status__c =: 'Active'
                                                  AND category__c IN : catagory
                                                  AND TriageNow_Import_Database__c IN:TNDb
                                                  AND Gender__c IN :lstGender                                                   
                                                  Order by Title__c Asc];

            for(TriageNow_Algorithm__c tt : ALgorithm1){
                Consolidated = new AlgoDetails();
                Consolidated.AlgorithmID = tt.AlgorithmID__c;
                Consolidated.Title = tt.Title__c;
                lstAlgos.add(Consolidated);
            }   
            system.debug('lstAlgos: '+lstAlgos);
            Result = JSON.Serialize(lstAlgos);    
        }                                      
        return Result;           
    }  

    /*
     * Check if the customer account is valid
     */
    webService static Boolean IsAccountValid(String acctId){
        List<Account> acct = [Select Id from Account where Id = :acctId and IsDeleted = false LIMIT 1];
        if(acct != null && acct.size() > 0){
            return true;
        }
        return false;
    }
    
    /*
     * @category  Adult / Pediatric / Both
     * @officeHours     true / false
     * @accountId       community user account Id
     * Check if customer has appropriate licence
     * @return    true if licence valid/ false
     */
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

    /*
     * Log customer interactions on different searches
     */ 
    webService static void logCustomerInteraction(CustomerInetractionWrapperObject ciObj, String mode, String status){  
        Account acct = [Select Id, TriageNow_Mode__c from Account where Id = :ciObj.accountId and IsDeleted = false LIMIT 1]; 
        DateTime currentDateTime = Datetime.now();
        TriageNow_Customer_Interaction__c tnCI = new TriageNow_Customer_Interaction__c();
        tnCI.Current_App_Mode__c = acct.TriageNow_Mode__c;
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
    
    
    /*
     * map of search results
     */   
    webService static string Symptoms(string symptom,string DefaultVersionYear,string catagoryref,Boolean Officehours,string Gender, String input,boolean Hospice,integer offsetSize, boolean isCustomerInteraction,boolean OrderByFirstAcquity,Integer Age){  
        CustomerInetractionWrapperObject ciwo = (CustomerInetractionWrapperObject)JSON.deserialize(input,CustomerInetractionWrapperObject.class);
        Map<String,AlgoDetails> mapAlgosret = new Map<String,AlgoDetails>();
        if(symptom!= null){ 
            
            system.debug('Officehours'+Officehours);
            system.debug('Gender'+Gender);
            system.debug('Age '+Age);
            //check if algoid is sent appropriately.
            set<string> catagory = new set<string>();
            /**
            * Check if license exists for given account on Adult/ Pediatric, OH/AH content 
            */
            boolean IsAdult =  isLicenceAvailable('Adult',Officehours,ciwo.accountId);          
            boolean IsPediatric =  isLicenceAvailable('Pediatric',Officehours,ciwo.accountId);

            if(catagoryref.contains('Both') && (IsPediatric || IsAdult)){
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
                AlgoDetails Wrapobja = new AlgoDetails(); 
                Wrapobja.Response_Message ='Error';
                Wrapobja.Response_Message ='This search is currently disabled for your account. Please request TriageNow administrator to enable the search.';
                mapAlgosret.put('Error',Wrapobja);
                return JSON.Serialize(mapAlgosret);               
            }           
           
            system.debug(catagory);                        
            String versionyear = DefaultVersionYear;
            List<string> TNDb = getTNDb(catagory, versionyear, Officehours);         
            string result;  
            List<string> categoryList = new List<string>(); 
            categoryList.addAll(catagory);
            mapAlgosret = Algomap(symptom,categoryList,catagoryref,Officehours,Gender,TNDb,offsetSize,Hospice,OrderByFirstAcquity,Age);
            result = JSON.Serialize(mapAlgosret);
            return result ;
          
        }else{
            AlgoDetails Wrapobja = new AlgoDetails(); 
            Wrapobja.Response_Message ='Error';
            Wrapobja.Response_Message ='Please Type a Search Keyword.';
            mapAlgosret.put('Error',Wrapobja);
            return JSON.Serialize(mapAlgosret); 
        }
                
    }
    
    webService static string TitleSymptoms(string symptom,string DefaultVersionYear,string catagoryref,Boolean Officehours,string Gender, String input,boolean Hospice,integer offsetSize, boolean isCustomerInteraction,boolean OrderByFirstAcquity,Integer Age){  
        CustomerInetractionWrapperObject ciwo = (CustomerInetractionWrapperObject)JSON.deserialize(input,CustomerInetractionWrapperObject.class);
        Map<String,AlgoDetails> mapAlgosret = new Map<String,AlgoDetails>();
        if(symptom!= null){    
            system.debug('Officehours'+Officehours);
            system.debug('Gender'+Gender);
            system.debug('Age '+Age);
            //check if algoid is sent appropriately.
            set<string> catagory = new set<string>();
            /**
            * Check if license exists for given account on Adult/ Pediatric, OH/AH content 
            */
            boolean IsAdult =  isLicenceAvailable('Adult',Officehours,ciwo.accountId);          
            boolean IsPediatric =  isLicenceAvailable('Pediatric',Officehours,ciwo.accountId);

            if(catagoryref.contains('Both') && (IsPediatric || IsAdult)){
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
                AlgoDetails Wrapobja = new AlgoDetails(); 
                Wrapobja.Response_Message ='Error';
                Wrapobja.Response_Message ='This search is currently disabled for your account. Please request TriageNow administrator to enable the search.';
                mapAlgosret.put('Error',Wrapobja);
                return JSON.Serialize(mapAlgosret);               
            }           
           
            system.debug(catagory);                        
            String versionyear = DefaultVersionYear;
            List<string> TNDb = getTNDb(catagory, versionyear, Officehours);         
            string result;  
            List<string> categoryList = new List<string>(); 
            categoryList.addAll(catagory);
            mapAlgosret = TitleAlgomap(symptom,categoryList,catagoryref,Officehours,Gender,TNDb,offsetSize,Hospice,OrderByFirstAcquity,Age);
            result = JSON.Serialize(mapAlgosret);
            return result ;
          
        }else{
            AlgoDetails Wrapobja = new AlgoDetails(); 
            Wrapobja.Response_Message ='Error';
            Wrapobja.Response_Message ='Please Type a Search Keyword.';
            mapAlgosret.put('Error',Wrapobja);
            return JSON.Serialize(mapAlgosret); 
        }
                
    }
  

        //catagory will give me adult/pediatric
        //office hours in offcie or not in offce
        //gender will give you gender

     static Map<String,AlgoDetails> Algomap(string symptomskey,List<String> catagory,String catagoryref,Boolean Officehours,string Gender, List<string> TNDb,integer offset,boolean Hospice,boolean OrderByFirstAcquity,Integer AgeInMonth){  
    Map<String,AlgoDetails> mapAlgos = new Map<String,AlgoDetails>();

    if(MapAlgoKeyworddataSort==null || MapAlgoKeyworddataSort.size()<=0){
        Map<String,AlgoDetails> tempmapAlgos = new Map<String,AlgoDetails>();
        Map<String,Boolean> mapBestGuideLine = new Map<String,Boolean>();
        List<Boolean> listOfBestGuide=new List<Boolean>();
        try{
            string IsActive = 'Active'; //check active records only
            string symptoms = symptomskey+'%';
            List<String> AcessAlgoID = new List<String>();
            if(!symptoms.contains('#')){
                List<TriageNow_AlgorithmSearchWord__c> ALgosearchword = [SELECT AD_AlgorithmID__c, TriageNow_Import_Database__r.Db_Alias__c
                                                                        FROM TriageNow_AlgorithmSearchWord__c
                                                                        WHERE AD_SearchWord__c like: symptoms
                                                                        AND TriageNow_Import_Database__c IN:TNDb];
            
            System.debug('ALgosearchword>>>>>>>>>>>: '+ALgosearchword);
                for(TriageNow_AlgorithmSearchWord__c AcesAlgo : ALgosearchword){                 
                    AcessAlgoID.add(AcesAlgo.AD_AlgorithmID__c);
                }
            } else {
                AcessAlgoID = symptoms.split('#');          
            }
            String tndbNew;
            try{
                tndbNew=[select id from TriageNow_Import_Database__c where Db_Alias__c='Crosswalk'].id;
            }catch(Exception e){
                
            }
         
            System.debug(tndbNew);
            if(Officehours){
                List<TriageNow_Related_OHAlgorithm__c> talcc=[select Id,AD_AlgorithmID__c,BestGuideline__c from TriageNow_Related_OHAlgorithm__c where TriageNow_Import_Database__c =:tndbNew and BestGuideline__c=true];
                for(TriageNow_Related_OHAlgorithm__c tv:talcc){
                    mapBestGuideLine.put(tv.AD_AlgorithmID__c,tv.BestGuideline__c);
                }
            } else {
                
                    List<TriageNow_Related_AdultAHAlgorithm__c> talcc=[select Id,AD_AlgorithmID__c,BestGuideline__c from TriageNow_Related_AdultAHAlgorithm__c where TriageNow_Import_Database__c =:tndbNew and BestGuideline__c=true];
                    for(TriageNow_Related_AdultAHAlgorithm__c tv:talcc){
                        mapBestGuideLine.put(tv.AD_AlgorithmID__c,tv.BestGuideline__c);
                    }
                
                    List<TriageNow_Related_PedAHAlgorithm__c> talcc1=[select Id,AD_AlgorithmID__c,BestGuideline__c from TriageNow_Related_PedAHAlgorithm__c where TriageNow_Import_Database__c =:tndbNew and BestGuideline__c=true];
                    for(TriageNow_Related_PedAHAlgorithm__c tv:talcc1){
                        mapBestGuideLine.put(tv.AD_AlgorithmID__c,tv.BestGuideline__c);
                    }   
                
            }
            
            String uniqueId;                
            List<String> lstGender = new List<String>();
            if(Gender != null && Gender != '' && Gender !='B'){
                lstGender.add(Gender);
            }
            lstGender.add('B');
        
            system.debug('All the algorithm ids form ALGO SEARCH TABLE'+AcessAlgoID);
            
            System.debug('IsActive '+IsActive);
            System.debug('TNDb '+TNDb);
            System.debug('gender '+gender);

            // 11 is taken tso to check if new record is present or not.
            Integer LimtofSoql = 100;  
            string soql ='SELECT AlgorithmID__c,DefinitionXHTML__c,Id,Title__c,Category__c,Group__c,Type__c,Acuity__c,Gender__c, TriageNow_Import_Database__r.Db_Alias__c FROM TriageNow_Algorithm__c WHERE AlgorithmID__c IN :AcessAlgoID AND Status__c = :IsActive AND Min_Age_Months__c <=:AgeInMonth and Max_Age_Months__c >=:AgeInMonth AND TriageNow_Import_Database__c IN :TNDb AND Gender__c IN :lstGender Order by Acuity__c ASC Limit: LimtofSoql';
            
            System.debug('soql::::::::: '+soql);
        
            List<TriageNow_Algorithm__c> ALgorithm1 =  database.query(soql);
    
            system.debug('ALgorith Value form ALGORITHM OBJECT'+ALgorithm1);
            system.debug('ALgorithm1.size(): '+ALgorithm1.size());

            //These IDS would be used for referencing all the Other tables according to the Triage now import database
            List<string> AccessAlgoIds = new List<string>();
            AlgoDetails algdtl;
            for(TriageNow_Algorithm__c algo : ALgorithm1){
                uniqueId = algo.AlgorithmID__c+'-'+algo.TriageNow_Import_Database__r.Db_Alias__c;
                algdtl = new AlgoDetails();
                if(mapBestGuideLine.get(algo.AlgorithmID__c)==true){algdtl.BestGuideLine=mapBestGuideLine.get(algo.AlgorithmID__c);
                    algdtl.AlgorithmID = algo.AlgorithmID__c;
                    algdtl.DefinitionXHTML = algo.DefinitionXHTML__c;
                    algdtl.Acuity = algo.Acuity__c;
                    algdtl.Title = algo.Title__c;
                    algdtl.category = algo.Category__c;
                    algdtl.Type = algo.Type__c;
                    algdtl.Gender = algo.Gender__c;    
                    algdtl.Group1 = algo.Group__c;
                    MapAlgoKeyworddataSort.put(uniqueId,algdtl); 
                } else {
                    algdtl.BestGuideLine=false;
                    algdtl.AlgorithmID = algo.AlgorithmID__c;
                    algdtl.DefinitionXHTML = algo.DefinitionXHTML__c;
                    algdtl.Acuity = algo.Acuity__c;
                    algdtl.Title = algo.Title__c;
                    algdtl.category = algo.Category__c;
                    algdtl.Type = algo.Type__c;
                    algdtl.Gender = algo.Gender__c;    
                    algdtl.Group1 = algo.Group__c;
                    tempmapAlgos.put(uniqueId,algdtl); 
                }
                      
                AccessAlgoIds.add(algo.AlgorithmID__c);                 
            }   
            if(!tempmapAlgos.isEmpty()){
                MapAlgoKeyworddataSort.putAll(tempmapAlgos);
            }
            System.debug('AccessAlgoIds: '+AccessAlgoIds);
            String qsoql ='SELECT AD_AlgorithmID__c,AlgorithmID__r.Acuity__c,SMAG_LINK_ID__c, TriageNow_Import_Database__r.Db_Alias__c,QuestionOrder__c FROM TriageNow_Question__c WHERE AD_AlgorithmID__c IN: AccessAlgoIds AND TriageNow_Import_Database__c IN:TNDb';
            if(Hospice == true){
                qsoql +=' AND DispositionLevel__r.Hospice__c =: Hospice';
            }
            qsoql += ' AND SMAG_LINK_ID__c != 0.0 Order by AD_AlgorithmID__c, TriageNow_Import_Database__r.Db_Alias__c ASC, QuestionOrder__c ASC';
            System.debug('qsoql: '+qsoql);
            List<TriageNow_Question__c> Question = database.query(qsoql);

            system.debug('questions'+Question);
            Map<String,SmagLink> mapSmag= new Map<String,Smaglink>();
            List<Decimal> smagIds = new List<Decimal>();
            List<string> smag = new List<string>();
            String prevUniqueId = '';
            String currUniqueId = '';
            SmagLink sstemp;        
            Set<Decimal> uniqueSmgIds = new Set<Decimal>();
            for(TriageNow_Question__c QUSIDS : Question){
                currUniqueId = QUSIDS.AD_AlgorithmID__c+'-'+QUSIDS.TriageNow_Import_Database__r.Db_Alias__c;
                if(MapAlgoKeyworddataSort.get(currUniqueId) != null){
                    if(prevUniqueId != '' && prevUniqueId !=currUniqueId){
                        smagIds.addAll(uniqueSmgIds);
                        smagIds.sort();
                        for(Decimal smg: smagIds){                      
                            MapAlgoKeyworddataSort.get(prevUniqueId).Smaglink.add(mapSmag.get(string.valueof(smg)));
                        }
                        System.debug('MapAlgoKeyworddataSort.get(prevUniqueId): '+MapAlgoKeyworddataSort.get(prevUniqueId)+'>>>>>>>>>>prevUniqueId: '+prevUniqueId);
                        mapSmag = new Map<String,Smaglink>();
                        smagIds = new List<Decimal>();
                        uniqueSmgIds = new Set<Decimal>();
                    }
                    sstemp =  new SmagLink();
                    sstemp.Algoid = QUSIDS.AD_AlgorithmID__c;     
                    
                    sstemp.SmagAlgoID = string.valueof(QUSIDS.SMAG_LINK_ID__c); 
                    sstemp.SmagUniqueID = QUSIDS.SMAG_LINK_ID__c+'-'+QUSIDS.TriageNow_Import_Database__r.Db_Alias__c;
                    mapSmag.put(String.valueOf(QUSIDS.SMAG_LINK_ID__c),sstemp);
                    uniqueSmgIds.add(QUSIDS.SMAG_LINK_ID__c);
                    smag.add(string.valueof(QUSIDS.SMAG_LINK_ID__c));   
                    prevUniqueId = currUniqueId;
                } else if (prevUniqueId != '' && prevUniqueId !=currUniqueId){
                    smagIds.addAll(uniqueSmgIds);
                    smagIds.sort();
                    for(Decimal smg: smagIds){                      
                        MapAlgoKeyworddataSort.get(prevUniqueId).Smaglink.add(mapSmag.get(string.valueof(smg)));
                    }
                    System.debug('MapAlgoKeyworddataSort.get(prevUniqueId): '+MapAlgoKeyworddataSort.get(prevUniqueId)+'>>>>>>>>>>prevUniqueId: '+prevUniqueId);
                    mapSmag = new Map<String,Smaglink>();
                    smagIds = new List<Decimal>();
                    uniqueSmgIds = new Set<Decimal>();
                    prevUniqueId = currUniqueId;
                }
            }  
        smagIds.addAll(uniqueSmgIds);
        smagIds.sort();
        for(Decimal smg: smagIds){                      
            MapAlgoKeyworddataSort.get(prevUniqueId).Smaglink.add(mapSmag.get(string.valueof(smg)));
        }
        System.debug('MapAlgoKeyworddataSort.get(prevUniqueId): '+MapAlgoKeyworddataSort.get(prevUniqueId)+'>>>>>>>>>>prevUniqueId: '+prevUniqueId);            
        
        system.debug('Smaglinks'+smag);
        List<TriageNow_Algorithm__c> lstSmaglinkTitles = [SELECT AlgorithmID__c,Acuity__c,Title__c , Gender__c, TriageNow_Import_Database__r.Db_Alias__c
                                                  FROM TriageNow_Algorithm__c 
                                                  WHERE AlgorithmID__c IN : smag
                                                  AND Status__c =: IsActive
                                                  AND Min_Age_Months__c <=:AgeInMonth and Max_Age_Months__c >=:AgeInMonth 
                                                  AND TriageNow_Import_Database__c IN:TNDb
                                                  AND Gender__c IN :lstGender]; 
                                                  
        Map<String,String> mapSmaglinkTitles = new Map<String,String>();
        String prevAlgo;
        String currAlgo;
        for(TriageNow_Algorithm__c ta:lstSmaglinkTitles){
            uniqueId = ta.AlgorithmID__c+'-'+ta.TriageNow_Import_Database__r.Db_Alias__c;
            mapSmaglinkTitles.put(uniqueId,ta.Title__c+'~'+ta.Gender__c+'~'+ta.Acuity__c);
        }
        List<Smaglink> tempSmagList; 
        List<Smaglink> tempSmagList2;       
        for(String algoId : MapAlgoKeyworddataSort.keySet()){
            tempSmagList = MapAlgoKeyworddataSort.get(algoId).Smaglink;
            tempSmagList2 = new List<Smaglink>();
            for(Smaglink smaglk : tempSmagList){
                if(mapSmaglinkTitles.get(smaglk.SmagUniqueID) != null){
                    String[] smagData = mapSmaglinkTitles.get(smaglk.SmagUniqueID).split('~');
                    smaglk.Title = smagData[0];
                    smaglk.dbAlias = smagData[1];
                    smaglk.SmagAcuity = decimal.valueOf(smagData[2]);
                    tempSmagList2.add(smaglk);
                }           
            }
           // tempSmagList2.sort();
            System.debug('tempSmagList2: '+tempSmagList2);
            MapAlgoKeyworddataSort.get(algoId).Smaglink = tempSmagList2;
        }               
                
        system.debug('MapAlgoKeyworddataSort final: '+MapAlgoKeyworddataSort);
 
    } catch(Exception e){
      system.debug('message'+e.getmessage());
      system.debug('message'+e.getLinenumber());
      
   }
        /********************Shorting Search by Work cards********************************/
        List<String> keys = new List<String>();
        List<String> keys1 = new List<String>();
        
        for(String key :MapAlgoKeyworddataSort.keySet()){
            String sortKey =  MapAlgoKeyworddataSort.get(key).Acuity+''+MapAlgoKeyworddataSort.get(key).BestGuideLine+'~'+key;
            if(MapAlgoKeyworddataSort.get(key).BestGuideLine){
                keys.add(MapAlgoKeyworddataSort.get(key).Acuity+'a'+'~'+key);
            }else{
                keys1.add(sortKey);
            }
            System.debug('keys '+keys+' keys1 '+keys1);
            System.debug('Key: '+key+'Concept: '+MapAlgoKeyworddataSort.get(key).Concept);
        }          
         
        if(!OrderByFirstAcquity){
            keys.sort();
            keys1.sort();
            keys.addAll(keys1);                          
        } else {                        
            keys1.sort();
            keys.addAll(keys1);
            keys.sort();                       
        }
        
        Map<String,AlgoDetails> m = new Map<String,AlgoDetails>();
        for(integer i=0;i<keys.size();i++){
            String key = keys.get(i);           
            m.put(key.split('~')[1],MapAlgoKeyworddataSort.get(key.split('~')[1]));           
        }
        MapAlgoKeyworddataSort = new Map<String,AlgoDetails>();
        MapAlgoKeyworddataSort.putAll(m);
         /********************End Shorting cards********************************/
        }
        System.debug('>>>>>>>>>>>>>>. '+MapAlgoKeyworddataSort);       
    
        List<String> mapKeys1 =new List<String>(MapAlgoKeyworddataSort.keySet());
        for(integer i=offset;i<mapKeys1.size();i++){
            String key = mapKeys1.get(i);
            if(mapAlgos.size()<11){
                mapAlgos.put(key,MapAlgoKeyworddataSort.get(key));
            } else {
                break;
            }
        }
        return mapAlgos; 
}
    
    static Map<String,AlgoDetails> TitleAlgomap(string symptoms,List<String> catagory,String catagoryref,Boolean Officehours,string Gender, List<string> TNDb,integer offset,boolean Hospice,boolean OrderByFirstAcquity,Integer AgeInMonth){  
        Map<String,AlgoDetails> mapAlgos = new Map<String,AlgoDetails>();
        if(MapAlgoTitleddataSort==null || MapAlgoTitleddataSort.size()<=0){
        Map<String,AlgoDetails> tempmapAlgos = new Map<String,AlgoDetails>();
        try{
            Map<String,Boolean> mapBestGuideLine = new Map<String,Boolean>();
            string IsActive = 'Active'; //check active records only
            List<String> AcessAlgoID = new List<String>();
            /*if(!symptoms.contains('#')){
                List<TriageNow_AlgorithmSearchWord__c> ALgosearchword = [SELECT AD_AlgorithmID__c, TriageNow_Import_Database__r.Db_Alias__c
                                                                        FROM TriageNow_AlgorithmSearchWord__c
                                                                        WHERE AD_SearchWord__c =: symptoms
                                                                        AND TriageNow_Import_Database__c IN:TNDb];
                
            System.debug('ALgosearchword>>>>>>>>>>>: '+ALgosearchword);
                for(TriageNow_AlgorithmSearchWord__c AcesAlgo : ALgosearchword){                 
                    AcessAlgoID.add(AcesAlgo.AD_AlgorithmID__c);
                }
            } else {
                AcessAlgoID = symptoms.split('#');          
            }*/
            String uniqueId;                
            List<String> lstGender = new List<String>();
            if(Gender != null && Gender != '' && Gender !='B'){
                lstGender.add(Gender);
            }
            lstGender.add('B');
            String tndbNew;
            try{
                tndbNew=[select id from TriageNow_Import_Database__c where Db_Alias__c='Crosswalk'].id;
            }catch(Exception e){
                
            }
             
            System.debug(tndbNew);
            if(Officehours){
                List<TriageNow_Related_OHAlgorithm__c> talcc=[select Id,AD_AlgorithmID__c,BestGuideline__c from TriageNow_Related_OHAlgorithm__c where TriageNow_Import_Database__c =:tndbNew and BestGuideline__c=true];
            for(TriageNow_Related_OHAlgorithm__c tv:talcc){
                mapBestGuideLine.put(tv.AD_AlgorithmID__c,tv.BestGuideline__c);
            }
            }else{
               
            List<TriageNow_Related_AdultAHAlgorithm__c> talcc=[select Id,AD_AlgorithmID__c,BestGuideline__c from TriageNow_Related_AdultAHAlgorithm__c where TriageNow_Import_Database__c =:tndbNew and BestGuideline__c=true];
            for(TriageNow_Related_AdultAHAlgorithm__c tv:talcc){
                mapBestGuideLine.put(tv.AD_AlgorithmID__c,tv.BestGuideline__c);
            }
            
            List<TriageNow_Related_PedAHAlgorithm__c> talcc1=[select Id,AD_AlgorithmID__c,BestGuideline__c from TriageNow_Related_PedAHAlgorithm__c where TriageNow_Import_Database__c =:tndbNew and BestGuideline__c=true];
            for(TriageNow_Related_PedAHAlgorithm__c tv:talcc1){
                mapBestGuideLine.put(tv.AD_AlgorithmID__c,tv.BestGuideline__c);
            }   
            
            }
            
            system.debug('All the algorithm ids form ALGO SEARCH TABLE'+AcessAlgoID);
            
            System.debug('IsActive '+IsActive);
            System.debug('TNDb '+TNDb);
            System.debug('gender '+gender);

            // 11 is taken tso to check if new record is present or not.
            Integer LimtofSoql = 100; 
            String finlTitle=symptoms+'%';          
            string soql ='SELECT AlgorithmID__c,DefinitionXHTML__c,Id,Title__c,Category__c,Group__c,Type__c,Acuity__c,Gender__c, TriageNow_Import_Database__r.Db_Alias__c FROM TriageNow_Algorithm__c WHERE Title__c like:finlTitle AND Status__c = :IsActive AND Min_Age_Months__c <=:AgeInMonth and Max_Age_Months__c >=:AgeInMonth AND TriageNow_Import_Database__c IN :TNDb AND Gender__c IN :lstGender Order by Acuity__c ASC Limit: LimtofSoql';
            
            System.debug('soql::::::::: '+soql);
            List<TriageNow_Algorithm__c> ALgorithm1 =  database.query(soql);
    
            system.debug('ALgorith Value form ALGORITHM OBJECT'+ALgorithm1);
            system.debug('ALgorithm1.size(): '+ALgorithm1.size());

            //These IDS would be used for referencing all the Other tables according to the Triage now import database 
            List<string> AccessAlgoIds = new List<string>();
            AlgoDetails algdtl;
            for(TriageNow_Algorithm__c algo : ALgorithm1){
                uniqueId = algo.AlgorithmID__c+'-'+algo.TriageNow_Import_Database__r.Db_Alias__c;
                algdtl = new AlgoDetails();
                if(mapBestGuideLine.get(algo.AlgorithmID__c)==true){
                algdtl.BestGuideLine=mapBestGuideLine.get(algo.AlgorithmID__c);
                algdtl.AlgorithmID = algo.AlgorithmID__c;
                algdtl.DefinitionXHTML = algo.DefinitionXHTML__c;
                algdtl.Acuity = algo.Acuity__c;
                algdtl.Title = algo.Title__c;
                algdtl.category = algo.Category__c;
                algdtl.Type = algo.Type__c;
                algdtl.Gender = algo.Gender__c;    
                algdtl.Group1 = algo.Group__c;
                MapAlgoTitleddataSort.put(uniqueId,algdtl); 
                }else{
                    algdtl.BestGuideLine=false;
                    algdtl.AlgorithmID = algo.AlgorithmID__c;
                algdtl.DefinitionXHTML = algo.DefinitionXHTML__c;
                algdtl.Acuity = algo.Acuity__c;
                algdtl.Title = algo.Title__c;
                algdtl.category = algo.Category__c;
                algdtl.Type = algo.Type__c;
                algdtl.Gender = algo.Gender__c;    
                algdtl.Group1 = algo.Group__c;
                tempmapAlgos.put(uniqueId,algdtl); 
                }
                      
                AccessAlgoIds.add(algo.AlgorithmID__c);
                
            }    
            if(!tempmapAlgos.isEmpty()){
                MapAlgoTitleddataSort.putAll(tempmapAlgos);
            }
            System.debug('AccessAlgoIds: '+AccessAlgoIds);
            String qsoql ='SELECT AD_AlgorithmID__c,SMAG_LINK_ID__c,QuestionOrder__c,AlgorithmID__r.Acuity__c,TriageNow_Import_Database__r.Db_Alias__c FROM TriageNow_Question__c WHERE AD_AlgorithmID__c IN: AccessAlgoIds AND TriageNow_Import_Database__c IN:TNDb';
            if(Hospice == true){
                qsoql +=' AND DispositionLevel__r.Hospice__c =: Hospice';
            }
            qsoql += ' AND SMAG_LINK_ID__c != 0.0 Order by AD_AlgorithmID__c, TriageNow_Import_Database__r.Db_Alias__c ASC, QuestionOrder__c ASC';
            System.debug('qsoql: '+qsoql);
            List<TriageNow_Question__c> Question = database.query(qsoql);

            system.debug('questions'+Question);
            Map<String,SmagLink> mapSmag= new Map<String,Smaglink>();
            List<Decimal> smagIds = new List<Decimal>();
            List<string> smag = new List<string>();
            String prevUniqueId = '';
            String currUniqueId = '';
            SmagLink sstemp;        
            Set<Decimal> uniqueSmgIds = new Set<Decimal>();
            for(TriageNow_Question__c QUSIDS : Question){
                currUniqueId = QUSIDS.AD_AlgorithmID__c+'-'+QUSIDS.TriageNow_Import_Database__r.Db_Alias__c;
                if(MapAlgoTitleddataSort.get(currUniqueId) != null){
                    if(prevUniqueId != '' && prevUniqueId !=currUniqueId){
                        smagIds.addAll(uniqueSmgIds);
                        smagIds.sort();
                        for(Decimal smg: smagIds){                      
                            MapAlgoTitleddataSort.get(prevUniqueId).Smaglink.add(mapSmag.get(string.valueof(smg)));
                        }
                        System.debug('MapAlgoTitleddataSort.get(prevUniqueId): '+MapAlgoTitleddataSort.get(prevUniqueId)+'>>>>>>>>>>prevUniqueId: '+prevUniqueId);
                        mapSmag = new Map<String,Smaglink>();
                        smagIds = new List<Decimal>();
                        uniqueSmgIds = new Set<Decimal>();
                    }
                    sstemp =  new SmagLink();
                    sstemp.Algoid = QUSIDS.AD_AlgorithmID__c;   
                                     
                    sstemp.SmagAlgoID = string.valueof(QUSIDS.SMAG_LINK_ID__c); 
                    sstemp.SmagUniqueID = QUSIDS.SMAG_LINK_ID__c+'-'+QUSIDS.TriageNow_Import_Database__r.Db_Alias__c;
                    mapSmag.put(String.valueOf(QUSIDS.SMAG_LINK_ID__c),sstemp);
                    uniqueSmgIds.add(QUSIDS.SMAG_LINK_ID__c);
                    smag.add(string.valueof(QUSIDS.SMAG_LINK_ID__c));   
                    prevUniqueId = currUniqueId;
                } else if(prevUniqueId != '' && prevUniqueId !=currUniqueId){
                    smagIds.addAll(uniqueSmgIds);
                    smagIds.sort();
                    for(Decimal smg: smagIds){                      
                        MapAlgoTitleddataSort.get(prevUniqueId).Smaglink.add(mapSmag.get(string.valueof(smg)));
                    }
                    System.debug('MapAlgoTitleddataSort.get(prevUniqueId): '+MapAlgoTitleddataSort.get(prevUniqueId)+'>>>>>>>>>>prevUniqueId: '+prevUniqueId);
                    mapSmag = new Map<String,Smaglink>();
                    smagIds = new List<Decimal>();
                    uniqueSmgIds = new Set<Decimal>();
                    prevUniqueId = currUniqueId;
                }
            }  
            smagIds.addAll(uniqueSmgIds);
            smagIds.sort();
            for(Decimal smg: smagIds){                      
                MapAlgoTitleddataSort.get(prevUniqueId).Smaglink.add(mapSmag.get(string.valueof(smg)));
            }
            System.debug('MapAlgoTitleddataSort.get(prevUniqueId): '+MapAlgoTitleddataSort.get(prevUniqueId)+'>>>>>>>>>>prevUniqueId: '+prevUniqueId);
            
            
            system.debug('Smaglinks'+smag);
            List<TriageNow_Algorithm__c> lstSmaglinkTitles = [SELECT AlgorithmID__c,Acuity__c,Title__c , Gender__c, TriageNow_Import_Database__r.Db_Alias__c
                                                      FROM TriageNow_Algorithm__c 
                                                      WHERE AlgorithmID__c IN : smag
                                                      AND Status__c =: IsActive
                                                      AND Min_Age_Months__c <=:AgeInMonth and Max_Age_Months__c >=:AgeInMonth 
                                                      AND TriageNow_Import_Database__c IN:TNDb
                                                      AND Gender__c IN :lstGender]; 
                                                      
            Map<String,String> mapSmaglinkTitles = new Map<String,String>();
            String prevAlgo;
            String currAlgo;
            for(TriageNow_Algorithm__c ta:lstSmaglinkTitles){
                uniqueId = ta.AlgorithmID__c+'-'+ta.TriageNow_Import_Database__r.Db_Alias__c;
                mapSmaglinkTitles.put(uniqueId,ta.Title__c+'~'+ta.Gender__c+'~'+ta.Acuity__c);
            }
            List<Smaglink> tempSmagList; 
            List<Smaglink> tempSmagList2;       
            for(String algoId : MapAlgoTitleddataSort.keySet()){
                tempSmagList = MapAlgoTitleddataSort.get(algoId).Smaglink;
                tempSmagList2 = new List<Smaglink>();
                for(Smaglink smaglk : tempSmagList){
                    if(mapSmaglinkTitles.get(smaglk.SmagUniqueID) != null){
                        String[] smagData = mapSmaglinkTitles.get(smaglk.SmagUniqueID).split('~');
                        smaglk.Title = smagData[0];
                        smaglk.dbAlias = smagData[1];
                        smaglk.SmagAcuity = decimal.valueOf(smagData[2]);
                        tempSmagList2.add(smaglk);
                    }           
                }
               // tempSmagList2.sort();
                System.debug('tempSmagList2: '+tempSmagList2);
                MapAlgoTitleddataSort.get(algoId).Smaglink = tempSmagList2;
            }               
                    
            system.debug('MapAlgoTitleddataSort final: '+MapAlgoTitleddataSort);
     
        } catch(Exception e){
          system.debug('message'+e.getmessage());
          system.debug('message'+e.getLinenumber());
          
       }
        /********************Shorting Title cards********************************/
        List<String> keys = new List<String>();
        List<String> keys1 = new List<String>();
        for(String key :MapAlgoTitleddataSort.keySet()){
            String sortKey =  MapAlgoTitleddataSort.get(key).Acuity+''+MapAlgoTitleddataSort.get(key).BestGuideLine+'~'+key;
            if(MapAlgoTitleddataSort.get(key).BestGuideLine){
                keys.add(MapAlgoTitleddataSort.get(key).Acuity+'a'+'~'+key);
            }else{
                keys1.add(sortKey);
            }                   
        }
        if(!OrderByFirstAcquity){
            keys.sort();
            keys1.sort();
            keys.addAll(keys1);                          
        } else {                        
            keys1.sort();
            keys.addAll(keys1);
            keys.sort();                       
        }
        
        Map<String,AlgoDetails> m = new Map<String,AlgoDetails>();
        for(integer i=0;i<keys.size();i++){
            String key = keys.get(i);           
            m.put(key.split('~')[1],MapAlgoTitleddataSort.get(key.split('~')[1]));           
        }
        MapAlgoTitleddataSort = new Map<String,AlgoDetails>();
        MapAlgoTitleddataSort.putAll(m);
         /********************End Shorting cards********************************/
        system.debug('MapAlgoTitleddataSort::::::: '+MapAlgoTitleddataSort);
        }
           
    
        List<String> mapKeys1 =new List<String>(MapAlgoTitleddataSort.keySet());
        for(integer i=offset;i<mapKeys1.size();i++){
            String key = mapKeys1.get(i);
            if(mapAlgos.size()<11){
                mapAlgos.put(key,MapAlgoTitleddataSort.get(key));
            } else {
                break;
            }
        }       
       return mapAlgos;      
    }
    webService static string getSelectedAlgoData(string uniqueId,string DefaultVersionYear,String category,String Gender, String input,boolean Hospice,Integer Age){
       string result;    
        Integer AgeInMonths=Age;
       AlgoDetails algoDetail = new AlgoDetails();
        try{            
            String AlgorithmID = uniqueId.split('-')[0];
            String DbAlias = uniqueId.split('-')[1]; 
            String versionyear = DefaultVersionYear;
            algoDetail.Reference = new  List<AlgoRefAndCitations>();
            algoDetail.QuestionAdvice  = new List<QuestionAdvice>();
            algoDetail.Supplement = new List<Supplement>();
            algoDetail.RelatedACI = new List<RelatedACI>();
            algoDetail.Question = new List<Question>();
            algoDetail.Smaglink = new List<Smaglink>();
            
            String Triagenowimport = '';    
            string IsActive = 'Active'; //check active records only
            if(versionyear != null || versionyear != ''){ 
                Triagenowimport = 'Select id from TriageNow_Import_Database__c where Db_Alias__c = \'' +DbAlias+ '\' AND Version_Year__c = \''+versionyear+'\'';
            }else{
                Triagenowimport = 'Select id from TriageNow_Import_Database__c where Db_Alias__c = \'' +DbAlias+ '\'';
            }
            List<TriageNow_Import_Database__c> TriagenowimportIDS  = database.query(Triagenowimport);
            system.debug('TriagenowimportIDS'+TriagenowimportIDS);
            //convert it into string 
            List<string> TNDb = new list<string>();
            for(TriageNow_Import_Database__c tt : TriagenowimportIDS){
                 TNDb.add(string.valueof(tt.get('id'))); 
            }           
            System.debug('IsActive '+IsActive);
            System.debug('category '+category);
            System.debug('TNDb '+TNDb);
            System.debug('gender '+gender);
            //System.debug('Age '+Age);
            List<string> lstGender = new List<string>();
                if(gender!=null && gender!='B' && gender!=''){
                lstGender.add(gender);
                }
            lstGender.add('B');
            TriageNow_Algorithm__c ALgorithm1 = [ SELECT AlgorithmID__c,BackgroundXHTML__c,Copyright__c,DefinitionXHTML__c,FirstAidXHTML__c,Id,
                                                      InitialAssessmentQuestions__c,Title__c,Category__c,Group__c,Type__c,System__c,Anatomy__c,
                                                      VersionYear__c,Status__c,SnoMedCode__c,ICD9Code__c,Acuity__c,Gender__c,Max_Age_Months__c,
                                                      Max_Age_Years__c,Min_Age_Months__c,Min_Age_Years__c,Prescription_Option__c 
                                                      FROM TriageNow_Algorithm__c 
                                                      WHERE AlgorithmID__c = : AlgorithmID
                                                      AND Status__c =: IsActive
                                                      AND Min_Age_Months__c <=:AgeInMonths and Max_Age_Months__c >=:AgeInMonths  
                                                      AND TriageNow_Import_Database__c IN:TNDb
                                                      AND Gender__c IN :lstGender LIMIT 1 ];

            system.debug('ALgorith Value form ALGORITHM OBJECT'+ALgorithm1);
            system.debug('***************************************');

            //These IDS would be used for referencing all the Other tables according to the Triage now import database
            system.debug('^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^');       
            if(ALgorithm1 != null){                 
                algoDetail.DefinitionXHTML = ALgorithm1.DefinitionXHTML__c;
                algoDetail.ICD9Code = ALgorithm1.ICD9Code__c == null ? 'NA':ALgorithm1.ICD9Code__c ;
                algoDetail.Acuity = ALgorithm1.Acuity__c;
                algoDetail.AlgoID = ALgorithm1.Id;
                algoDetail.FirstAidXHTML = ALgorithm1.FirstAidXHTML__c;
                algoDetail.BackgroundXHTML = ALgorithm1.BackgroundXHTML__c;
                algoDetail.AlgorithmID = ALgorithm1.AlgorithmID__c;
                algoDetail.Title = ALgorithm1.Title__c;
                algoDetail.category=ALgorithm1.Category__c;
                algoDetail.Copyright = ALgorithm1.Copyright__c;
                algoDetail.Anatomy = ALgorithm1.Anatomy__c;                
                algoDetail.System1 = ALgorithm1.System__c;
                algoDetail.Type = ALgorithm1.Type__c;
                algoDetail.Gender = ALgorithm1.Gender__c;    
                algoDetail.Group1 = ALgorithm1.Group__c;                
                algoDetail.VersionYear = ALgorithm1.VersionYear__c;
                algoDetail.SnoMedCod = ALgorithm1.SnoMedCode__c == null ? 'NA':ALgorithm1.SnoMedCode__c;
                algoDetail.Min_Age_Year = string.valueof(ALgorithm1.Min_Age_Years__c);
                algoDetail.Max_Age_Year = string.valueof(ALgorithm1.Max_Age_Years__c);
                algoDetail.Min_Age_Month = string.valueof(ALgorithm1.Min_Age_Months__c);
                algoDetail.Max_Age_Month = string.valueof(ALgorithm1.Max_Age_Months__c);
                algoDetail.Prescription = ALgorithm1.Prescription_Option__c;               
                algoDetail.InitialAssessmentQuestions = ALgorithm1.InitialAssessmentQuestions__c; 
            } 
            system.debug('algoDetail'+algoDetail); 

            //If lookupfails Then populate the table and bring the ids and then hit the table with its ids

            List<TriageNow_AlgorithmReference__c> Algoreference  =  [SELECT AlgorithmID__c,AD_AlgorithmID__c,ReferenceID__r.PubMedURL__c,ReferenceID__r.ReferenceAuthor__c
                                                                  ,ReferenceID__r.ReferenceSource__c,ReferenceID__r.ReferenceTitle__c 
                                                                  FROM TriageNow_AlgorithmReference__c 
                                                                  WHERE AD_AlgorithmID__c = : AlgorithmID
                                                                  AND TriageNow_Import_Database__c IN:TNDb];     

            System.debug('REferences from ALGORITHM REFERENCE : '+Algoreference);
            system.debug('***************************************');                             

            for(TriageNow_AlgorithmReference__c ref : Algoreference){
                AlgoRefAndCitations RefValList = new  AlgoRefAndCitations(); 
                RefValList.PubMedURL =  ref.ReferenceID__r.PubMedURL__c;
                RefValList.ReferenceAuthor = ref.ReferenceID__r.ReferenceAuthor__c;
                RefValList.ReferenceSource = ref.ReferenceID__r.ReferenceSource__c;
                RefValList.ReferenceTitle = ref.ReferenceID__r.ReferenceTitle__c;    
                RefValList.RefALgoID = ref.AD_AlgorithmID__c; 
                algoDetail.Reference.add(RefValList);
            }
          
            String qsoql ='SELECT AD_AlgorithmID__c,AD_DispositionLevel__c,DispositionLevel__r.Hospice__c ,DispositionLevel__r.levelid__c,AlgorithmID__c,CMS__c,DispositionLevel__r.DispositionHeading__c, Id,Information__c,Name,QuestionID__c,QuestionOrder__c,Question__c,AlgorithmID__r.Acuity__c,SMAG_LINK_ID__c,TriageNow_Import_Database__r.Db_Alias__c FROM TriageNow_Question__c WHERE AD_AlgorithmID__c =: AlgorithmID AND TriageNow_Import_Database__c IN:TNDb';
                                                   
            if(Hospice == true){
                qsoql +=' AND DispositionLevel__r.Hospice__c =: Hospice';
            }
            qsoql += ' Order by DispositionLevel__r.levelid__c DESC , SMAG_LINK_ID__c ASC, QuestionOrder__c ASC';
            System.debug('qsoql>>>>>selected algo: '+qsoql);
            List<TriageNow_Question__c> Question =  database.query(qsoql);
            system.debug('All the question form TRIAGE QUESTION'+Question);
            system.debug('***************************************');                                          

            List<SmagLink> ss =new List<Smaglink>();                                                 
            List<string> smag = new List<string>();
            Map<String,SmagLink> mapSmagLinks = new Map<String,SmagLink>();
            for(TriageNow_Question__c QUSIDS : Question){
                if(QUSIDS.SMAG_LINK_ID__c != 0.0){
                    SmagLink sstemp =  new SmagLink();
                    sstemp.Algoid = QUSIDS.AD_AlgorithmID__c;                    
                    sstemp.SmagAlgoID = string.valueof(QUSIDS.SMAG_LINK_ID__c); 
                    sstemp.SmagUniqueID = QUSIDS.SMAG_LINK_ID__c+'-'+QUSIDS.TriageNow_Import_Database__r.Db_Alias__c;
                    mapSmagLinks.put(String.valueOf(QUSIDS.SMAG_LINK_ID__c),sstemp);
                    smag.add(string.valueof(QUSIDS.SMAG_LINK_ID__c));
                    ss.add(sstemp);   
                    system.debug('Added smag link in iteration'+ss);
                }
            } 
            
            List<TriageNow_Algorithm__c> Smaglink = [SELECT AlgorithmID__c,Title__c,Acuity__c,Gender__c 
                                              FROM TriageNow_Algorithm__c 
                                              WHERE AlgorithmID__c IN : smag
                                              AND Status__c =: IsActive
                                              AND Min_Age_Months__c <=:AgeInMonths and Max_Age_Months__c >=:AgeInMonths 
                                              AND TriageNow_Import_Database__c IN:TNDb
                                              AND Gender__c IN:lstGender 
                                              Order by AlgorithmID__c ASC ];

                                
            Map<String,String> mapSmags = new Map<String,String>();
            for(TriageNow_Algorithm__c Sl : Smaglink){
            
                mapSmags.put(Sl.AlgorithmID__c,Sl.Title__c+'~'+Sl.Gender__c+'~'+Sl.Acuity__c);
            }
            System.debug('mapSmags-------------->'+mapSmags);
            for(String smgId : mapSmagLinks.keySet()){
                if(mapSmags.get(smgId) != null){
                        String[] smagData = mapSmags.get(smgId).split('~');
                        SmagLink slink = mapSmagLinks.get(smgId);
                        slink.Title = smagData[0];
                        slink.dbAlias = smagData[1];
                        slink.SmagAcuity = decimal.valueOf(smagData[2]);
                        algoDetail.Smaglink.add(slink);
                    }
            }
           // algoDetail.Smaglink.sort();
            
            for(TriageNow_Question__c qus : Question){
            Question Quse  = new Question();  
                 
            if(mapSmags.get(String.valueOf(qus.SMAG_LINK_ID__c)) != null){
                    String[] smagData = mapSmags.get(String.valueOf(qus.SMAG_LINK_ID__c)).split('~'); 
                    Quse.SmagquesAcuity = decimal.valueOf(smagData[2]); 
                }
                Quse.Question = qus.Question__c;
                Quse.QuestionAdviceOrder = qus.QuestionOrder__c;
                Quse.QusAlgoID = qus.AD_AlgorithmID__c;
                Quse.QusIDtomap = qus.QuestionID__c;
                if(qus.Information__c != null){
                    if(qus.Information__c.startsWith('Go to Guideline:')){
                        qus.Information__c = qus.Information__c.remove('Go to Guideline:');
                    }
                }
                Quse.Information = qus.Information__c;
                 
                if(mapSmags.get(String.valueOf(qus.SMAG_LINK_ID__c)) != null){
                   // if(qus.SMAG_LINK_ID__c != null){
                    Quse.Smaglink = qus.SMAG_LINK_ID__c;
                    Quse.SmaglinkUniqueId = qus.SMAG_LINK_ID__c+'-'+qus.TriageNow_Import_Database__r.Db_Alias__c;
                }
                Quse.DispositionHeading = qus.DispositionLevel__r.DispositionHeading__c;
                Quse.DispositionID = string.valueof(qus.DispositionLevel__r.levelid__c);  
                System.debug('Ouse--->'+Quse);              
                algoDetail.Question.add(Quse);
                
                System.debug('algoDetail.Question-->'+algoDetail.Question);
            }                          
           
            List<string> Qusid = new List<String>();
            for(TriageNow_Question__c QUSIDS : Question){
                Qusid.add(QUSIDS.QuestionID__c);
            }  
            system.debug('Smag link'+algoDetail.Smaglink);

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
                algoDetail.QuestionAdvice.add(Qusadv);
            }
          
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
                algoDetail.Supplement.add(supple);
            }  

            system.debug('algoDetail.Supplement'+algoDetail.Supplement);

            string TriagenowimportforACI = '';
              //only we have to hit the after care instruction  database logic for that is below 
            if(versionyear != null || versionyear != ''){ 
                TriagenowimportforACI = 'Select id from TriageNow_Import_Database__c where Version_Year__c = \''+versionyear+'\' AND';
            }else{
                TriagenowimportforACI = 'Select id from TriageNow_Import_Database__c where';
            }
            
            string pACI = 'Pediatric / ACI';
            string aACI = 'Adult / ACI';
            
              TriagenowimportforACI += ' Db_Alias__c = \'' +pACI+ '\'';   
            
                TriagenowimportforACI += ' Db_Alias__c = \'' +aACI+ '\'';   
            
            
            system.debug('TriagenowimportforACI'+TriagenowimportforACI);            
            List<TriageNow_Import_Database__c> TNDbACI;
            try{
             TNDbACI = database.query(TriagenowimportforACI);
            }catch(Exception e){
                
            }
            System.debug('TNDbACI--->'+TNDbACI);

            List<string> Tnndb = new List<string>();
            try{
            for(TriageNow_Import_Database__c tt : TNDbACI){
                  Tnndb.add(string.valueof(tt.get('Id'))); 
            }
            }catch(Exception e){
                
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
                    algoDetail.RelatedACI.add(rAci);
                }
                system.debug('algoDetail.RelatedACI'+algoDetail.RelatedACI);
            }///this is for Related ACi 
            
        } catch(Exception e){
              system.debug('message'+e.getmessage());
              system.debug('message'+e.getLinenumber());
              
        }
        system.debug('algoDetail final>>>>>>>>>> '+algoDetail);
        result = JSON.Serialize(algoDetail);
        return result ;
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

    // Algorithm data 
    global class AlgoDetails { 
        public AlgoDetails(){
            Response_Status ='Success';
            this.Reference = new List<AlgoRefAndCitations>(); 
            this.QuestionAdvice = new List<QuestionAdvice>(); 
            this.Question = new List<Question>();
            this.Supplement = new List<Supplement>();
            this.RelatedACI = new List<RelatedACI>();
            this.Smaglink = new List<SmagLink>();
            this.Concept = new List<ConceptID>();
        }
        webService Boolean BestGuideLine{get;set;}
        webService string uniqueId{get;set;}
        webService string AlgoID{get;set;}
        webService string AlgorithmID{get;set;}
        webService string DefinitionXHTML{get;set;} 
        webService string ICD9Code{get;set;}
        webService decimal Acuity{get;set;}
        webService string FirstAidXHTML{get;set;}
        webService string BackgroundXHTML{get;set;} 
        webService string Title{get;set;}
        webService string Copyright{get;set;}
        webService string category{get;set;}
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
        webservice string Response_Status{get;set;}
        webservice string Response_Message{get;set;}
        webService List<AlgoRefAndCitations> Reference{get;set;} 
        webService List<QuestionAdvice> QuestionAdvice{get;set;} 
        webService List<Question> Question{get;set;} 
        webService List<Supplement> Supplement{get;set;}
        webService List<RelatedACI> RelatedACI{get;set;}
        webservice List<SmagLink> Smaglink{get;set;}
        webservice List<ConceptID> Concept{get;set;}
    }
    // References and Citations
    global class AlgoRefAndCitations{
        webService string RefALgoID{get;set;} 
        webService string PubMedURL{get;set;} 
        webService string ReferenceAuthor{get;set;} 
        webService string ReferenceSource{get;set;} 
        webService string ReferenceTitle{get;set;} 
    } 

    // Smag Link
    global class SmagLink {
        Webservice string SmagUniqueID{get;set;}
        Webservice string SmagAlgoID{get;set;}
        Webservice string Algoid{get;set;}
        Webservice string Title{get;set;}
        Webservice string dbAlias{get;set;}
        webService string SFDCAlgoid{get;set;}
        webService decimal SmagAcuity{get;set;}
        
         /* global Integer compareTo(Object ObjToCompare) { 
         return Title.CompareTo(((SmagLink)ObjToCompare).Title);  
        } */
        
    }

    // Triage Assessment Questions
    global class Question {
        webService string QusAlgoID{get;set;}
        webService string DispositionID{get;set;}
        webService string QusIDtomap{get;set;}            
        webService string Question{get;set;} 
        webService string Information{get;set;} 
        webService decimal Smaglink{get;set;}  
        webService decimal SmagquesAcuity{get;set;}         
        webService String SmaglinkUniqueId{get;set;} 
        webService decimal QuestionAdviceOrder{get;set;}            
        webservice string DispositionHeading{get;set;}
       
    } 

    // Care Advice                         
    global class QuestionAdvice{
           webService string QusID{get;set;} 
           webService string Advice{get;set;} 
           webService boolean IsAdvicePresent{get;set;}
    } 

    // Supplement
    global class Supplement{
        webservice string SupplementAlgoID{get;set;}
        webservice string Content{get;set;} 
        webservice string Title{get;set;} 
        webservice string Category{get;set;} 
    }

    // Concept Id
    global class ConceptID{
        webservice string ConceptID{get;set;}
        webservice string AlgorithmID{get;set;}
    }

    // Related ACI
    global class RelatedACI{
        webservice string RelatedAciAlgoID{get;set;}
        webservice string Title{get;set;}
        webservice string Definition{get;set;} 
        webservice string Advice{get;set;}
        webservice string Hiall{get;set;}
        webservice string CallBack{get;set;}
    }
   

// This is for NLP Engine implementation=-----------------------------------------------------------------------------------------------------------    
     webService static string GetNLPData(List<string> Symptom,String DefaultVersionYear,string catagoryref,Boolean Officehours,string Gender,String input,boolean hospice ,Integer Offsetsize, boolean isCustomerInteraction,boolean OrderByFirstAcquity,Integer Age){
         List<String> tempt;
        List<String> tempt1;
        List<String> tempt2;
        List<String> tempt3;
        List<String> tempt4;
        List<String> tempt5;
        List<String> tempt6;
        CustomerInetractionWrapperObject ciwo = (CustomerInetractionWrapperObject)JSON.deserialize(input,CustomerInetractionWrapperObject.class);
        
        Map<String,AlgoDetails> result = new Map<String,AlgoDetails>();
        
        try{ 
            tempt=new List<String>();
            tempt1=new List<String>();
            tempt2=new List<String>();
            tempt3=new List<String>();
            tempt4=new List<String>();
            tempt5=new List<String>();
            tempt6=new List<String>();
            set<string> catagory = new set<string>();
            System.debug('Officehours '+Officehours);
            System.debug('Age '+Age);
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
            }else if(catagoryref.contains('Pediatric') && IsPediatric){     catagory.add('Pediatric');
            }else{
                AlgoDetails Wrapobja = new AlgoDetails(); 
                Wrapobja.Response_Status = 'Error';
                Wrapobja.Response_Message ='This search is currently disabled for your account. Please request TriageNow administrator to enable the search.';
                result.put('Error',Wrapobja);
                return JSON.serialize(result);
            }             
           
            system.debug(catagory);
            /**
            * Check if license exists for given account on Adult/ Pediatric, OH/AH content 
            */ 
                String tndbNew;
            try{
            tndbNew=[select id from TriageNow_Import_Database__c where Db_Alias__c='Crosswalk'].id;
            }catch(Exception e){

            }
            String versionyear = DefaultVersionYear;
            List<string> TNDb = getTNDb(catagory, versionyear, Officehours); 
            List<String> AcessAlgoID = new List<string>();          
            if(Officehours){
                 List<TriageNow_Concept__c> ConceptWord = [SELECT Title__c FROM TriageNow_Concept__c WHERE  ConceptID__c IN: Symptom AND TriageNow_Import_Database__c IN: TNDb];

                 List<string> conceptid = new List<string>(); 
                 for(TriageNow_Concept__c tc : ConceptWord){
                      conceptid.add(tc.Title__c);
                 }       
                    System.debug('conceptid '+conceptid);
                    System.debug('TNDb '+TNDb);

        List<TriageNow_Related_OHAlgorithm__c> ALgosearchword = [SELECT AD_AlgorithmID__c
                                                               FROM TriageNow_Related_OHAlgorithm__c 
                                                               where AD_ConceptID__c IN: Symptom
                                                               AND TriageNow_Import_Database__c =:tndbNew];               
                for(TriageNow_Related_OHAlgorithm__c AcesAlgo : ALgosearchword){
                    AcessAlgoID.add(AcesAlgo.AD_AlgorithmID__c);
                }
             
                AcessAlgoID.sort();
                system.debug('All the algorithm ids form ALGO SEARCH TABLE'+AcessAlgoID);                                          
                             
            } else{
                /*
            if(catagoryref.contains('Adult')){
            List<TriageNow_Related_AdultAHAlgorithm__c> AlgoCCC=[SELECT AD_AlgorithmID__c
                                                               FROM TriageNow_Related_AdultAHAlgorithm__c 
                                                               where AD_ConceptID__c IN: Symptom
                                                               AND TriageNow_Import_Database__c =:tndbNew];
            List<String> AcessAlgoIDssss = new List<string>();
                for(TriageNow_Related_AdultAHAlgorithm__c AcesAlgo : AlgoCCC){
                    AcessAlgoID.add(AcesAlgo.AD_AlgorithmID__c);
                }      
                AcessAlgoID.sort();
            }else if(catagoryref.contains('Pediatric')){
            List<TriageNow_Related_PedAHAlgorithm__c> AlgoCCC=[SELECT AD_AlgorithmID__c FROM TriageNow_Related_PedAHAlgorithm__c where AD_ConceptID__c IN: Symptom AND TriageNow_Import_Database__c =:tndbNew];
            List<String> AcessAlgoIDssss = new List<string>();
                for(TriageNow_Related_PedAHAlgorithm__c AcesAlgo : AlgoCCC){
                    AcessAlgoID.add(AcesAlgo.AD_AlgorithmID__c);
                }      
                AcessAlgoID.sort();   
            }else{
                */
                List<TriageNow_Related_AdultAHAlgorithm__c> AlgoCCC=[SELECT AD_AlgorithmID__c
                                                               FROM TriageNow_Related_AdultAHAlgorithm__c 
                                                               where AD_ConceptID__c IN: Symptom
                                                               AND TriageNow_Import_Database__c =:tndbNew];
            List<String> AcessAlgoIDssss = new List<string>();
                for(TriageNow_Related_AdultAHAlgorithm__c AcesAlgo : AlgoCCC){
                    AcessAlgoID.add(AcesAlgo.AD_AlgorithmID__c);
                }     
					System.debug('AcessAlgoID '+AcessAlgoID);
                //AcessAlgoID.sort();
            List<String> AcessAlgoIDn = new List<string>();
            List<TriageNow_Related_PedAHAlgorithm__c> AlgoCCC1=[SELECT AD_AlgorithmID__c FROM TriageNow_Related_PedAHAlgorithm__c where AD_ConceptID__c IN: Symptom AND TriageNow_Import_Database__c =:tndbNew];
            List<String> AcessAlgoIDssss1 = new List<string>();
                for(TriageNow_Related_PedAHAlgorithm__c AcesAlgo : AlgoCCC1){
                    AcessAlgoIDn.add(AcesAlgo.AD_AlgorithmID__c);
                }  
				System.debug('AcessAlgoIDn '+AcessAlgoIDn);
				AcessAlgoID.addAll(AcessAlgoIDn);
                AcessAlgoID.sort(); 
            //}        
               
            } 
            List<string> temp = new List<string>();
            temp.addAll(catagory);
            result = AlgomapforNLP(AcessAlgoID,temp,catagoryref,Symptom,Officehours,Gender,TNDb,Offsetsize,hospice,DefaultVersionYear,OrderByFirstAcquity,Age); 
        } catch (Exception e) {
            system.debug('e.getCause();'+e.getCause());
            system.debug('e.getMessage()'+e.getMessage());
            AlgoDetails Wrapobja = new AlgoDetails(); 
            Wrapobja.Response_Status = 'Error';
            Wrapobja.Response_Message ='This search is currently disabled for your account. Please request TriageNow administrator to enable the search.';
            result.put('Error',Wrapobja);
            return JSON.serialize(result);
        }
        return JSON.serialize(result);   
     }

     static Map<String,AlgoDetails> AlgomapforNLP(List<string> AlgoID,list<string> catagory,String catagoryref,List<string> ConceptId,Boolean Officehours,string Gender, List<string> TNDb,integer offset,boolean hospice,String DefaultVersionYear,Boolean OrderByFirstAcquity,Integer AgeInMonth){
        List<String> tempt;
        List<String> tempt1;
        List<String> tempt2;
        List<String> tempt3;
        List<String> tempt4;
        List<String> tempt5;
        List<String> tempt6;
        List<String> tempt7;
        system.debug('Entering AlgomapforNLP>>>>>>>>>>>>>>>>>>>>');
        Map<String,AlgoDetails> mapAlgos = new Map<String,AlgoDetails>();
        
           
        if(MapAlgoChiefdataSort==null || MapAlgoChiefdataSort.size()<=0){
        try{
            Map<String,Boolean> mapBestGuideLine=new Map<String,Boolean>();
        Map<String,AlgoDetails> tempmapAlgos;
        string returnresult ; 
            tempmapAlgos = new Map<String,AlgoDetails>();
            tempt=new List<String>();
            tempt1=new List<String>();
            tempt2=new List<String>();
            tempt3=new List<String>();
            tempt4=new List<String>();
            tempt5=new List<String>();
            tempt6=new List<String>();
            tempt7=new List<String>();
            String uniqueId;
            string IsActive = 'Active'; //check active records only
            system.debug('^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^');
               
            System.debug('IsActive '+IsActive);
            System.debug('TNDb '+TNDb);
            System.debug('gender '+gender);
            System.debug('AlgoID '+AlgoID);
            List<String> lstGender = new List<String>();
            if(Gender != null && Gender != '' && Gender !='B'){
                lstGender.add(Gender);
            }
            lstGender.add('B');
            // 11 is taken tso to check if new record is present or not.
            Integer LimtofSoql = 100; 
            String tndbNew;
            try{
            tndbNew=[select id from TriageNow_Import_Database__c where Db_Alias__c='Crosswalk'].id;
            }catch(Exception e){

            }   
            System.debug('catagory '+catagory); 
            String soql='';
            List<TriageNow_Algorithm__c> ALgorithm1=new List<TriageNow_Algorithm__c>();
            List<TriageNow_Algorithm__c> ALgorithm2=new List<TriageNow_Algorithm__c>();
            List<string> AcessAlgoID1=new List<string>();
            List<string> AcessAlgoID2=new List<string>();
            List<TriageNow_Related_AdultAHAlgorithm__c> AlgoCCCa=[SELECT AD_AlgorithmID__c FROM TriageNow_Related_AdultAHAlgorithm__c where AD_ConceptID__c IN: ConceptId AND TriageNow_Import_Database__c =:tndbNew];
            for(TriageNow_Related_AdultAHAlgorithm__c AcesAlgo : AlgoCCCa){
                    AcessAlgoID1.add(AcesAlgo.AD_AlgorithmID__c);
                }
                if(AcessAlgoID1!=null){
                    AcessAlgoID1.sort();
                }
                
            List<TriageNow_Related_PedAHAlgorithm__c> AlgoCCCp=[SELECT AD_AlgorithmID__c FROM TriageNow_Related_PedAHAlgorithm__c where AD_ConceptID__c IN: ConceptId AND TriageNow_Import_Database__c =:tndbNew];
            for(TriageNow_Related_PedAHAlgorithm__c AcesAlgo : AlgoCCCp){
                    AcessAlgoID2.add(AcesAlgo.AD_AlgorithmID__c);
                }
                if(AcessAlgoID2!=null){
                    AcessAlgoID2.sort();
                }
            
                soql ='SELECT AlgorithmID__c,DefinitionXHTML__c,Id,Title__c,Category__c,Group__c,Type__c,Acuity__c,Gender__c, TriageNow_Import_Database__r.Db_Alias__c FROM TriageNow_Algorithm__c WHERE AlgorithmID__c IN : AlgoID AND Status__c =: IsActive AND Min_Age_Months__c <=:AgeInMonth and Max_Age_Months__c >=:AgeInMonth AND TriageNow_Import_Database__c IN:TNDb AND Gender__c IN :lstGender Order by Acuity__c ASC Limit: LimtofSoql';
                ALgorithm1 =  database.query(soql);
            
           
            
            
            system.debug('ALgorith Value form ALGORITHM OBJECT'+ALgorithm1);
            system.debug('***************************************');
            if(Officehours){
                 List<TriageNow_Related_OHAlgorithm__c> talcc=[select Id,AD_AlgorithmID__c,BestGuideline__c from TriageNow_Related_OHAlgorithm__c where TriageNow_Import_Database__c =:tndbNew and BestGuideline__c=true and AD_ConceptID__c IN:ConceptId];
            for(TriageNow_Related_OHAlgorithm__c tv:talcc){
                mapBestGuideLine.put(tv.AD_AlgorithmID__c,tv.BestGuideline__c);
            }
            }else{
                    List<TriageNow_Related_AdultAHAlgorithm__c> talcca=[select Id,AD_AlgorithmID__c,BestGuideline__c from TriageNow_Related_AdultAHAlgorithm__c where TriageNow_Import_Database__c =:tndbNew and BestGuideline__c=true and AD_ConceptID__c IN:ConceptId];
                    for(TriageNow_Related_AdultAHAlgorithm__c tv:talcca){
                    mapBestGuideLine.put(tv.AD_AlgorithmID__c,tv.BestGuideline__c);
                    }
                    List<TriageNow_Related_PedAHAlgorithm__c> talccp=[select Id,AD_AlgorithmID__c,BestGuideline__c from TriageNow_Related_PedAHAlgorithm__c where TriageNow_Import_Database__c =:tndbNew and BestGuideline__c=true and AD_ConceptID__c IN:ConceptId];
                    for(TriageNow_Related_PedAHAlgorithm__c tv:talccp){
                    mapBestGuideLine.put(tv.AD_AlgorithmID__c,tv.BestGuideline__c);
                    } 
                
            }
            

             //These IDS would be used for referencing all the Other tables according to the Triage now import database
            List<string> AccessAlgoIds = new List<string>();
            AlgoDetails algdtl;
            for(TriageNow_Algorithm__c algo : ALgorithm1){
                uniqueId = algo.AlgorithmID__c+'-'+algo.TriageNow_Import_Database__r.Db_Alias__c;
                algdtl = new AlgoDetails();
                if(mapBestGuideLine.get(algo.AlgorithmID__c)==true){
                algdtl.BestGuideLine=mapBestGuideLine.get(algo.AlgorithmID__c);
                algdtl.uniqueId = uniqueId;
                algdtl.AlgorithmID = algo.AlgorithmID__c;
                algdtl.DefinitionXHTML = algo.DefinitionXHTML__c;
                algdtl.Acuity = algo.Acuity__c;
                algdtl.Title = algo.Title__c;
                algdtl.category = algo.Category__c;
                algdtl.Type = algo.Type__c;
                algdtl.Gender = algo.Gender__c;    
                algdtl.Group1 = algo.Group__c;
                MapAlgoChiefdataSort.put(uniqueId,algdtl);
                }else{
                    algdtl.BestGuideLine=false;
                    algdtl.uniqueId = uniqueId;
                algdtl.AlgorithmID = algo.AlgorithmID__c;
                algdtl.DefinitionXHTML = algo.DefinitionXHTML__c;
                algdtl.Acuity = algo.Acuity__c;
                algdtl.Title = algo.Title__c;
                algdtl.category = algo.Category__c;
                algdtl.Type = algo.Type__c;
                algdtl.Gender = algo.Gender__c;    
                algdtl.Group1 = algo.Group__c;
                tempmapAlgos.put(uniqueId,algdtl);
                }
                
                AccessAlgoIds.add(algo.AlgorithmID__c);
            }   
            AccessAlgoIds.sort();
            if(!tempmapAlgos.isEmpty()){
                MapAlgoChiefdataSort.putAll(tempmapAlgos);
            }
            System.debug('ALL Algo ids in string ALGORITHM IDS  :'+AccessAlgoIds);
            
            //this is written to bring the ICD10 information
            
            
            String prevUniqueId='';
            String currUniqueId='';
            String prevUniqueId1='';
            String currUniqueId1='';
            if(Officehours){
                List<TriageNow_Related_OHAlgorithm__c> AlgoCCC = [SELECT AD_AlgorithmID__c,AD_ConceptID__c,TriageNow_Import_Database__r.Db_Alias__c
                                                                   FROM TriageNow_Related_OHAlgorithm__c 
                                                                   where AD_AlgorithmID__c IN: AccessAlgoIds
                                                                   AND TriageNow_Import_Database__c =:tndbNew 
                                                                   Order By AD_AlgorithmID__c,TriageNow_Import_Database__r.Db_Alias__c];
            
            for(TriageNow_Related_OHAlgorithm__c TA :AlgoCCC)
            { 
                currUniqueId = TA.AD_AlgorithmID__c+'-'+'Adult and Pediatric / OH';
                if(MapAlgoChiefdataSort.get(currUniqueId) !=null){
                    if(prevUniqueId !='' && prevUniqueId !=currUniqueId){                   
                        MapAlgoChiefdataSort.put(prevUniqueId,algdtl);
                    }   
                    algdtl = MapAlgoChiefdataSort.get(currUniqueId); 
                    ConceptID cid = new ConceptID();
                    cid.ConceptID = TA.AD_ConceptID__c;
                    cid.AlgorithmID = TA.AD_AlgorithmID__c;
                    if(algdtl.uniqueId == currUniqueId){
                        algdtl.Concept.add(cid);
                    }
                    prevUniqueId = currUniqueId;                    
                } else if(prevUniqueId !='' && prevUniqueId !=currUniqueId){                    
                    MapAlgoChiefdataSort.put(prevUniqueId,algdtl);
                }
            }
            }else{
            
                List<TriageNow_Related_AdultAHAlgorithm__c> AlgoCCC = [SELECT AD_AlgorithmID__c,AD_ConceptID__c,TriageNow_Import_Database__r.Db_Alias__c
                                                                   FROM TriageNow_Related_AdultAHAlgorithm__c 
                                                                   where AD_AlgorithmID__c IN: AccessAlgoIds
                                                                   AND TriageNow_Import_Database__c =:tndbNew 
                                                                   Order By AD_AlgorithmID__c,TriageNow_Import_Database__r.Db_Alias__c];
            
            for(TriageNow_Related_AdultAHAlgorithm__c TA :AlgoCCC)
            { 
                currUniqueId1 = TA.AD_AlgorithmID__c+'-'+'Adult / AH';
                if(MapAlgoChiefdataSort.get(currUniqueId1) !=null){
                    if(prevUniqueId1 !='' && prevUniqueId1 !=currUniqueId1){                   
                        MapAlgoChiefdataSort.put(prevUniqueId1,algdtl);
                    }   
                    algdtl = MapAlgoChiefdataSort.get(currUniqueId1); 
                    ConceptID cid = new ConceptID();
                    cid.ConceptID = TA.AD_ConceptID__c;
                    cid.AlgorithmID = TA.AD_AlgorithmID__c;
                    if(algdtl.uniqueId == currUniqueId1){
                        algdtl.Concept.add(cid);
                    }
                    prevUniqueId1 = currUniqueId1;                    
                } else if(prevUniqueId1 !='' && prevUniqueId1 !=currUniqueId1){                    
                    MapAlgoChiefdataSort.put(prevUniqueId1,algdtl);
                }
            }
            
                List<TriageNow_Related_PedAHAlgorithm__c> AlgoCCC1 = [SELECT AD_AlgorithmID__c,AD_ConceptID__c,TriageNow_Import_Database__r.Db_Alias__c FROM TriageNow_Related_PedAHAlgorithm__c where AD_AlgorithmID__c IN: AccessAlgoIds AND TriageNow_Import_Database__c =:tndbNew Order By AD_AlgorithmID__c,TriageNow_Import_Database__r.Db_Alias__c];
            for(TriageNow_Related_PedAHAlgorithm__c TA :AlgoCCC1)
            { 
                currUniqueId = TA.AD_AlgorithmID__c+'-'+'Pediatric / AH';
                if(MapAlgoChiefdataSort.get(currUniqueId) !=null){
                    if(prevUniqueId !='' && prevUniqueId !=currUniqueId){                   
                        MapAlgoChiefdataSort.put(prevUniqueId,algdtl);
                    }   
                    algdtl = MapAlgoChiefdataSort.get(currUniqueId); 
                    ConceptID cid = new ConceptID();
                    cid.ConceptID = TA.AD_ConceptID__c;
                    cid.AlgorithmID = TA.AD_AlgorithmID__c;
                    if(algdtl.uniqueId == currUniqueId){
                        algdtl.Concept.add(cid);
                    }
                    prevUniqueId = currUniqueId;                    
                } else if(prevUniqueId !='' && prevUniqueId !=currUniqueId){                    
                    MapAlgoChiefdataSort.put(prevUniqueId,algdtl);
                }
            }
            
                
            }
           
            
            System.debug('MapAlgoChiefdataSort NLP: '+MapAlgoChiefdataSort);            
            System.debug('MapAlgoChiefdataSort.size: NLP'+MapAlgoChiefdataSort.size());
            String qsoql ='SELECT AD_AlgorithmID__c,AlgorithmID__r.Acuity__c,SMAG_LINK_ID__c, TriageNow_Import_Database__r.Db_Alias__c,QuestionOrder__c FROM TriageNow_Question__c WHERE AD_AlgorithmID__c IN: AccessAlgoIds AND TriageNow_Import_Database__c IN:TNDb';
            if(Hospice == true){  qsoql +=' AND DispositionLevel__r.Hospice__c =: hospice';
            }
            qsoql += ' AND SMAG_LINK_ID__c != 0.0 Order by AD_AlgorithmID__c, TriageNow_Import_Database__r.Db_Alias__c ASC, QuestionOrder__c ASC';
            System.debug('qsoql: '+qsoql);
            List<TriageNow_Question__c> Question =  database.query(qsoql);

            system.debug('questions'+Question);
            Map<String,SmagLink> mapSmag= new Map<String,Smaglink>();
            List<Decimal> smagIds = new List<Decimal>();
            List<string> smag = new List<string>();
            Set<Decimal> uniqueSmgIds = new Set<Decimal>();
            prevUniqueId = '';
            SmagLink sstemp;
            for(TriageNow_Question__c QUSIDS : Question){
                currUniqueId = QUSIDS.AD_AlgorithmID__c+'-'+QUSIDS.TriageNow_Import_Database__r.Db_Alias__c;
                if(MapAlgoChiefdataSort.get(currUniqueId) != null){
                    if(prevUniqueId != '' && prevUniqueId !=currUniqueId){
                        smagIds.addAll(uniqueSmgIds);
                        smagIds.sort();
                        for(Decimal smg: smagIds){                      
                            MapAlgoChiefdataSort.get(prevUniqueId).Smaglink.add(mapSmag.get(string.valueof(smg)));
                        }
                        System.debug('MapAlgoChiefdataSort.get(prevUniqueId): '+MapAlgoChiefdataSort.get(prevUniqueId)+'>>>>>>>>>>prevUniqueId: '+prevUniqueId);
                        mapSmag = new Map<String,Smaglink>();
                        smagIds = new List<Decimal>();
                        uniqueSmgIds = new Set<Decimal>();
                    }
                    sstemp =  new SmagLink();
                    sstemp.Algoid = QUSIDS.AD_AlgorithmID__c;   
                    sstemp.SmagAlgoID = string.valueof(QUSIDS.SMAG_LINK_ID__c); 
                    sstemp.SmagUniqueID = QUSIDS.SMAG_LINK_ID__c+'-'+QUSIDS.TriageNow_Import_Database__r.Db_Alias__c;
                    mapSmag.put(String.valueOf(QUSIDS.SMAG_LINK_ID__c),sstemp);
                    uniqueSmgIds.add(QUSIDS.SMAG_LINK_ID__c);
                    smag.add(string.valueof(QUSIDS.SMAG_LINK_ID__c));   
                    prevUniqueId = currUniqueId;
                } else if(prevUniqueId != '' && prevUniqueId !=currUniqueId){
                    smagIds.addAll(uniqueSmgIds);
                    smagIds.sort();
                    for(Decimal smg: smagIds){                      
                        MapAlgoChiefdataSort.get(prevUniqueId).Smaglink.add(mapSmag.get(string.valueof(smg)));
                    }
                    System.debug('MapAlgoChiefdataSort.get(prevUniqueId): '+MapAlgoChiefdataSort.get(prevUniqueId)+'>>>>>>>>>>prevUniqueId: '+prevUniqueId);
                    mapSmag = new Map<String,Smaglink>();
                    smagIds = new List<Decimal>();
                    uniqueSmgIds = new Set<Decimal>();
                    prevUniqueId = currUniqueId;
                }
            }  
            smagIds.addAll(uniqueSmgIds);
            smagIds.sort();
            for(Decimal smg: smagIds){                      
                MapAlgoChiefdataSort.get(prevUniqueId).Smaglink.add(mapSmag.get(string.valueof(smg)));
            }
            System.debug('MapAlgoChiefdataSort.get(prevUniqueId): '+MapAlgoChiefdataSort.get(prevUniqueId)+'>>>>>>>>>>prevUniqueId: '+prevUniqueId);
             
            system.debug('Smaglinks'+smag);
            List<TriageNow_Algorithm__c> lstSmaglinkTitles = [SELECT AlgorithmID__c,Acuity__c,Title__c ,Gender__c, TriageNow_Import_Database__r.Db_Alias__c
                                                      FROM TriageNow_Algorithm__c 
                                                      WHERE AlgorithmID__c IN : smag
                                                      AND Status__c =: IsActive
                                                      AND Min_Age_Months__c <=:AgeInMonth and Max_Age_Months__c >=:AgeInMonth  
                                                      AND TriageNow_Import_Database__c IN:TNDb
                                                      AND Gender__c IN :lstGender]; 
                                                      
            Map<String,String> mapSmaglinkTitles = new Map<String,String>();
            for(TriageNow_Algorithm__c ta:lstSmaglinkTitles){
                uniqueId = ta.AlgorithmID__c+'-'+ta.TriageNow_Import_Database__r.Db_Alias__c;
                mapSmaglinkTitles.put(uniqueId,ta.Title__c+'~'+ta.Gender__c+'~'+ta.Acuity__c);
            }
            List<Smaglink> tempSmagList; 
            List<Smaglink> tempSmagList2;  
            List<Smaglink> tempSmagList3; 
            List<Smaglink> tempSmagList4;           
            for(String algoId1 : MapAlgoChiefdataSort.keySet()){
                tempSmagList = MapAlgoChiefdataSort.get(algoId1).Smaglink;
                tempSmagList2 = new List<Smaglink>();
                for(Smaglink smaglk : tempSmagList){
                    if(mapSmaglinkTitles.get(smaglk.SmagUniqueID) != null){
                        String[] smagData = mapSmaglinkTitles.get(smaglk.SmagUniqueID).split('~');
                        smaglk.Title = smagData[0];
                        smaglk.dbAlias = smagData[1];
                        smaglk.SmagAcuity = decimal.valueOf(smagData[2]); 
                        tempSmagList2.add(smaglk);
                    }               
                }
                //tempSmagList2.sort();
                System.debug('tempSmagList2: '+tempSmagList2);
                MapAlgoChiefdataSort.get(algoId1).Smaglink = tempSmagList2;
            }                
                    
            system.debug('MapAlgoChiefdataSort AFTER Smag Links '+MapAlgoChiefdataSort);            
            system.debug('^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^');
      
        } catch(Exception e){
          system.debug('message'+e.getmessage());
          system.debug('message'+e.getLinenumber());          
        }
        
                /********************Shorting cards********************************/
        List<String> keys = new List<String>();
        List<String> keys1 = new List<String>();
        
        for(String key :MapAlgoChiefdataSort.keySet()){
            String sortKey =  MapAlgoChiefdataSort.get(key).Acuity+''+MapAlgoChiefdataSort.get(key).BestGuideLine+'~'+key;
            if(MapAlgoChiefdataSort.get(key).BestGuideLine){
                keys.add(MapAlgoChiefdataSort.get(key).Acuity+'a'+'~'+key);
            }else{
                keys1.add(sortKey);
            }
            System.debug('keys '+keys+' keys1 '+keys1);
            System.debug('Key: '+key+'Concept: '+MapAlgoChiefdataSort.get(key));
        }
        System.debug('>>>>>>>>>>>>>>. '+MapAlgoChiefdataSort);
        
        if(!OrderByFirstAcquity){
            keys.sort();
            keys1.sort();
            keys.addAll(keys1);                          
        } else {                        
            keys1.sort();
            keys.addAll(keys1);
            keys.sort();                       
        }
            Map<String,AlgoDetails> m = new Map<String,AlgoDetails>();
            for(integer i=0;i<keys.size();i++){
                String key = keys.get(i);           
                m.put(key.split('~')[1],MapAlgoChiefdataSort.get(key.split('~')[1]));           
            }
            MapAlgoChiefdataSort = new Map<String,AlgoDetails>();
            MapAlgoChiefdataSort.putAll(m);
        }
        system.debug('MapAlgoChiefdataSort++++++++++++++++++++++++++++++'+MapAlgoChiefdataSort);
        system.debug('<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< Exiting AlgomapforNLP');
        
        List<String> mapKeys1 =new List<String>(MapAlgoChiefdataSort.keySet());
        for(integer i=offset;i<mapKeys1.size();i++){
            String key = mapKeys1.get(i);
            if(mapAlgos.size()<11){
                mapAlgos.put(key,MapAlgoChiefdataSort.get(key));
            } else {
                break;
            }
        }
        
        /********************End Shorting cards********************************/
        
        return mapAlgos;       
    }   
    
    public void algotempData(){
        List<String> tempt;
        List<String> tempt1;
        List<String> tempt2;
        List<String> tempt3;
        List<String> tempt4;
        List<String> tempt5;
        List<String> tempt6;
        List<String> tempt7;
        List<String> tempt8;
        List<String> tempt9;
        List<String> tempt10;
        List<String> tempt11;
        List<String> tempt21;
        List<String> tempt22;
        List<String> tempt23;
        List<String> tempt24;
        List<String> tempt25;
        List<String> tempt26;
        List<String> tempt27;
        List<String> tempt28;
        List<String> tempt29;
        List<String> tempt210;
        List<String> tempt211;
        List<String> tempt31;
        List<String> tempt32;
        List<String> tempt33;
        List<String> tempt34;
        List<String> tempt35;
        List<String> tempt36;
        List<String> tempt37;
        List<String> tempt38;
        List<String> tempt39;
        List<String> tempt310;
        List<String> tempt311;
        List<String> tempt510;
        List<String> tempt511;
        List<String> tempt521;
        List<String> tempt522;
        List<String> tempt523;
        List<String> tempt524;
        List<String> tempt525;
        List<String> tempt526;
        List<String> tempt527;
        List<String> tempt528;
        List<String> tempt529;
        List<String> tempt5210;
        List<String> tempt5211;
        List<String> tempt531;
        List<String> tempt532;
        List<String> tempt533;
        List<String> tempt534;
        List<String> tempt535;
        List<String> tempt536;
        List<String> tempt537;
        List<String> tempt538;
        List<String> tempt539;
        List<String> tempt5310;
        List<String> tempt5311;
        List<String> atempt528;
        List<String> atempt529;
        List<String> atempt5210;
        List<String> atempt5211;
        List<String> atempt531;
        List<String> atempt532;
        List<String> atempt533;
        List<String> atempt534;
        List<String> atempt535;
        List<String> atempt536;
        List<String> atempt537;
        List<String> atempt538;
        List<String> atempt539;
        List<String> atempt5310;
        List<String> atempt5311;
        List<String> aatempt536;
        List<String> aatempt537;
        List<String> aatempt538;
        List<String> aatempt539;
        List<String> aatempt5310;
        List<String> aatempt5311;
        List<String> atempt;
        List<String> atempt1;
        List<String> atempt2;
        List<String> atempt3;
        List<String> atempt4;
        List<String> atempt5;
        List<String> atempt6;
        List<String> atempt7;
        List<String> atempt8;
        List<String> atempt9;
        List<String> atempt10;
        List<String> aatempt;
        List<String> aatempt1;
        List<String> aatempt2;
        List<String> aatempt3;
        List<String> aatempt4;
        List<String> aatempt5;
        List<String> aatempt6;
        List<String> aatempt7;
        List<String> aatempt8;
        List<String> aatempt9;
        List<String> aatempt10;
        
        tempt=new List<String>();
        tempt1=new List<String>();
        tempt2=new List<String>();
        tempt3=new List<String>();
        tempt4=new List<String>();
        tempt5=new List<String>();
        tempt6=new List<String>();
        tempt7=new List<String>();
        tempt8=new List<String>();
        tempt9=new List<String>();
        tempt10=new List<String>();
        tempt11=new List<String>();
        tempt2=new List<String>();
        tempt21=new List<String>();
        tempt22=new List<String>();
        tempt23=new List<String>();
        tempt24=new List<String>();
        tempt25=new List<String>();
        tempt26=new List<String>();
        tempt27=new List<String>();
        tempt28=new List<String>();
        tempt29=new List<String>();
        tempt210=new List<String>();
        tempt211=new List<String>();
        tempt31=new List<String>();
        tempt32=new List<String>();
        tempt33=new List<String>();
        tempt34=new List<String>();
        tempt35=new List<String>();
        tempt36=new List<String>();
        tempt37=new List<String>();
        tempt38=new List<String>();
        tempt39=new List<String>();
        tempt310=new List<String>();
        tempt311=new List<String>();
        tempt510=new List<String>();
        tempt511=new List<String>();
        tempt521=new List<String>();
        tempt522=new List<String>();
        tempt523=new List<String>();
        tempt524=new List<String>();
        tempt525=new List<String>();
        tempt526=new List<String>();
        tempt527=new List<String>();
        tempt528=new List<String>();
        tempt529=new List<String>();
        tempt5210=new List<String>();
        tempt5211=new List<String>();
        tempt531=new List<String>();
        tempt532=new List<String>();
        tempt533=new List<String>();
        tempt534=new List<String>();
        tempt535=new List<String>();
        tempt536=new List<String>();
        tempt537=new List<String>();
        tempt538=new List<String>();
        tempt539=new List<String>();
        tempt5310=new List<String>();
        tempt5311=new List<String>();
        atempt528=new List<String>();
        atempt529=new List<String>();
        atempt5210=new List<String>();
        atempt5211=new List<String>();
        atempt531=new List<String>();
        atempt532=new List<String>();
        atempt533=new List<String>();
        atempt534=new List<String>();
        atempt535=new List<String>();
        atempt536=new List<String>();
        atempt537=new List<String>();
        atempt538=new List<String>();
        atempt539=new List<String>();
        atempt5310=new List<String>();
        atempt5311=new List<String>();
        aatempt536=new List<String>();
        aatempt537=new List<String>();
        aatempt538=new List<String>();
        aatempt539=new List<String>();
        aatempt5310=new List<String>();
        aatempt5311=new List<String>();
        atempt=new List<String>();
        atempt1=new List<String>();
        atempt2=new List<String>();
        atempt3=new List<String>();
        atempt4=new List<String>();
        atempt5=new List<String>();
        atempt6=new List<String>();
        atempt7=new List<String>();
        atempt8=new List<String>();
        atempt9=new List<String>();
        atempt10=new List<String>();
        aatempt=new List<String>();
        aatempt1=new List<String>();
        aatempt2=new List<String>();
        aatempt3=new List<String>();
        aatempt4=new List<String>();
        aatempt5=new List<String>();
        aatempt6=new List<String>();
        aatempt7=new List<String>();
        aatempt8=new List<String>();
        aatempt9=new List<String>();
        aatempt10=new List<String>();
    }
    
    private static List<String> getTNDb(set<String> category, string versionyear, boolean Officehours){
        List<String> tempt;
        List<String> tempt1;
        List<String> tempt2;
        List<String> tempt3;
        List<String> tempt4;
        List<String> tempt5;
        List<String> tempt6;
        List<String> tempt7;
        List<String> tempt8;
        List<String> tempt9;
        List<String> tempt10;
        List<String> tempt11;
        System.debug('getTNDb>>>>>>>>>>>>>>>>>>>>>>>>');
        string APOH = 'Adult and Pediatric / OH';
        string AAH = 'Adult / AH';
        string PAH = 'Pediatric / AH';
        string Triagenowimport = '';
        tempt=new List<String>();
        tempt1=new List<String>();
        tempt2=new List<String>();
        tempt3=new List<String>();
        tempt4=new List<String>();
        tempt5=new List<String>();
        tempt6=new List<String>();
        tempt7=new List<String>();
        tempt8=new List<String>();
        tempt9=new List<String>();
        tempt10=new List<String>();
        tempt11=new List<String>();
        if(versionyear != null || versionyear != ''){
            Triagenowimport = 'Select id from TriageNow_Import_Database__c where Version_Year__c = \''+versionyear+'\' AND';
        }else{
            Triagenowimport = 'Select id from TriageNow_Import_Database__c where';
        }


        if(Officehours == true ){
             Triagenowimport += ' Db_Alias__c = \'' +APOH+ '\'';            
        }else if(Officehours == false){
            list<string> ss = new List<string>();
            ss.add(AAH);
            ss.add(PAH);
            Triagenowimport += ' Db_Alias__c IN : ss';   
        }

        system.debug(Triagenowimport);

        List<TriageNow_Import_Database__c> TriagenowimportIDS  = database.query(Triagenowimport);
        system.debug('TriagenowimportIDS'+TriagenowimportIDS);

        //convert it into string 
        List<string> TNDb = new list<string>();
        for(TriageNow_Import_Database__c tt : TriagenowimportIDS){
             TNDb.add(string.valueof(tt.get('id'))); 
        }
        System.debug('<<<<<<<<<<<<<<<<<<<<<<<<<getTNDb: '+TNDb);
        return TNDb;
    }
    
    
}