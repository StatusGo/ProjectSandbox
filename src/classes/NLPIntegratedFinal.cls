global class NLPIntegratedFinal 
{
     
        //Age will give you age
        //catagory will give me adult/pediatric
        //office hours: in offcie or not in offce
        //gender will give you gender       
       //this class is used to discover the TNimport databse
            
        
    webService static string Symptoms(string Symptom,integer Age,Boolean Officehours,string Gender,Boolean SpecificAlgoID,date birthdate){        
     
     if(Symptom!= null){     
    
          system.debug('Age'+Age);
           system.debug('Officehours'+Officehours);
                system.debug('Gender'+Gender);
       //check if algoid is send appropriately.
         
         string catagory;
            if(Age >= 0 && Age <= 21){              
              catagory = 'Pediatric';                          
            }else if(Age > 21 && Age <= 120){
              catagory = 'Adult';              
            }     
         //to bring all the 
            string APOH = 'Adult and Pediatric / OH';
            string AAH = 'Adult / AH';
            string PAH = 'Pediatric / AH';
            string Triagenowimport = 'Select id from TriageNow_Import_Database__c where';
            
            
            if(Officehours == true ){
                 Triagenowimport += ' Db_Alias__c = \'' +APOH+ '\'';            
            }else if(Officehours == false && catagory == 'Adult') {
                 Triagenowimport += ' Db_Alias__c = \'' +AAH+ '\'';           
            }else if(Officehours == false && catagory == 'Pediatric'){
                 Triagenowimport += ' Db_Alias__c = \'' +PAH + '\'';         
            } 
            system.debug(Triagenowimport);

            TriageNow_Import_Database__c TriagenowimportIDS  = database.query(Triagenowimport);
            system.debug('TriagenowimportIDS'+TriagenowimportIDS);

            //convert it into string 
            string TNDb = string.valueof(TriagenowimportIDS.get('id')); 
      
          string result;
          if(Symptom.startsWith('~')){
            string sympt = Symptom.remove('~');
              result = ChiefComplains(sympt,Officehours,TNDb,Gender,catagory,birthdate);        
           }
            else{
            
            if(SpecificAlgoID == true){
                  String symptoms = Symptom;  
                WrapperForAlgorithCards Wrappp = new WrapperForAlgorithCards();
                Wrappp = Algomap(symptoms,catagory,Age,Gender,TNDb);
                //Wrappp.Error = 'Success';
                result = JSON.Serialize(Wrappp);
                    
            }
            else{
                returnWrapperObject Wrapobj = new returnWrapperObject();  
                Wrapobj  = AdditionalDetails(Symptom,catagory,Age,Gender,TNDb);
                Wrapobj.Error = 'Success';
                result = JSON.Serialize(Wrapobj);
            }          

            }
             return result ;

           } 

            else{
             returnWrapperObject Wrapobja = new returnWrapperObject();  
              Wrapobja.Error ='Please Type a Search Keyword';
              return Wrapobja.Error;
            }           
    }
  
        //Age will give you age
        //catagory will give me adult/pediatric
        //office hours in offcie or not in offce
        //gender will give you gender

    webService static WrapperForAlgorithCards Algomap(string symptoms,string catagory,integer Age,string Gender, string TNDb){
             WrapperForAlgorithCards ConsolidatedObjRetObj = new WrapperForAlgorithCards();
             
    try{     
          ConsolidatedObjRetObj.ALgorithm = new List<AlgoreturnVal>();
        

          string IsActive = 'Active'; //check active records only


     List<TriageNow_AlgorithmSearchWord__c> ALgosearchword = [SELECT AD_AlgorithmID__c
                                                              FROM TriageNow_AlgorithmSearchWord__c
                                                               WHERE AD_SearchWord__c =: symptoms
                                                               AND TriageNow_Import_Database__c =:TNDb];  

      
      System.debug('@@@@@AlgorithmID__cnoYT USED :'+ALgosearchword);

           
           //this is use to ceck for the Acerss IDS                                                  
      List<String> AcessAlgoID = new List<string>();
       for(TriageNow_AlgorithmSearchWord__c AcesAlgo : ALgosearchword){
        AcessAlgoID.add(AcesAlgo.AD_AlgorithmID__c);
       }                                                       
         system.debug('All the algorithm ids form ALGO SEARCH TABLE'+AcessAlgoID);
         system.debug('^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^');
     
    string category = '%'+catagory+'%';   
    String Genderr = '\''+Gender+'\'';
    Set<String> genders = new Set<String>();
    if(Gender != null && Gender != '') {
        genders.add(Gender);
    }
    genders.add('B');
    System.debug('IsActive '+IsActive);
    System.debug('category '+category);
    System.debug('TNDb '+TNDb);
    System.debug('Gender '+Gender);

     List<TriageNow_Algorithm__c> ALgorithm1 = [ SELECT AlgorithmID__c,BackgroundXHTML__c,Copyright__c,DefinitionXHTML__c,FirstAidXHTML__c,Id,
                                                  InitialAssessmentQuestions__c,Title__c,Category__c,Group__c,Type__c,System__c,Anatomy__c,
                                                  VersionYear__c,Status__c,SnoMedCode__c,ICD9Code__c,Acuity__c,Gender__c,Max_Age_Months__c,
                                                  Max_Age_Years__c,Min_Age_Months__c,Min_Age_Years__c,Prescription_Option__c 
                                                  FROM TriageNow_Algorithm__c 
                                                  WHERE AlgorithmID__c IN : AcessAlgoID
                                                  AND Status__c =: IsActive
                                                  AND category__c like : category
                                                  AND TriageNow_Import_Database__c =:TNDb
                                                  AND Gender__c like : genders                                                   
                                                  Order by Acuity__c ASC ];

      system.debug('ALgorith Value form ALGORITHM OBJECT'+ALgorithm1);
      system.debug('***************************************');

      //These IDS would be used for referencing all the Other tables according to the Triage now import database
      List<string> AccessAlgoIds = new List<string>();
        for(TriageNow_Algorithm__c algo : ALgorithm1){
          AccessAlgoIds.add(algo.AlgorithmID__c);
        }    

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
       return ConsolidatedObjRetObj;
    }




webService static returnWrapperObject AdditionalDetails(string AlgorithmID,string catagory,integer Age,string Gender,string TNDb){
    returnWrapperObject ConsolidatedObj = new returnWrapperObject();
    try{          
         ConsolidatedObj.ALgorithm = new List<AlgoreturnVal>(); 
         ConsolidatedObj.Reference = new  List<AlgoreferencerretVal>();
         ConsolidatedObj.QuestionAdvice  = new List<QuestionAdvice>();
         ConsolidatedObj.Supplement = new List<Supplement>();
         ConsolidatedObj.RelatedACI = new List<RelatedACI>();
         ConsolidatedObj.Question = new List<Question>();
         ConsolidatedObj.Smaglinks = new List<Smaglink>();
            
 string IsActive = 'Active'; //check active records only    
    
         string category = '%'+catagory+'%';   
    String Genderr = '\''+Gender+'\'';
    Set<String> genders = new Set<String>();
    if(Gender != null && Gender != '') {
        genders.add(Gender);
    }
    genders.add('B');
    System.debug('IsActive '+IsActive);
    System.debug('category '+category);
    System.debug('TNDb '+TNDb);
    System.debug('Gender '+Gender);

     List<TriageNow_Algorithm__c> ALgorithm1 = [ SELECT AlgorithmID__c,BackgroundXHTML__c,Copyright__c,DefinitionXHTML__c,FirstAidXHTML__c,Id,
                                                  InitialAssessmentQuestions__c,Title__c,Category__c,Group__c,Type__c,System__c,Anatomy__c,
                                                  VersionYear__c,Status__c,SnoMedCode__c,ICD9Code__c,Acuity__c,Gender__c,Max_Age_Months__c,
                                                  Max_Age_Years__c,Min_Age_Months__c,Min_Age_Years__c,Prescription_Option__c 
                                                  FROM TriageNow_Algorithm__c 
                                                  WHERE AlgorithmID__c = : AlgorithmID
                                                  AND Status__c =: IsActive
                                                  AND category__c like : category
                                                  AND TriageNow_Import_Database__c =:TNDb
                                                  AND Gender__c like : genders                                                   
                                                  Order by Acuity__c ASC ];

      system.debug('ALgorith Value form ALGORITHM OBJECT'+ALgorithm1);
      system.debug('***************************************');

      //These IDS would be used for referencing all the Other tables according to the Triage now import database
      List<string> AccessAlgoIds = new List<string>();
        for(TriageNow_Algorithm__c algo : ALgorithm1){
          AccessAlgoIds.add(algo.AlgorithmID__c);
        }    

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
                                                                      AND TriageNow_Import_Database__c =:TNDb];     

              System.debug('REferences from ALGORITHM REFERENCE : '+Algoreference);
              system.debug('***************************************');                             

              for(TriageNow_AlgorithmReference__c ref : Algoreference){
                  AlgoreferencerretVal RefValList = new  AlgoreferencerretVal();

                    RefValList.PubMedURL = ref.ReferenceID__r.PubMedURL__c;
                    RefValList.ReferenceAuthor = ref.ReferenceID__r.ReferenceAuthor__c;
                    RefValList.ReferenceSource = ref.ReferenceID__r.ReferenceSource__c;
                    RefValList.ReferenceTitle = ref.ReferenceID__r.ReferenceTitle__c;    
                    RefValList.RefALgoID = ref.AD_AlgorithmID__c;        

                   // ConsolidatedObj.Reference.add(RefValList);
              }

             //system.debug('ConsolidatedObj.Reference'+ConsolidatedObj.Reference);


              List<TriageNow_Question__c> Question =  [SELECT AD_AlgorithmID__c,AD_DispositionLevel__c,DispositionLevel__r.levelid__c,AlgorithmID__c,CMS__c,DispositionLevel__r.DispositionHeading__c,
                                                       Id,Information__c,Name,QuestionID__c,QuestionOrder__c,Question__c,
                                                       SMAG_LINK_ID__c,TriageNow_Import_Database__c
                                                       FROM TriageNow_Question__c
                                                       WHERE AD_AlgorithmID__c = : AlgorithmID
                                                        AND TriageNow_Import_Database__c =:TNDb
                                                        Order by DispositionLevel__r.levelid__c DESC , QuestionOrder__c ASC];

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
              List<string> smag = new List<string>();
              for(TriageNow_Question__c QUSIDS : Question){
                smag.add(string.valueof(QUSIDS.SMAG_LINK_ID__c));
              }  
 
               List<TriageNow_Algorithm__c> Smaglinks = [SELECT AlgorithmID__c,Title__c 
                                                  FROM TriageNow_Algorithm__c 
                                                  WHERE AlgorithmID__c IN : smag
                                                  AND Status__c =: IsActive
                                                  AND category__c like : category
                                                  AND TriageNow_Import_Database__c =:TNDb
                                                  AND Gender__c like : genders                                                   
                                                  Order by Acuity__c ASC ];


              for(TriageNow_Algorithm__c Smagll : Smaglinks){
                  SmagLink ss = new SmagLink();
                  ss.Algoid = Smagll.AlgorithmID__c;
                  ss.Title = Smagll.Title__c;
                  ConsolidatedObj.Smaglinks.add(ss);
              }                                    

//------------

              System.debug('ONLY QUESTION IDS : '+Qusid);
              system.debug('^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^');

             List<TriageNow_QuestionAdvice__c> QuestionAndAdvice = [SELECT AdviceID__r.Advice__c,AdviceID__r.Advice_XHTML__c,AD_AdviceID__c,AD_QuestionID__c,QuestionAdviceOrder__c
                                                                    ,QuestionID__c,TriageNow_Import_Database__c
                                                                    FROM TriageNow_QuestionAdvice__c
                                                                    WHERE AD_QuestionID__c IN : Qusid
                                                                     AND TriageNow_Import_Database__c =:TNDb];

             system.debug('GET ADvices fron QUEStion IDS object TRIAGE QUSTION ADVICE'+QuestionAndAdvice);
             system.debug('***************************************');                                                          

             for(TriageNow_QuestionAdvice__c qusad : QuestionAndAdvice){             
                QuestionAdvice Qusadv  = new QuestionAdvice();
                Qusadv.QusID = qusad.AD_QuestionID__c;
                Qusadv.Advice = qusad.AdviceID__r.Advice_XHTML__c;   
           /*     if(Qusadv.Advice != null || Qusadv.Advice.length() < 1){
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
                                                                       AND TriageNow_Import_Database__c =:TNDb ];


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

            string pACI = 'Pediatric / ACI';
            string aACI = 'Adult / ACI';
            if(Catagory == 'Pediatric'){
              TriagenowimportforACI += ' Db_Alias__c = \'' +pACI+ '\'';   
              }else if(Catagory == 'Adult'){
                TriagenowimportforACI += ' Db_Alias__c = \'' +aACI+ '\'';   
              }
            
            //system.debug('TriagenowimportforACI'+TriagenowimportforACI);            

            TriageNow_Import_Database__c TNDbACI = database.query(TriagenowimportforACI);

            //system.debug('TNDbACI'+TNDbACI);

             string Tnndb = string.valueof(TNDbACI.get('Id'));

             system.debug('Get after care advice IDS'+Tnndb);


              

///this is for Related ACi
              List<TriageNow_RelatedACI__c> RelatedACI = [SELECT AD_AlgorithmID__c,AlgorithmID__c,HealthInfoTopicID__c,Name
                                                          ,Temp__c,TriageNow_Import_Database__c
                                                          FROM TriageNow_RelatedACI__c
                                                          WHERE AD_AlgorithmID__c = : AlgorithmID 
                                                          AND TriageNow_Import_Database__c  =: TNDb ]; 

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
                                                              AND TriageNow_Import_Database__c  =: Tnndb];                          

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
    }
     
     global class returnWrapperObject{
       
        webService String Error{get;set;}       
        webService List<AlgoreturnVal> ALgorithm{get;set;}       
        webService List<AlgoreferencerretVal> Reference{get;set;} 
        webService List<QuestionAdvice> QuestionAdvice{get;set;} 
        webService List<Question> Question{get;set;} 
        webService List<Supplement> Supplement{get;set;}
        webService List<RelatedACI> RelatedACI{get;set;}
        webservice List<SmagLink> Smaglinks{get;set;}

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

      Webservice string Algoid{get;set;}
      Webservice string Title{get;set;}
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


    global class RelatedACI{
        webservice string RelatedAciAlgoID{get;set;}
        webservice string Title{get;set;}
        webservice string Definition{get;set;} 
        webservice string Advice{get;set;}
        webservice string Hiall{get;set;}
        webservice string CallBack{get;set;}
    }

///-------------------------------------------------------------------------------------NLP Section----------------------------------------------------------

    global class WrapNLP{
          webService List<string> conceptID{get;set;}
          webService List<string> ICD10{get;set;}

          public WrapNLP(){
               conceptID = new List<string>(); 
               ICD10 = new List<string>(); 
          }
    }


  
  webService static string ChiefComplains(string symptom,boolean Officehours,string TNDb,string Gender,string catagory,date birthdate)
    {
       string resr; 
        try{    

        NLP_Settings__c nlp = NLP_Settings__c.getInstance('NLP');       
        String url = nlp.URL__c;
        String token = nlp.Securitytoken__c;

       // url ='http://healthnavdevapi.azurewebsites.net/V1/';  
        string newurl = url +'FindCccByPopulation?freetextchiefcomplaints='+symptom+'&birthdate='+birthdate+'&gender='+Gender;
        http ht = new http();       
        httprequest req = new httprequest();  
        httpresponse res = new httpresponse();
        req.setEndpoint(newurl);
        req.setMethod('GET');
        req.setHeader('Content-Type', 'application/JSON');          
        
       // string token = '92F3614C-CAE0-4CE3-B9DC-45E988187818:9070026A-D086-4FAF-8A37-2448E3554DD3';                 
        req.setTimeout(60000);
        system.debug('req.getEndpoint'+req.getEndpoint());         
        
        
        Blob headerValue = Blob.valueOf(token);
    system.debug('headerValue'+headerValue);        
      String authorizationHeader = 'Basic ' +EncodingUtil.base64Encode(headerValue);
        system.debug('authorizationHeader'+authorizationHeader);    
       
        
      req.setHeader('Authorization', authorizationHeader);    
            req.setHeader('Connection','keep-alive');
         try {             
              res = ht.send(req);     
             system.debug('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@res'+res);
           
          }
          catch(System.CalloutException e)
            {
              System.debug('Callout error: '+ e);
              System.debug(res.toString());
          }
        
        //system.debug('ht.send(req)'+ht.send(req));
        
        system.debug('status'+res.getStatus());
        string jsondata = res.getBody();
        res.getStatus();
        system.debug('body'+res.getBody());                
        system.debug('jsondata + jsondata'+jsondata);
      
             
          if(jsondata!= null){                        
            resr = Getjsondata(jsondata,Officehours,TNDb,Gender,catagory);
          }else{

            system.debug('No data present');
          }
 
        }catch(CalloutException ee){
            ee.getCause();
            ee.getLineNumber();
            ee.getMessage();           
            
        }
       return resr;
    }     
   



 
    webService static string Getjsondata(string jsondata,boolean Officehours,string TNDb,string gender,string catagory){
        string result;
        try{         
            // parse coordinates from response
            JSONParser parser = JSON.createParser(jsondata);            
       WrapNLP nlpWrapper = new WrapNLP();
           
            while (parser.nextToken() != null) {
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) &&
                    (parser.getText() == 'ConceptId')){
                       parser.nextToken(); // object start
                       nlpWrapper.conceptID.add(string.valueof(parser.getIntegerValue()));
                       system.debug('conceptID '+nlpWrapper.conceptID );
                }
          
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) &&
                    (parser.getText() == 'ICD10')){
                       parser.nextToken(); // object start
                       nlpWrapper.ICD10.add(parser.gettext());
                       system.debug('ICD10 '+nlpWrapper.ICD10 );
                }
            }

//to bring the data according to offcie hours or after hours
            
            if(Officehours){

                 List<TriageNow_Concept__c> ConceptWord = [SELECT Title__c
                                                           FROM TriageNow_Concept__c 
                                                           WHERE  ConceptID__c IN: nlpWrapper.conceptID
                                                           AND TriageNow_Import_Database__c =: TNDb];

                 List<string> conceptid = new List<string>(); 
                 for(TriageNow_Concept__c tc : ConceptWord){
                      conceptid.add(tc.Title__c);
                 }                                         

                 List<TriageNow_AlgorithmSearchWord__c> ALgosearchword = [SELECT AD_AlgorithmID__c
                                                                          FROM TriageNow_AlgorithmSearchWord__c
                                                                           WHERE AD_SearchWord__c IN: conceptid
                                                                           AND TriageNow_Import_Database__c =:TNDb];  

      
                   System.debug('@@@@@AlgorithmID__cnoYT NLP NLP NLP :'+ALgosearchword);

           
           //this is use to ceck for the Acerss IDS                                                  
            List<String> AcessAlgoID = new List<string>();
                  for(TriageNow_AlgorithmSearchWord__c AcesAlgo : ALgosearchword){
                              AcessAlgoID.add(AcesAlgo.AD_AlgorithmID__c);
                  }                                                       
                system.debug('All the algorithm ids form ALGO SEARCH TABLE'+AcessAlgoID);                                          
             
             result = AlgomapforNLP(AcessAlgoID,catagory,gender,TNDb);              
            }
            else{

                    List<TriageNow_AlgorithmCCC__c> AlgoCCC = [SELECT AD_AlgorithmID__c
                                                               FROM TriageNow_AlgorithmCCC__c 
                                                               where AD_ConceptID__c IN: nlpWrapper.conceptID
                                                               AND TriageNow_Import_Database__c =:TNDb];

              List<String> AcessAlgoIDssss = new List<string>();
                  for(TriageNow_AlgorithmCCC__c AcesAlgo : AlgoCCC){
                              AcessAlgoIDssss.add(AcesAlgo.AD_AlgorithmID__c);
                  }                                                       
                    system.debug('All the algorithm ids form ALGO SEARCH TABLE'+AcessAlgoIDssss);                                          
             
                 result = AlgomapforNLP(AcessAlgoIDssss,catagory,gender,TNDb);                                                          

                 }    


           

        } catch (Exception e) {
                system.debug('e.getCause();'+e.getCause());
                system.debug('e.getMessage()'+e.getMessage());                
        }
        return result;   
 }
        


  webService static string AlgomapforNLP(List<string> AlgoID,string catagory,string Gender, string TNDb){
             WrapperForAlgorithCards ConsolidatedObjRetObj = new WrapperForAlgorithCards();
             
    try{     
          ConsolidatedObjRetObj.ALgorithm = new List<AlgoreturnVal>();
        

          string IsActive = 'Active'; //check active records only


    
         system.debug('^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^');
     
    string category = '%'+catagory+'%';   
    String Genderr = '\''+Gender+'\'';
    Set<String> genders = new Set<String>();
    if(Gender != null && Gender != '') {
        genders.add(Gender);
    }
    genders.add('B');
    System.debug('IsActive '+IsActive);
    System.debug('category '+category);
    System.debug('TNDb '+TNDb);
    System.debug('Gender '+Gender);

     List<TriageNow_Algorithm__c> ALgorithm1 = [ SELECT AlgorithmID__c,BackgroundXHTML__c,Copyright__c,DefinitionXHTML__c,FirstAidXHTML__c,Id,
                                                  InitialAssessmentQuestions__c,Title__c,Category__c,Group__c,Type__c,System__c,Anatomy__c,
                                                  VersionYear__c,Status__c,SnoMedCode__c,ICD9Code__c,Acuity__c,Gender__c,Max_Age_Months__c,
                                                  Max_Age_Years__c,Min_Age_Months__c,Min_Age_Years__c,Prescription_Option__c 
                                                  FROM TriageNow_Algorithm__c 
                                                  WHERE AlgorithmID__c IN : AlgoID
                                                  AND Status__c =: IsActive
                                                  AND category__c like : category
                                                  AND TriageNow_Import_Database__c =:TNDb
                                                  AND Gender__c like : genders                                                   
                                                  Order by Acuity__c ASC ];

      system.debug('ALgorith Value form ALGORITHM OBJECT'+ALgorithm1);
      system.debug('***************************************');

      //These IDS would be used for referencing all the Other tables according to the Triage now import database
      List<string> AccessAlgoIds = new List<string>();
        for(TriageNow_Algorithm__c algo : ALgorithm1){
          AccessAlgoIds.add(algo.AlgorithmID__c);
        }    

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
       string resultfinal = JSON.Serialize(ConsolidatedObjRetObj);
        return resultfinal;
       
    }


///-------------------------------------------------------------------------------------NLP Section----------------------------------------------------------    


}