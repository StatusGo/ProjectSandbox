@isTest(SeeAllData = true)
public class NLPIntegratedFinalTest{
     public static testMethod void UnitTest() {
         string test3 = 'Cancer';
         string test1 = 'Fever';
         String algoId = '444';
         String test2 = '~Fever';
        /* integer Age = 22;
         Boolean Officehours = true;
         string Gender = 'M';*/
         
  
/*string pedia ='Pediatric / ACI';
string Adult ='Adult / ACI';
string PAH ='Pediatric / AH';
string pedia ='Adult / AH';
string pedia ='Adult and Pediatric / OH';*/

         TriageNow_Import_Database__c tndbAPOH = [select id from TriageNow_Import_Database__c where Db_Alias__c = 'Adult and Pediatric / OH'];
        TriageNow_Import_Database__c tndbAACI = [select id from TriageNow_Import_Database__c where Db_Alias__c = 'Adult / ACI'];
         //tndbAPOH.Db_Alias__c = 'Adult and Pediatric / OH';
         //insert tndbAPOH;
         //string sss1 = (string)tndbAPOH.Id;
/*
         TriageNow_Import_Database__c tndbPAH = new TriageNow_Import_Database__c();
         tndbPAH.Db_Alias__c = 'Pediatric / AH';
         insert tndbPAH;
         string sss2 = (string)tndbPAH.Id;

         TriageNow_Import_Database__c tndbAAH = new TriageNow_Import_Database__c();
         tndbAAH.Db_Alias__c = 'Adult / AH';
         insert tndbAAH;
         string sss3 = (string)tndbAAH.Id;


         TriageNow_Import_Database__c tndbPACI = new TriageNow_Import_Database__c();
         tndbPACI.Db_Alias__c = 'Pediatric / ACI';
         insert tndbPACI;
         string sss4 = (string)tndbPACI.Id;


         TriageNow_Import_Database__c tndbAACI = new TriageNow_Import_Database__c();
         tndbAACI.Db_Alias__c = 'Adult / ACI';
         insert tndbAACI;
         string sss5 = (string)tndbAACI.Id;*/

   /*      for(integer i = 400 ;i < 410 ;i++){

         TriageNow_Algorithm__c ta = new TriageNow_Algorithm__c();
         ta.Acuity__c = 1;
         ta.category__c = 'adult';
         //ta.Group__c = 'after';
         ta.Gender__c = 'M';
         ta.AlgorithmID__c = string.valueof(i);
         ta.BackgroundXHTML__c = 'testback';
         ta.Copyright__c = 'testback';
         ta.DefinitionXHTML__c = 'testback';
         ta.FirstAidXHTML__c = 'testback';
         ta.ICD9Code__c = 'testback';
         ta.InitialAssessmentQuestions__c= 'testback';
         ta.Title__c = test;
         ta.Status__c = 'Active';
         ta.TriageNow_Import_Database__c = tndbAPOH.id;         
         insert ta;//oH = open

         } */


         NLPIntegratedFinal ss= new NLPIntegratedFinal();         
         NLPIntegratedFinal.returnWrapperObject wrap = new NLPIntegratedFinal.returnWrapperObject();

           NLPIntegratedFinal.AlgoreturnVal algo = new NLPIntegratedFinal.AlgoreturnVal();        
         NLPIntegratedFinal.QuestionAdvice qAdvice = new NLPIntegratedFinal.QuestionAdvice();
         NLPIntegratedFinal.AlgoreferencerretVal Algoreference = new NLPIntegratedFinal.AlgoreferencerretVal();
         NLPIntegratedFinal.QuestionAdvice qa = new NLPIntegratedFinal.QuestionAdvice();
         NLPIntegratedFinal.Supplement supp= new NLPIntegratedFinal.Supplement();
         NLPIntegratedFinal.RelatedACI aci = new  NLPIntegratedFinal.RelatedACI();
         NLPIntegratedFinal.Question qas = new NLPIntegratedFinal.Question();
         NLPIntegratedFinal.WrapHelthInfoTopic wraphealth = new NLPIntegratedFinal.WrapHelthInfoTopic();

          NLPIntegratedFinal.returnWrapperObject wrap1 = new NLPIntegratedFinal.returnWrapperObject();
          NLPIntegratedFinal.returnWrapperObject wrap2 = new NLPIntegratedFinal.returnWrapperObject();
          NLPIntegratedFinal.returnWrapperObject wrap3 = new NLPIntegratedFinal.returnWrapperObject();
          NLPIntegratedFinal.returnWrapperObject wrap4 = new NLPIntegratedFinal.returnWrapperObject();
          NLPIntegratedFinal.returnWrapperObject wrap5 = new NLPIntegratedFinal.returnWrapperObject();
          NLPIntegratedFinal.returnWrapperObject wrap6 = new NLPIntegratedFinal.returnWrapperObject();
          NLPIntegratedFinal.returnWrapperObject wrap7 = new NLPIntegratedFinal.returnWrapperObject();
         
         
       
         //TriageNow_Import_Database__c data = new TriageNow_Import_Database__c();
//insert data;
              
///OH A and P
              //TriageNow_Import_Database__c db = [Select id from TriageNow_Import_Database__c where Db_Alias__c =: 'Adult and Pediatric / OH11'];
           TriageNow_SearchWord__c tsa = new TriageNow_SearchWord__c();
              tsa.ConceptTitle__c ='test3';
              tsa.SearchWord__c = test3; //cough
              tsa.Searchword_Type__c = 'test3';
              tsa.TriageNow_Import_Database__c = tndbAPOH.id;
              insert tsa;

         TriageNow_AlgorithmSearchWord__c algosearch = new TriageNow_AlgorithmSearchWord__c();
         algosearch.SearchWord__c = tsa.id;
         algosearch.TriageNow_Import_Database__c = tndbAPOH.id;
         insert algosearch;

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
             
 

          TriageNow_AlgorithmSearchWord__c tt = new TriageNow_AlgorithmSearchWord__c();
          //tt.AD_AlgorithmID__c = '555';
          //tt.AD_SearchWord__c  = 'test';
          tt.AlgorithmID__c = ta3.id;
          tt.SearchWord__c = tsa.id;
          tt.TriageNow_Import_Database__c = tndbAPOH.id;
           insert tt;   


          TriageNow_Concept__c cc = new TriageNow_Concept__c();
          cc.TriageNow_Import_Database__c = tndbAPOH.id;
          cc.Title__c = test3;
          insert cc;
 
          TriageNow_AlgorithmCCC__c algoCCC = new TriageNow_AlgorithmCCC__c();
          algoCCC.ConceptID__c = cc.id;
          algoCCC.AlgorithmID__c = ta.id;
          algoCCC.TriageNow_Import_Database__c = tndbAPOH.id;
          insert algoCCC;
          
         TriageNow_Reference__c ref = new TriageNow_Reference__c();
         ref.TriageNow_Import_Database__c = tndbAPOH.id;
         insert ref;
         
         TriageNow_AlgorithmReference__c algoRef = new TriageNow_AlgorithmReference__c();
         algoRef.TriageNow_Import_Database__c = tndbAPOH.id;
         algoRef.AlgorithmID__c = ta4.id;
         algoRef.ReferenceID__c = ref.id;
         insert algoRef; 

         TriageNow_Question__c ques = new TriageNow_Question__c();
         ques.AlgorithmID__c = ta4.id;
         ques.TriageNow_Import_Database__c = tndbAPOH.id;
         insert ques;

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

         
         date dt = date.newInstance(1985, 02, 13);
         
         Test.startTest();
// SingleRequestMock fakeResponse = new SingleRequestMock(200,'Complete');
 Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator()); 
   //      string Symptom,integer Age,Boolean Officehours,string Gender,Boolean SpecificAlgoID
  // Symptoms(string Symptom,integer Age,Boolean Officehours,string Gender,Boolean SpecificAlgoID){
         string s= NLPIntegratedFinal.Symptoms(test3,25,true,'M',true,dt);
         string ssq= NLPIntegratedFinal.Symptoms(test1,25,false,'M',true,dt);
		// string symptom,boolean Officehours,string TNDb,string Gender,string catagory,date birthdate
         string sss= NLPIntegratedFinal.Symptoms(test3,25,true,'M',false,dt);
		 string sssSS= NLPIntegratedFinal.Symptoms(test2,25,true,'M',false,dt);
       //  string sssss = NLPIntegratedFinal.ChiefComplains(test2,true,25,'M',dt);
        // wrap = NLPIntegratedFinal.Algomap(test,'adult',25,'F',sss);
         //string k= NLPIntegratedFinal.Symptoms(test,13,true,'F');
        // wrap1 = NLPIntegratedFinal.Algomap(test,'Pediatric',12,'F',sss);

