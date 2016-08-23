global class KeywordSearchWSDl
{
    webService string SearchKeyword{get;set;}
    global class returnWrapperObject{

        webService string Data{get;set;}
        webService integer Rating{get;set;}
    }

    webService static string FindCCC(){

        return 'This is the dummy service';
    }
}