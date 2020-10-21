/********************************************************************************
*   CHANGE  HISTORY
*   =============================================================================
*   Date        Name                    Description
*   7/07/2017  Joey Zhuang/M360        Add user access level indicator
********************************************************************************/
public class RWS_Home_PageController{

    //added by Joey
    public Boolean isFullAccessUser {get;set;}
    
    public RWS_Home_PageController() {
        isFullAccessUser = RWS_UtilityClass.isFullAccessUser();
       
    }    
 
    
}