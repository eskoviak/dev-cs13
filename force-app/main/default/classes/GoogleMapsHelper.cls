public virtual class GoogleMapsHelper extends MapHelper {
	private static final String googleEndpoint = 'http://maps.google.com/maps/api/staticmap';
	private static final String googleGeocodeEndpoint = 'http://maps.google.com/maps/api/geocode/xml';
	
	/*
	public override String getMapUrl(String location) {
		if( location == null )
			return null;
			
		return googleEndpoint + '?size=250x250&sensor=false&markers=size:mid|color:red|' + EncodingUtil.urlEncode(location, 'UTF-8'); 
	}
	*/
	
	public override MapHelper.Landmark geocodeLandmark(String landmarkAddress) {
	
		try {
			if( (landmarkAddress == null) || (landmarkAddress == '') )
				throw new MapsException('Geocoding: Invalid landmark address: empty');		
			
			String url = googleGeocodeEndpoint + '?address=' + landmarkAddress + '&sensor=false';		
			system.debug('url: ' + url);
			
			Http h = new Http();
			HttpRequest req = new HttpRequest();
			req.setEndpoint(url);
			req.setMethod('GET');
			
			HttpResponse res = new HttpResponse();
			dom.Document doc = new dom.Document();
			
			if(Test.isRunningTest()){
				textXML = '<?xml version="1.0" encoding="UTF-8"?> <GeocodeResponse>  <status>OK</status>  <result><type>country</type><type>political</type><formatted_address>Uganda</formatted_address>';
				textXML += '<address_component><long_name>Uganda</long_name><short_name>UG</short_name><type>country</type><type>political</type></address_component><geometry><location><lat>1.3733330</lat>';
				textXML += '<lng>32.2902750</lng></location><location_type>APPROXIMATE</location_type><viewport><southwest><lat>-1.4828153</lat><lng>28.1923745</lng></southwest><northeast><lat>4.2260728</lat>';
				textXML += '<lng>36.3881755</lng></northeast></viewport><bounds><southwest><lat>-1.4761108</lat><lng>29.5663892</lng></southwest><northeast><lat>4.2211117</lat><lng>35.0261117</lng></northeast>';
				textXML += '</bounds></geometry></result></GeocodeResponse>';
				
				doc.load(textXML);
			}else{
				res = h.send(req);
				doc = res.getBodyDocument();
			}

			if( doc == null )
				throw new MapsException('Geocoding: Unable to get response body');
						
			dom.XmlNode root = doc.getRootElement();
			if( root == null )
				throw new MapsException('Geocoding: Unable to get root node');
				
			String namespace = root.getNamespace();
			system.debug('namespace: ' + namespace);
			
			dom.XmlNode nodeResult = root.getChildElement('result', namespace);
			if( nodeResult == null )
				throw new MapsException('Geocoding: Unable to get result node');
			
			dom.XmlNode nodeGeometry = nodeResult.getChildElement('geometry', namespace);
			if( nodeGeometry == null )
				throw new MapsException('Geocoding: Unable to get geometry node');
				
			dom.XmlNode nodeLocation = nodeGeometry.getChildElement('location', namespace);
			if( nodeLocation == null )
				throw new MapsException('Geocoding: Unable to get location node');				
			
			MapHelper.Landmark next = new MapHelper.Landmark();
			next.latitude = safeGetNumber(nodeLocation, 'lat');
			next.longitude = safeGetNumber(nodeLocation, 'lng');
			next.name = landmarkAddress;
			
			if( (next.latitude == null) || (next.longitude == null) )			
				throw new MapsException('Geocoding: Unable to get latitude or longitude');
			
			return next;
		}
		catch( Exception e) {
			throw new MapsException('Geocoding: ' + e.GetMessage());
		}
	}
	
	private string textXML {get; set;}
}

/*
<?xml version="1.0" encoding="UTF-8"?> <GeocodeResponse>  <status>OK</status>  <result>
  <type>country</type>
  <type>political</type>
  <formatted_address>Uganda</formatted_address>
  <address_component>
   <long_name>Uganda</long_name>
   <short_name>UG</short_name>
   <type>country</type>
   <type>political</type>
  </address_component>
  <geometry>
   <location>
    <lat>1.3733330</lat>
    <lng>32.2902750</lng>
   </location>
   <location_type>APPROXIMATE</location_type>
   <viewport>
    <southwest>
     <lat>-1.4828153</lat>
     <lng>28.1923745</lng>
    </southwest>
    <northeast>
     <lat>4.2260728</lat>
     <lng>36.3881755</lng>
    </northeast>
   </viewport>
   <bounds>
    <southwest>
     <lat>-1.4761108</lat>
     <lng>29.5663892</lng>
    </southwest>
    <northeast>
     <lat>4.2211117</lat>
     <lng>35.0261117</lng>
    </northeast>
   </bounds>
  </geometry>
 </result>
</GeocodeResponse>

*/