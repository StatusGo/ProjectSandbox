@isTest(SeeAllData = true)
public class KeywordSearchWSDlTest1{
     public static testMethod void UnitTest() {
        Account acct = new Account();
        acct.Name = 'testAccount';
         //acct.Adult_AH_Content_Enabled__c = true;
        acct.Adult_OH_Content_Enabled__c = true;
        acct.Pediatric_AH_Content_Enabled__c = true;
        acct.Pediatric_OH_Content_Enabled__c = true;
        acct.NLP_Enabled__c = true;
        insert acct;
         List<String> testString = new List<String>();

         string test3 = 'Cancer';
         string test1 = 'Fever';
         String algoId = '444';
         String test2 = '~Fever';
         String test4 = '~Earache';
         String testt = 'A';
         testString.add(test2);
         testString.add(test4);
         testString.add(test3);
        

        TriageNow_Import_Database__c tndbAPOH = [select id from TriageNow_Import_Database__c where Db_Alias__c = 'Adult and Pediatric / OH'];
        TriageNow_Import_Database__c tndbAAH = [select id from TriageNow_Import_Database__c where Db_Alias__c = 'Adult / AH'];
        TriageNow_Import_Database__c tndbAACI = [select id from TriageNow_Import_Database__c where Db_Alias__c = 'Adult / ACI'];
        

         KeywordSearchWSDl1 ss= new KeywordSearchWSDl1();         
         KeywordSearchWSDl1.returnWrapperObject wrap = new KeywordSearchWSDl1.returnWrapperObject();

         KeywordSearchWSDl1.AlgoreturnVal algo = new KeywordSearchWSDl1.AlgoreturnVal();        
         KeywordSearchWSDl1.QuestionAdvice qAdvice = new KeywordSearchWSDl1.QuestionAdvice();
         KeywordSearchWSDl1.AlgoreferencerretVal Algoreference = new KeywordSearchWSDl1.AlgoreferencerretVal();         
         KeywordSearchWSDl1.Supplement supp= new KeywordSearchWSDl1.Supplement();
         KeywordSearchWSDl1.RelatedACI aci = new  KeywordSearchWSDl1.RelatedACI();
         KeywordSearchWSDl1.SmagLink   tthhtt = new KeywordSearchWSDl1.SmagLink();
         KeywordSearchWSDl1.Question qas = new KeywordSearchWSDl1.Question();
        // KeywordSearchWSDl1.Question ddv=new KeywordSearchWSDl1.Question
        
      //   KeywordSearchWSDl1.WrapHelthInfoTopic wraphealth = new KeywordSearchWSDl1.WrapHelthInfoTopic();

          KeywordSearchWSDl1.returnWrapperObject wrap1 = new KeywordSearchWSDl1.returnWrapperObject();
          KeywordSearchWSDl1.returnWrapperObject wrap2 = new KeywordSearchWSDl1.returnWrapperObject();
          KeywordSearchWSDl1.returnWrapperObject wrap3 = new KeywordSearchWSDl1.returnWrapperObject();
          KeywordSearchWSDl1.returnWrapperObject wrap4 = new KeywordSearchWSDl1.returnWrapperObject();
          KeywordSearchWSDl1.returnWrapperObject wrap5 = new KeywordSearchWSDl1.returnWrapperObject();
          KeywordSearchWSDl1.returnWrapperObject wrap6 = new KeywordSearchWSDl1.returnWrapperObject();
          KeywordSearchWSDl1.returnWrapperObject wrap7 = new KeywordSearchWSDl1.returnWrapperObject();
          
        
         KeywordSearchWSDl1.CustomerInetractionWrapperObject ciObj = new KeywordSearchWSDl1.CustomerInetractionWrapperObject();
         ciObj.AccountId = acct.Id;
         ciObj.patientCity ='testCity';
         ciObj.patientDOB = Date.today();
         ciObj.patientGender = 'M';
         ciObj.patientState = 'testState';
         ciObj.patientWeightLbs = 124;
         ciObj.patientPostalCode ='23934';
         ciObj.relationshipTopatient='Aunt';
         ciObj.searchBy = 'Protocol Title/Keyword';
         ciObj.searchText = 'fever';
         ciObj.userEmail = 'test@test.com';
         ciObj.userId = 'xyz';
         ciObj.userName = 'xyz';
         
         String jsonString = JSON.serialize(ciObj);

             TriageNow_SearchWord__c tsa = new TriageNow_SearchWord__c();
              tsa.ConceptTitle__c ='test3';
              tsa.SearchWord__c = test3; //cough
              tsa.Searchword_Type__c = 'test3';
              tsa.TriageNow_Import_Database__c = tndbAPOH.id;
              insert tsa;

              TriageNow_Algorithm__c ttqq = new TriageNow_Algorithm__c();
              ttqq.Title__c = 'A';
              ttqq.Status__c = 'Active';
              ttqq.category__c = 'Adult';
              ttqq.TriageNow_Import_Database__c = tndbAPOH.id;
              ttqq.Gender__c = 'M';
              insert ttqq;

 
              
              TriageNow_SearchWord__c tsaa = new TriageNow_SearchWord__c();
              tsaa.ConceptTitle__c ='test3';              
              tsaa.SearchWord__c = testt; //cough
              tsaa.Searchword_Type__c = 'test3';
              tsaa.TriageNow_Import_Database__c = tndbAPOH.id;
              insert tsaa;

              TriageNow_SearchWord__c tsaah = new TriageNow_SearchWord__c();
              tsaah.ConceptTitle__c ='test3a';
              tsaah.SearchWord__c = test1; //cough
              tsaah.Searchword_Type__c = 'test3a';
              tsaah.TriageNow_Import_Database__c = tndbAAH.id;
              insert tsaah;

         TriageNow_AlgorithmSearchWord__c algosearch = new TriageNow_AlgorithmSearchWord__c();
         algosearch.SearchWord__c = tsa.id;               
         algosearch.TriageNow_Import_Database__c = tndbAPOH.id;
         insert algosearch;

         TriageNow_AlgorithmSearchWord__c algosearchh = new TriageNow_AlgorithmSearchWord__c();
         algosearchh.SearchWord__c = tsaa.id;         
         algosearchh.TriageNow_Import_Database__c = tndbAPOH.id;
         insert algosearchh;
         
         TriageNow_AlgorithmSearchWord__c algosearchah = new TriageNow_AlgorithmSearchWord__c();
         algosearchah.SearchWord__c = tsaah.id;
         algosearchah.TriageNow_Import_Database__c = tndbAAH.id;
         insert algosearchah;

        TriageNow_Disposition__c dd = new TriageNow_Disposition__c();
        dd.Hospice__c = true;
        dd.TriageNow_Import_Database__c = tndbAPOH.id;
        dd.LevelID__c = 100;
        insert dd;

         TriageNow_Algorithm__c ta = new TriageNow_Algorithm__c();
         ta.Acuity__c = 1;
         ta.category__c = 'adult';
         //ta.Group__c = 'after';
         ta.Gender__c = 'M';
         ta.AlgorithmID__c = algosearch.AD_AlgorithmID__c;
         ta.BackgroundXHTML__c = 'testback';
         ta.Copyright__c = 'testback';
         ta.DefinitionXHTML__c = 'testback';
         ta.FirstAidXHTML__c = 'testback';
         ta.ICD9Code__c = 'testback';
         ta.InitialAssessmentQuestions__c= 'testback';
         ta.Title__c = test3;
         ta.Status__c = 'Active';
         ta.TriageNow_Import_Database__c = tndbAPOH.id;         
         insert ta;//oH = open

         TriageNow_Algorithm__c ta3 = new TriageNow_Algorithm__c();
         ta3.Acuity__c = 1;
         ta3.category__c = 'adult';
         //ta.Group__c = 'after';
         ta3.Gender__c = 'M';
         ta3.AlgorithmID__c = algosearch.AD_AlgorithmID__c;
         ta3.BackgroundXHTML__c = 'testback';
         ta3.Copyright__c = 'testback';
         ta3.DefinitionXHTML__c = 'testback';
         ta3.FirstAidXHTML__c = 'testback';
         ta3.ICD9Code__c = 'testback';
         ta3.InitialAssessmentQuestions__c= 'testback';
         ta3.Title__c = test1;
         ta3.Status__c = 'Active';
         ta3.TriageNow_Import_Database__c = tndbAPOH.id;         
         insert ta3;

         
         TriageNow_Algorithm__c ta4 = new TriageNow_Algorithm__c();
         ta4.Acuity__c = 1;
         ta4.category__c = 'adult';
         //ta.Group__c = 'after';
         ta4.Gender__c = 'M';
         ta4.AlgorithmID__c = test3;
         ta4.BackgroundXHTML__c = 'testback';
         ta4.Copyright__c = 'testback';
         ta4.DefinitionXHTML__c = 'testback';
         ta4.FirstAidXHTML__c = 'testback';
         ta4.ICD9Code__c = 'testback';
         ta4.InitialAssessmentQuestions__c= 'testback';
         ta4.Title__c = test1;
         ta4.Status__c = 'Active';
         ta4.TriageNow_Import_Database__c = tndbAPOH.id;         
         insert ta4;
             
 
 
         TriageNow_Algorithm__c taah = new TriageNow_Algorithm__c();
         taah.Acuity__c = 1;
         taah.category__c = 'adult';
         //ta.Group__c = 'after';
         taah.Gender__c = 'M';
         taah.AlgorithmID__c = algosearchah.AD_AlgorithmID__c;
         taah.BackgroundXHTML__c = 'testback';
         taah.Copyright__c = 'testback';
         taah.DefinitionXHTML__c = 'testback';
         taah.FirstAidXHTML__c = 'testback';
         taah.ICD9Code__c = 'testback';
         taah.InitialAssessmentQuestions__c= 'testback';
         taah.Title__c = test3;
         taah.Status__c = 'Active';
         taah.TriageNow_Import_Database__c = tndbAAH.id;         
         insert taah;//oH = open

         TriageNow_Algorithm__c ta3ah = new TriageNow_Algorithm__c();
         ta3ah.Acuity__c = 1;
         ta3ah.category__c = 'adult';
         //ta.Group__c = 'after';
         ta3ah.Gender__c = 'M';
         ta3ah.AlgorithmID__c = algosearchah.AD_AlgorithmID__c;
         ta3ah.BackgroundXHTML__c = 'testback';
         ta3ah.Copyright__c = 'testback';
         ta3ah.DefinitionXHTML__c = 'testback';
         ta3ah.FirstAidXHTML__c = 'testback';
         ta3ah.ICD9Code__c = 'testback';
         ta3ah.InitialAssessmentQuestions__c= 'testback';
         ta3ah.Title__c = test1;
         ta3ah.Status__c = 'Active';
         ta3ah.TriageNow_Import_Database__c = tndbAAH.id;         
         insert ta3ah;

         TriageNow_Algorithm__c ta4ah = new TriageNow_Algorithm__c();
         ta4ah.Acuity__c = 1;
         ta4ah.category__c = 'adult';
         //ta.Group__c = 'after';
         ta4ah.Gender__c = 'M';
         ta4ah.AlgorithmID__c = test1;
         ta4ah.BackgroundXHTML__c = 'testback';
         ta4ah.Copyright__c = 'testback';
         ta4ah.DefinitionXHTML__c = 'testback';
         ta4ah.FirstAidXHTML__c = 'testback';
         ta4ah.ICD9Code__c = 'testback';
         ta4ah.InitialAssessmentQuestions__c= 'testback';
         ta4ah.Title__c = test1;
         ta4ah.Status__c = 'Active';
         ta4ah.TriageNow_Import_Database__c = tndbAAH.id;         
         insert ta4ah;
         
          TriageNow_AlgorithmSearchWord__c tt = new TriageNow_AlgorithmSearchWord__c();
          //tt.AD_AlgorithmID__c = '555';
          //tt.AD_SearchWord__c  = 'test';
          tt.AlgorithmID__c = ta3.id;
          tt.SearchWord__c = tsa.id;
          tt.TriageNow_Import_Database__c = tndbAPOH.id;
           insert tt;   

          TriageNow_AlgorithmSearchWord__c ttah = new TriageNow_AlgorithmSearchWord__c();
          //tt.AD_AlgorithmID__c = '555';
          //tt.AD_SearchWord__c  = 'test';
          ttah.AlgorithmID__c = ta3ah.id;
          ttah.SearchWord__c = tsaah.id;
          ttah.TriageNow_Import_Database__c = tndbAAH.id;
          insert ttah; 
           
          TriageNow_Concept__c cc = new TriageNow_Concept__c();
          cc.TriageNow_Import_Database__c = tndbAPOH.id;
          cc.Title__c = test3;
          insert cc;
          
          TriageNow_Concept__c ccah = new TriageNow_Concept__c();
          ccah.TriageNow_Import_Database__c = tndbAAH.id;
          ccah.Title__c = test1;
          ccah.ConceptID__c =  test1;
          insert ccah;
 
          TriageNow_AlgorithmCCC__c algoCCC = new TriageNow_AlgorithmCCC__c();
         
          algoCCC.ConceptID__c = cc.id;
          algoCCC.AlgorithmID__c = ta.id;
          algoCCC.TriageNow_Import_Database__c = tndbAPOH.id;
          insert algoCCC;
          
          TriageNow_AlgorithmCCC__c algoCCCah = new TriageNow_AlgorithmCCC__c();
          algoCCCah.ConceptID__c = ccah.id;
          algoCCCah.AlgorithmID__c = taah.id;
          algoCCCah.TriageNow_Import_Database__c = tndbAAH.id;
          insert algoCCCah;
          
         TriageNow_Reference__c ref = new TriageNow_Reference__c();
         ref.TriageNow_Import_Database__c = tndbAPOH.id;
         insert ref;
         
         TriageNow_Reference__c refah = new TriageNow_Reference__c();
         refah.TriageNow_Import_Database__c = tndbAAH.id;
         insert refah;
         
         TriageNow_AlgorithmReference__c algoRef = new TriageNow_AlgorithmReference__c();
         algoRef.TriageNow_Import_Database__c = tndbAPOH.id;
         algoRef.AlgorithmID__c = ta4.id;
         algoRef.ReferenceID__c = ref.id;
         insert algoRef; 
         
         TriageNow_AlgorithmReference__c algoRefah = new TriageNow_AlgorithmReference__c();
         algoRefah.TriageNow_Import_Database__c = tndbAAH.id;
         algoRefah.AlgorithmID__c = ta4ah.id;
         algoRefah.ReferenceID__c = refah.id;
         insert algoRefah; 
         
         TriageNow_Disposition__c dips = new TriageNow_Disposition__c();
         dips.Hospice__c = false;
         dips.TriageNow_Import_Database__c = tndbAPOH.id;
        dips.LevelID__c = 100;
         insert dips;

         TriageNow_Question__c quesss = new TriageNow_Question__c();
         quesss.AlgorithmID__c = ta4.id;
         quesss.SMAG_LINK_ID__c = 1.2;
         quesss.DispositionLevel__c =  dd.id;
       //  ques.DispositionLevel__c =  dd.id;
         quesss.TriageNow_Import_Database__c = tndbAPOH.id;
          
         insert quesss; 

         TriageNow_Question__c ques = new TriageNow_Question__c();
         ques.AlgorithmID__c = ta.AlgorithmID__c;
         ques.SMAG_LINK_ID__c = 1.2;
         ques.DispositionLevel__c =  dips.id;
       //  ques.DispositionLevel__c =  dd.id;
         ques.TriageNow_Import_Database__c = tndbAPOH.id;
          
         insert ques;

         TriageNow_Algorithm__c algs = new TriageNow_Algorithm__c();
      //   algsalgsalgs.Acuity__c = 1;
         algs.category__c = 'adult';
         algs.Gender__c = 'B';
         algs.AlgorithmID__c = String.valueOf(ques.SMAG_LINK_ID__c);
      //   algs.DefinitionXHTML__c = 'testback';
      //   algs.FirstAidXHTML__c = 'testback';
      //   algs.ICD9Code__c = 'testback';
      //   algs.InitialAssessmentQuestions__c= 'testback';
      //   algs.Title__c = test1;
         algs.Status__c = 'Active';
         algs.TriageNow_Import_Database__c = tndbAPOH.id;         
         insert algs;


         TriageNow_Advice__c advice = new TriageNow_Advice__c();
         advice.TriageNow_Import_Database__c = tndbAPOH.id;
         insert advice;

         TriageNow_QuestionAdvice__c quesAdvice = new TriageNow_QuestionAdvice__c();
         quesAdvice.AdviceID__c =  advice.id;
         quesAdvice.TriageNow_Import_Database__c = tndbAPOH.id;
         quesAdvice.QuestionID__c = ques.id;
         insert quesAdvice;

         TriageNow_Supplemental__c sup = new TriageNow_Supplemental__c();
         sup.TriageNow_Import_Database__c = tndbAPOH.id;
         insert sup;

         TriageNow_AlgorithmSupplemental__c algoSup = new TriageNow_AlgorithmSupplemental__c();
         algoSup.AlgorithmID__c = ta4.id;
         algoSup.TriageNow_Import_Database__c = tndbAPOH.id;
         algoSup.SupplementalID__c = sup.id;
         insert algoSup;

         TriageNow_HealthInfoTopic__c infoTopic = new TriageNow_HealthInfoTopic__c();
         infoTopic.TriageNow_Import_Database__c = tndbAACI.id;
         insert infoTopic;

         TriageNow_RelatedACI__c related = new TriageNow_RelatedACI__c();
         related.TriageNow_Import_Database__c = tndbAPOH.id;
         related.AlgorithmID__c = ta4.Id;
         related.HealthInfoTopicID__c = 13;
         insert related;

         TriageNow_Advice__c advice77 = new TriageNow_Advice__c();
      //   advice77.AD_HealthInfoTopicId__c = related.id; 
         advice77.TriageNow_Import_Database__c = tndbAACI.id;
         insert advice77;

         TriageNow_Question__c quesah = new TriageNow_Question__c();
         quesah.AlgorithmID__c = ta4ah.id;
         quesah.TriageNow_Import_Database__c = tndbAAH.id;
         quesah.SMAG_LINK_ID__c = 1.2;
         quesah.DispositionLevel__c =  dd.id;         
         insert quesah;

         TriageNow_Advice__c adviceah = new TriageNow_Advice__c();
         adviceah.TriageNow_Import_Database__c = tndbAAH.id;
         insert adviceah;

         TriageNow_QuestionAdvice__c quesAdviceah = new TriageNow_QuestionAdvice__c();
         quesAdviceah.AdviceID__c =  adviceah.id;
         quesAdviceah.TriageNow_Import_Database__c = tndbAAH.id;
         quesAdviceah.QuestionID__c = quesah.id;
         insert quesAdviceah;

         TriageNow_Supplemental__c supah = new TriageNow_Supplemental__c();
         supah.TriageNow_Import_Database__c = tndbAAH.id;
         insert supah;

         TriageNow_AlgorithmSupplemental__c algoSupah = new TriageNow_AlgorithmSupplemental__c();
         algoSupah.AlgorithmID__c = ta4ah.id;
         algoSupah.TriageNow_Import_Database__c = tndbAAH.id;
         algoSupah.SupplementalID__c = supah.id;
         insert algoSupah;

         TriageNow_HealthInfoTopic__c infoTopicah = new TriageNow_HealthInfoTopic__c();
         infoTopicah.TriageNow_Import_Database__c = tndbAACI.id;
         insert infoTopicah;

         TriageNow_RelatedACI__c relatedah = new TriageNow_RelatedACI__c();
         relatedah.TriageNow_Import_Database__c = tndbAAH.id;
         relatedah.AlgorithmID__c = ta4ah.Id;
         relatedah.HealthInfoTopicID__c = 13;
         insert relatedah;

         TriageNow_Advice__c advice77ah = new TriageNow_Advice__c();
      
         advice77ah.TriageNow_Import_Database__c = tndbAACI.id;
         insert advice77ah;
         
         date dt = date.newInstance(1985, 02, 13);
         
         Test.startTest();
         Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator()); 
          Boolean isaccValid = KeywordSearchWSDl1.IsAccountValid(acct.id);

         
         string  designations = 'teztr';
         string cat = 'Both';
         string cats='Adult';
         string catss='Pediatric';       
         string s=      KeywordSearchWSDl1.Symptoms(test3,cats,true,'M',true,jsonString,true,0);                 
         string ssq=    KeywordSearchWSDl1.Symptoms(test1,cats,false,'M',true, jsonString,false,0); 
         string sss=    KeywordSearchWSDl1.Symptoms(test3,cats,true,'M',false,jsonString,true,0);
         string ttt33=  KeywordSearchWSDl1.Symptoms(test3,cat,false,'M',false,jsonString,true,0);
         string sssSS=  KeywordSearchWSDl1.Symptoms(test2,catss,true,'M',false,jsonString,true,0);  
         string sskjsSS=  KeywordSearchWSDl1.Symptoms(algoId,catss,false,'M',true,jsonString,false,0);         
         string sssSSQ =KeywordSearchWSDl1.GetNLPData(testString,cats,true,'M',jsonString,false,0);
         string ppgg  = KeywordSearchWSDl1.GetNLPData(testString,cat,true,'M',jsonString,false,0);
         string ssr =   KeywordSearchWSDl1.GetNLPData(testString,cat,false,'M',jsonString,false,0);
         string eessr =   KeywordSearchWSDl1.GetNLPData(testString,'asdas',false,'M',jsonString,false,0);
         string ssss =  KeywordSearchWSDl1.keywordOrtitle(ttqq.Title__c,cats,true,'M',true,jsonString);
  //       string ssss333 =  KeywordSearchWSDl1.keywordOrtitle(test2,cats,true,'M',false,jsonString);
         string ssss3s33 = KeywordSearchWSDl1.keywordOrtitle(test2,cat,false,'M',false,jsonString);
         string ssss3w33 = KeywordSearchWSDl1.keywordOrtitle(test2,catss,false,'M',false,jsonString);
         string ssss3w333 =KeywordSearchWSDl1.keywordOrtitle(testt,cat,false,'M',false,jsonString); 
         string ssss3w33q =KeywordSearchWSDl1.keywordOrtitle(test2,cat,false,'M',false,jsonString);  

     }
}