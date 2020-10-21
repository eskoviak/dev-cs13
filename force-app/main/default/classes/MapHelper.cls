public abstract class MapHelper {

	public class MapsException extends Exception{}

	public enum LocationType { Country, Headquarters, Site}

	//public static final String STYLE_COUNTRY = 'http://maps.google.com/mapfiles/ms/micons/grn-pushpin.png';
	//public static final String STYLE_HEADQUARTERS= 'http://maps.google.com/mapfiles/ms/micons/blue-pushpin.png';
	//public static final String STYLE_SITE = 'http://maps.google.com/mapfiles/ms/micons/pink-pushpin.png';
	public static final String STYLE_COUNTRY = 'map_icons/GE-Map-Icons-Country.png';
	public static final String STYLE_HEADQUARTERS= 'map_icons/GE-Map-Icons-Headquarters.png';
	public static final String STYLE_SITE = 'map_icons/GE-Map-Icons-ProgramSites.png';
	
	public class Landmark {
		public Double longitude {get;set;}
		public Double latitude {get;set;}
		public String name {get;set;}		
		public String details {get;set;}
		public String markerStyle {get;set;}
	}
	
	
	//public abstract String getMapUrl(String location);
	public virtual MapHelper.Landmark geocodeLandmark(String landmarkAddress) {
		//throw( new MapsException( 'Geocoding not supported'));
		return null;
	}
	
	
	protected Double safeGetNumber(dom.XMLNode node, String elementName) {
		String result = safeGetText(node, elementName);
		if( (result != null) && (result != ''))
			return Double.valueOf(result);
		else
			return null;		
	}

	protected String safeGetText(dom.XMLNode node, String elementName) {
		if( node == null )
			return '';
			
		String namespace = node.getNamespace();
		system.debug('namespace: ' + namespace);
		dom.XMLNode childNode = node.getChildElement(elementName,  namespace);
		if( childNode != null ) { 
			system.debug('child node is not null: ' + childNode.getText());
			return childNode.getText();
		}
		else {
			system.debug('child node is null');
			return '';
		}		
	}
	
	/*
	public static String getPickListValue( LocationType lType ) { 
		if( lType == LocationType.Headquarters )
			return 'Program Headquarters';
		else if( lType == LocationType.Site )
			return 'Implementation Location';
		else
			return '';
	}
	
	public static String getMarkerStyle(LocationType lType) {
		if( lType == LocationType.Headquarters )
			return STYLE_HEADQUARTERS;
		else if( lType == LocationType.Site )
			return STYLE_SITE;
		else
			return STYLE_COUNTRY;
		
	}
	*/
}