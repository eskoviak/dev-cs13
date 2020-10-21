@isTest
private class RWS_Home_PageController_Test {
	@isTest 
    public static void Constructor_Test(){
    	
			RWS_Home_PageController controller = new RWS_Home_PageController();
			Boolean isFullAccess = controller.isFullAccessUser;

			System.assert(isFullAccess != null);
		 
	}
}