public with sharing class CaseVoluntaryRecallController {

/**
*   {Purpose}  �  Provides an interface to allow users to mass enter products for the 2013 Voluntary Recall campaign
*                 
*   {Function}  � Interfaces with CaseVoluntaryRecall VF page
*
*   {Contact}   - support@demandchainsystems.com
*                 www.demandchainsystems.com
*                 612-424-0032                  
*/

/**
*   CHANGE  HISTORY
*   =============================================================================
*   Date    	Name             		Description
*   20131031  	Andy Boettcher DCS		Created
*   =============================================================================
*/
	public Id idRecord {get;set;}
	public String strTest {get;set;}
	private Set<String> setAllSizes = new Set<String>();
	private Integer intSepCount = 0;

	///////////////////////////////////
	// Constructors
	///////////////////////////////////
	
	public CaseVoluntaryRecallController(ApexPages.standardController scMain) {
		
		idRecord = scMain.getId();
		strTest = '';
		
		setAllSizes.add('11');
		setAllSizes.add('11.5');
		setAllSizes.add('12');
		setAllSizes.add('13');
		setAllSizes.add('14');
		setAllSizes.add('15');
		setAllSizes.add('16');
		setAllSizes.add('17');
		setAllSizes.add('18');
		
	}
	
	///////////////////////////////////
	// GET / SET
	///////////////////////////////////
	public List<hClsStyle> lstStyles {
		get {
			
			List<hClsStyle> lstStylesTemp = new List<hClsStyle>();
			
			// TODO: Query Existing Values
			Map<String, String> mapQuantities = new Map<String, String>();
			for(Case_Component__c cc : [SELECT Style__c, Condition__c, Width__c, Size__c, Quantity__c FROM Case_Component__c WHERE Case__c = :idRecord]) {
				mapQuantities.put(cc.Style__c + cc.Condition__c + cc.Width__c + cc.Size__c, string.valueOf(integer.valueOf(cc.Quantity__c)));
			}
			
			// Query Master Custom Setting
			//for(Voluntary_Recall_Rules__c vr : Voluntary_Recall_Rules__c.getall().values()) {
			for(Voluntary_Recall_Rules__c vr : [SELECT Id, Name, IsActive__c, StyleScope__c FROM Voluntary_Recall_Rules__c WHERE IsActive__c = true ORDER BY Name ASC]) {
				
				// Style
				String strStyle = vr.Name;
				
				// Create Parent hClsStyle
				hClsStyle clsStyle = new hClsStyle(strStyle, intSepCount);
				if(intSepCount == 5) {
					intSepCount = 1;
				} else {
					intSepCount += 1;
				}
			
				Map<String, hClsWidth> mapWidths = new Map<String, hClsWidth>();				
				
				// Parse Scoped widths
				List<String> lstWidths = vr.StyleScope__c.split('\\|');
				for(String strScope : lstWidths) {
					
					// Split Width and Sizes
					String[] arrScope = strScope.split(':');
					
					// Create hClsWidth
					hClsWidth clsWidth = new hClsWidth(arrScope[0]);
					Map<String, hClsSize> mapSizes = new Map<String, hClsSize>();
					
					// Create all possible size combos first
					for(String strAllSize : setAllSizes) {
						mapSizes.put(strAllSize, new hClsSize(false, null,null,strAllSize,0,0));
					}
					
					// Parse Sizes
					List<String> lstSizes = arrScope[1].split(',');
					for(String strSize : lstSizes) {
						
						// Test Output
						strTest += strSize + ' in width ' + arrScope[0] + ' for style ' + strStyle + '<br />';
						
						// TODO:  Interrogate existing values and determine if there is already an entry!
						//mapQuantities.put(cc.Style__c + cc.Condition__c + cc.Width__c + Size__c, integer.valueOf(cc.Quantity__c));
						String strQuantityNewKey = strStyle + 'New' + arrScope[0] + strSize;
						String strQuantityWornKey = strStyle + 'Worn' + arrScope[0] + strSize;
						
						Id idExistingRecordNew = null;
						Id idExistingRecordWorn = null;
						Integer intQuantityNew = checkForNullInteger(mapQuantities.get(strQuantityNewKey));
						Integer intQuantityWorn = checkForNullInteger(mapQuantities.get(strQuantityWornKey));
						
						// Create hClsSize
						mapSizes.put(strSize, new hClsSize(true, idExistingRecordNew,idExistingRecordWorn,strSize,intQuantityNew,intQuantityWorn));
						
					}
					
					// Place Size Map into Width Class
					clsWidth.mapSizes = mapSizes;
					
					// Add Width Class to Width Map
					mapWidths.put(arrScope[0], clsWidth);

				}
				
				// Add Width Map to Style
				clsStyle.mapWidths = mapWidths;
				clsStyle.intWidthCount = mapWidths.size();
				
				// Add Style Class to Main List
				lstStylesTemp.add(clsStyle);

			}
			
			return lstStylesTemp;
			
		}
		// set {lstStyles = value;}
	}
	
	///////////////////////////////////
	// Action Methods
	///////////////////////////////////
	@RemoteAction
	public static String deleteData(String strCaseId, String strCondition, String strStyle, String strWidth, String strSize) {
		
		String strReturn = '';
			
		List<Case_Component__c> lstCheck = [SELECT Id FROM Case_Component__c WHERE Case__c = :strCaseId
																		AND Condition__c = :strCondition
																		AND Style__c = :strStyle 
																		AND Width__c = :strWidth
																		AND Size__c = :strSize];
		
		if(lstCheck.size() > 0) {
			delete lstCheck;
		}
		
		strReturn = 'success';
		
		return strReturn;
		
	}
	
	@RemoteAction
	public static String processData(String strCaseId, String strCondition, String strRecordId, String strStyle, String strWidth, String strSize, String intQuantity) {
		
		String strReturn = '';
		Case_Component__c ccShoe = new Case_Component__c();
		ccShoe.Case__c = strCaseId;

		List<Case_Component__c> lstCheck = [SELECT Id FROM Case_Component__c WHERE Case__c = :strCaseId
																			AND Condition__c = :strCondition
																			AND Style__c = :strStyle 
																			AND Width__c = :strWidth
																			AND Size__c = :strSize LIMIT 1];
																			
		System.Debug(LoggingLevel.ERROR, 'lstCheck = ' + lstCheck);
																			
			
		
		if(lstCheck.size() > 0) {
			ccShoe = new Case_Component__c(Id=lstCheck[0].Id);
		}
		
		try {

			ccShoe.Condition__c = strCondition;
			ccShoe.Quantity__c = integer.valueOf(intQuantity);
			ccShoe.Size__c = strSize;
			ccShoe.Width__c = strWidth;
			ccShoe.Style__c = strStyle;
			
			upsert ccShoe;
		
			strReturn = 'success';
			
		} catch(Exception ex) {
			strReturn = string.valueOf(ex);
		}
		
		return strReturn;
		
	}
	
	public Integer checkForNullInteger(String strValue) {
		
		if(strValue == null) {
			return 0;
		}
		
		return integer.valueOf(strValue);
		
	}
	
	///////////////////////////////////
	// Helper Classes
	///////////////////////////////////
	public class hClsStyle {
		
		public Map<String, hClsWidth> mapWidths {get;set;}
		public Integer intWidthCount {get;set;}
		public String strStyle {get;set;}
		public Boolean bolSepBar {get;set;}
		
		public hClsStyle(String passStyle, Integer intSepCount) {
			strStyle = passStyle;
			bolSepBar = false;
			
			if(intSepCount == 5) {
				bolSepBar = true;
			}
			
		}
	}
	
	public class hClsWidth {
		
		public Map<String, hClsSize> mapSizes {get;set;}
		public String strWidth {get;set;}
		
		public hClsWidth(String passWidth) {
			strWidth = passWidth;	
		}
	}
	
	public class hClsSize {
		
		public Boolean bolAvailable {get;set;}
		public Id idExistingRecordNew {get;set;}
		public Id idExistingRecordWorn {get;set;}
		public String strSize {get;set;}
		public Integer intQuantityNew {get;set;}
		public Integer intQuantityWorn {get;set;}
		
		public hClsSize(Boolean passAvailable, Id passRecordIdNew, Id passRecordIdWorn, String passSize, Integer passQuantityNew, Integer passQuantityWorn) { 
			
			bolAvailable = passAvailable;
			strSize = passSize;
			
			idExistingRecordNew = passRecordIdNew;
			intQuantityNew = (passQuantityNew == 0) ? null : passQuantityNew;
			
			idExistingRecordWorn = passRecordIdWorn;
			intQuantityWorn = (passQuantityWorn == 0) ? null : passQuantityWorn;
		}
	}

}