         //string sls= NLPIntegratedFinal.Symptoms(test,25,false,'F');
        // wrap2 = NLPIntegratedFinal.Algomap(test,'adult',25,'F',sss);
         //string kk= NLPIntegratedFinal.Symptoms(test,13,false,'F');
        // wrap3 = NLPIntegratedFinal.Algomap(test,'Pediatric',12,'F',sss);

       /*  string sssd= NLPIntegratedFinal.Symptoms(test,25,true,'M');
         wrap4 = NLPIntegratedFinal.Algomap(test,'adult',25,'M',sss);
         string ksd= NLPIntegratedFinal.Symptoms(test,13,true,'M');
         wrap5 = NLPIntegratedFinal.Algomap(test,'Pediatric',12,'M',sss);

         string ers= NLPIntegratedFinal.Symptoms(test,25,false,'M');
         wrap6 = NLPIntegratedFinal.Algomap(test,'adult',25,'M',sss);
         string kvb= NLPIntegratedFinal.Symptoms(test,13,false,'M');
         
         
         wrap7 = NLPIntegratedFinal.Algomap(test,'Pediatric',12,'M',sss);*/
         //system.debug('wrap1wrap1wrap1'+wrap);
         
       

      //   String str = null;
        // NLPIntegratedFinal.Symptoms(str);
        
        /* List<TriageNow_Algorithm__c> ALgorithm1 = [ SELECT Acuity__c,BackgroundXHTML__c,Copyright__c,DefinitionXHTML__c,FirstAidXHTML__c
                                                    ,ICD9Code__c,Id,InitialAssessmentQuestions__c,Title__c
                                                    FROM TriageNow_Algorithm__c 
                                                    WHERE Title__c like: test]; 
           system.debug('ALgorithm1ALgorithm1'+ALgorithm1); */
      /*   TriageNow_Import_Database__c data = new TriageNow_Import_Database__c();
         insert data;
         TriageNow_Algorithm__c algo1 = new TriageNow_Algorithm__c();
         algo1.TriageNow_Import_Database__c = data.id;
         algo1.Title__c = test;
         insert algo1;
         algo.DefinitionXHTML = algo1.DefinitionXHTML__c;
         algo.ICD9Code =  algo1.ICD9Code__c;
         algo.Acuity = algo1.Acuity__c;
         TriageNow_Algorithm__c algo2 = new TriageNow_Algorithm__c();
         algo2.TriageNow_Import_Database__c = data.id;
         algo2.Title__c = test;
         insert algo2; */
        
           
                                                           
      
         
     }
}