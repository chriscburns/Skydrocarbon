//
//  ArcGISTest1ViewController.m
//  ArcGISTest1
//
//  Created by Chris Burns on 11-05-04.
//  Copyright University of Calgary. 2011. All rights reserved.
//

#import "ArcGISTest1ViewController.h"
#import "ArcGISTest1AppDelegate.h"

#import "MBProgressHUD.h"

@implementation ArcGISTest1ViewController

@synthesize mapView=_mapView;

@synthesize depthsInfo; 
@synthesize contoursInfo; 


@synthesize contoursLayer; 
@synthesize oilLayer; 
@synthesize depthsLayer; 


@synthesize dcoControl; 
@synthesize secondaryControl;






#pragma mark Background Thread Functions


- (void) downloadMapInfo {
	
	
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];

	NSLog(@" Map Attempt Started"); 


	NSError *error = nil; 
	
	//Download the AGSMapServiceInfo object for depth 
	NSURL *depthsUrl = [NSURL URLWithString:@"http://asebeast.cpsc.ucalgary.ca:1892/ArcGIS/rest/services/cpzdepths/MapServer"];
	self.depthsInfo = [AGSMapServiceInfo mapServiceInfoWithURL:depthsUrl error:&error]; 
	
	//Download the AGSMapServiceInfo object for contours
	NSURL *contoursUrl = [NSURL URLWithString:@"http://asebeast.cpsc.ucalgary.ca:1892/ArcGIS/rest/services/cpzcontoursopt/MapServer"];
	self.contoursInfo = [AGSMapServiceInfo mapServiceInfoWithURL:contoursUrl error:&error]; 
	
	NSLog(@" Map Attempt Ended"); 

	
	//Download the AGSMapServiceInfo object for depth 
	//NSURL *oilUrl = [NSURL URLWithString:@"http://asebeast.cpsc.ucalgary.ca:1892/ArcGIS/rest/services/Oil12mask/MapServer"]; 
	//(TODO - this needs to be made an instance variable)AGSMapServiceInfo *oilInfo = [AGSMapServiceInfo mapServiceInfoWithURL:oilUrl error:&error]; 
	
	
	if (error) {
		
		NSLog(@"Map Info Failed To Load: %@", error );   
		//(TODO) add the create alert view with the appropriate information
		
	}
	
	
	else {
		
		[self performSelectorOnMainThread:@selector(loadMapInfo) withObject:nil waitUntilDone:NO]; 
		
	}
	
	
	[pool drain]; 
	
}


- (void) loadMapInfo {
	
	NSLog(@" Load Attempt Started %@ + ", [NSThread isMainThread]?@"YES": @"NO");  

	
	//Load the depth layer
	self.depthsLayer = [AGSDynamicMapServiceLayer dynamicMapServiceLayerWithMapServiceInfo:self.depthsInfo]; 
	self.depthsLayer.visibleLayers = [NSArray arrayWithObjects:[NSNumber numberWithInt:0], nil];
	
	
	//Load the contour layer and display it 
	self.contoursLayer = [AGSDynamicMapServiceLayer dynamicMapServiceLayerWithMapServiceInfo:self.contoursInfo]; 
	self.contoursLayer.visibleLayers = [NSArray arrayWithObjects:[NSNumber numberWithInt:0], nil];  //Only show C Layer 
	[self.mapView addMapLayer:contoursLayer withName:@"Contours Layer"]; 
	
	
	
	NSLog(@" Load Attempt Ended %@ + ", [NSThread isMainThread]?@"YES": @"NO");  

	
	/*Load the oil layer and display it (TODO) 
	self.oilLayer = [AGSDynamicMapServiceLayer dynamicMapServiceLayerWithMapServiceInfo:oilInfo]; 
	self.oilLayer.visibleLayers = [NSArray arrayWithObjects:[NSNumber numberWithInt:0], nil]; //Only show 75% Layer 
	
	[self.mapView addMapLayer:oilLayer withName:@"Oil Layer"]; */
	
	
}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	
	//Add the base map which serves as the background to all subsquent maps 
	NSURL *baseUrl = [NSURL URLWithString:@"http://asebeast.cpsc.ucalgary.ca:1892/ArcGIS/rest/services/bingmapsRoad/MapServer"];
	AGSDynamicMapServiceLayer *baseLayer = [AGSDynamicMapServiceLayer dynamicMapServiceLayerWithURL:baseUrl]; 
	
	[self.mapView addMapLayer:baseLayer withName:@"Base Layer"];
	
	
	[self performSelectorInBackground:@selector(downloadMapInfo) withObject:nil]; 
	
	AGSSpatialReference *sr = [AGSSpatialReference spatialReferenceWithWKID:4283]; 
	
	AGSEnvelope *initialExtent = [AGSEnvelope envelopeWithXmin:138.225
														  ymin:-29.215
														  xmax:141.855
														  ymax:-26.321
											  spatialReference:sr];
	
	[self.mapView zoomToEnvelope:initialExtent animated:YES]; 
	
	
	
	/*
	
	NSError *error = nil; 

	NSLog(@" Map Attempt Started"); 
	//Depth (Map) Layers (! Not Shown By Default, ergo it's loaded but not put into the view)
	NSURL *depthsUrl = [NSURL URLWithString:@"http://asebeast.cpsc.ucalgary.ca:1892/ArcGIS/rest/services/cpzdepths/MapServer"];
	self.depthsInfo = [AGSMapServiceInfo mapServiceInfoWithURL:depthsUrl error:&error]; 
	
	NSLog(@"Map Info Attempt To Load Failed?: %@", error); 
	
	
	self.depthsLayer = [AGSDynamicMapServiceLayer dynamicMapServiceLayerWithMapServiceInfo:depthsInfo]; 
	self.depthsLayer.visibleLayers = [NSArray arrayWithObjects:[NSNumber numberWithInt:0], nil];
	
	

	//Contours (Lines) Layers 
	NSURL *contoursUrl = [NSURL URLWithString:@"http://asebeast.cpsc.ucalgary.ca:1892/ArcGIS/rest/services/cpzcontoursopt/MapServer"];
	self.contoursInfo = [AGSMapServiceInfo mapServiceInfoWithURL:contoursUrl error:&error]; 
	
	self.contoursLayer = [AGSDynamicMapServiceLayer dynamicMapServiceLayerWithMapServiceInfo:contoursInfo]; 
	self.contoursLayer.visibleLayers = [NSArray arrayWithObjects:[NSNumber numberWithInt:0], nil];  //Only show C Layer 
	
	
	[self.mapView addMapLayer:contoursLayer withName:@"Contours Layer"]; 
	
	
	
	
	//Oil Layer 
	NSURL *oilUrl = [NSURL URLWithString:@"http://asebeast.cpsc.ucalgary.ca:1892/ArcGIS/rest/services/Oil12mask/MapServer"]; 
	AGSMapServiceInfo *oilInfo = [AGSMapServiceInfo mapServiceInfoWithURL:oilUrl error:&error]; 

	self.oilLayer = [AGSDynamicMapServiceLayer dynamicMapServiceLayerWithMapServiceInfo:oilInfo]; 
	self.oilLayer.visibleLayers = [NSArray arrayWithObjects:[NSNumber numberWithInt:0], nil]; //Only show 75% Layer 
	
	[self.mapView addMapLayer:oilLayer withName:@"Oil Layer"]; 
	
	
	

	//Zoom the correct initial extent 
	
	AGSSpatialReference *sr = [AGSSpatialReference spatialReferenceWithWKID:4283]; 
	
	AGSEnvelope *initialExtent = [AGSEnvelope envelopeWithXmin:138.225
														  ymin:-29.215
														  xmax:141.855
														  ymax:-26.321
											  spatialReference:sr];
						
	[self.mapView zoomToEnvelope:initialExtent animated:YES]; 
	
	 
	 */
	 
	

}




#pragma mark Segmented Control Functions

- (IBAction) dcoIndexChanged {
	
	
	
	int currentIndex = self.dcoControl.selectedSegmentIndex; 
	
	
	switch (currentIndex) {
		case 0:
			[self loadDepthControl];
			break;
			
		case 1:
			[self loadOilControl];
			break;
			
		case 2:
			[self loadContoursControl];
			break;


		default:
			break;
	}
	
}

- (IBAction) secondaryIndexChanged {
	
		
	//Determine what the new changed index value
	int currentIndex = self.secondaryControl.selectedSegmentIndex; 
	
	
	
	
	//Determine which segment the higher level controller is on (i.e. depth, contours, etc) 
	
	if (self.dcoControl.selectedSegmentIndex == 0) { //Depth
		
		//Find the currently visible layers in the map 
		NSArray *activeLayers = self.mapView.mapLayers; 
		
		//Contours are visible
		if ([activeLayers containsObject:self.contoursLayer]) {

			self.contoursLayer.visibleLayers = [NSArray arrayWithObjects:[NSNumber numberWithInt:currentIndex], nil]; 
			[self.contoursLayer dataChanged]; 
		}
		
		//Depths are visible
		else if ([activeLayers containsObject:self.depthsLayer]) {
			
			self.depthsLayer.visibleLayers = [NSArray arrayWithObjects:[NSNumber numberWithInt:currentIndex], nil];
			[self.depthsLayer dataChanged]; 
		}
			 
		
		
	} 
	
	
	else if (self.dcoControl.selectedSegmentIndex == 1) { //Microseeps 
		
		self.oilLayer.visibleLayers = [NSArray arrayWithObjects:[NSNumber numberWithInt:currentIndex], nil]; 
		[self.oilLayer dataChanged]; 
		
	}
	
	
	else if (self.dcoControl.selectedSegmentIndex == 2) {  //Visibility of lines & map 
		
		switch (currentIndex) {
			case 0: //Contours (Lines) Only
	
				
				if ([self.mapView.mapLayers containsObject:self.depthsLayer]) {
					
					self.contoursLayer.visibleLayers = self.depthsLayer.visibleLayers; //Copy Visibility from Contours
				
					[self.mapView removeMapLayerWithName:@"Depths Layer"]; //Remove depths layer 
					[self.mapView insertMapLayer:self.contoursLayer withName:@"Contours Layer" atIndex:1];
				}

				break;
				
			case 1: //Depths (Map) Only 
				
				self.depthsLayer.visibleLayers = self.contoursLayer.visibleLayers; //Copt Visibility from Depths
	
				
				[self.mapView removeMapLayerWithName:@"Contours Layer"]; //Remove contours layer 
				[self.mapView insertMapLayer:self.depthsLayer withName:@"Depths Layer" atIndex:1]; 
				
				//self.contoursLayer = nil;
				break;
								
			default:
				NSAssert(false, @"Error with the secondary control under the lines & maps context"); 
				break;
		}
		
		
	}
	
	
	
	
	
	
	
}



	

#pragma mark Secondary Segmented Control Functions 
- (void) loadDepthControl {
	
	
	//Remove all existing segments
	
	[self.secondaryControl removeAllSegments]; 
	
	//Add the C P Z depth segments 
	[self.secondaryControl insertSegmentWithTitle:@"C" atIndex:0 animated:YES]; 
	[self.secondaryControl insertSegmentWithTitle:@"P" atIndex:1 animated:YES];
	[self.secondaryControl insertSegmentWithTitle:@"Z" atIndex:2 animated:YES];
	
	//Select the item in the list that is currently selected in the map
	//int currentSelected = [[depthsLayer.visibleLayers lastObject] intValue];
	
	int currentSelected = [[contoursLayer.visibleLayers lastObject] intValue];
	self.secondaryControl.selectedSegmentIndex = currentSelected; 

	
}

- (void) loadOilControl {
	
	//Remove all existing segments 
	
	[self.secondaryControl removeAllSegments]; 
	
	//Add 75%, 85%, 90%, 95%
	[self.secondaryControl insertSegmentWithTitle:@"75%" atIndex:0 animated:YES]; 
	[self.secondaryControl insertSegmentWithTitle:@"85%" atIndex:1 animated:YES]; 
	[self.secondaryControl insertSegmentWithTitle:@"90%" atIndex:2 animated:YES]; 
	[self.secondaryControl insertSegmentWithTitle:@"95%" atIndex:3 animated:YES]; 
	
	//Select the item in the list that s currently selected in the map
	int currentSelected = [[oilLayer.visibleLayers lastObject] intValue]; 
	self.secondaryControl.selectedSegmentIndex = currentSelected; 
}


- (void) loadContoursControl {
	
	//Remove all existing segments 
	
	[self.secondaryControl removeAllSegments]; 
	
	//Add the C P Z contour segments
	[self.secondaryControl insertSegmentWithTitle:@"Line" atIndex:0 animated:YES]; 
	[self.secondaryControl insertSegmentWithTitle:@"Map" atIndex:1 animated:YES];
	
	//Find the currently visible layers in the map 
	NSArray *activeLayers = self.mapView.mapLayers; 
	
	//Contours are visible
	if ([activeLayers containsObject:self.contoursLayer]) {
		
		self.secondaryControl.selectedSegmentIndex = 0;
		
	}
	
	//Depths are visible
	else if ([activeLayers containsObject:self.depthsLayer]) {
		
		self.secondaryControl.selectedSegmentIndex = 1; 
		
	}
	
	
}

/*
#pragma mark iOS Remote Connector Functions
- (void) registerAllListeners {
	
	ArcGISTest1AppDelegate *delegate = (ArcGISTest1AppDelegate *) [[UIApplication sharedApplication] delegate];
	
	//Register to listen for method calls 
	[[[delegate receiver] methodResponders] addObject:self]; //Add self to the list of method responders
	
	//Register to listen for received data (as in requested files)
	[[[delegate sender] dataReceivedListeners] addObject:self]; //Add self to the list of file received listeners
	
}
 
 

- (void) changeExtentToXMin:(id) xmin xMax: (id) xmax yMin: (id) ymin yMax: (id) ymax withID:(id) mID {
	
	double xMinAsDouble = [((NSString *) xmin) doubleValue]; 
	
	double xMaxAsDouble = [((NSString *)xmax) doubleValue]; 
	
	double yMinAsDouble = [((NSString *)ymin) doubleValue]; 
	
	double yMaxAsDouble = [((NSString *)ymax) doubleValue]; 
	
	NSAssert(xMinAsDouble < xMaxAsDouble, @"xMin is greater or equal to xMax"); 
	
	NSAssert(yMinAsDouble < yMaxAsDouble, @"yMin is greater or equal to yMax"); 
	
	
	AGSSpatialReference *sr = [AGSSpatialReference spatialReferenceWithWKID:4283];
	AGSEnvelope *env = [AGSEnvelope envelopeWithXmin:xMinAsDouble
												ymin:yMinAsDouble
												xmax:xMaxAsDouble
												ymax:yMaxAsDouble
									spatialReference:sr];
	[self.mapView zoomToEnvelope:env animated:YES];
	
	
	
	
}


- (void) changeOilLayer:(id) oilLayerValue withID: (id) mID {
	
	NSLog(@" changeOilValue  to %@", (NSString *) oilLayerValue); 
	
	int oilLayerValueAsInt = [((NSString *) oilLayerValue) intValue]; 
	self.oilLayer.visibleLayers = [NSArray arrayWithObjects:[NSNumber numberWithInt:oilLayerValueAsInt], nil];  

	if (dcoControl.selectedSegmentIndex == 1) { secondaryControl.selectedSegmentIndex = oilLayerValueAsInt; }
	
	
}

- (void) changeDepthLayer: (id) depthLayerValue withID: (id) mID {
	
	
	NSLog(@" changeDepthValue  to %@", (NSString *) depthLayerValue); 
	
	int depthLayerValueAsInt = [((NSString *) depthLayerValue) intValue];
	self.contoursLayer.visibleLayers = [NSArray arrayWithObjects:[NSNumber numberWithInt:depthLayerValueAsInt], nil];  //Only show C Layer

	
	if (dcoControl.selectedSegmentIndex == 0) { secondaryControl.selectedSegmentIndex = depthLayerValueAsInt; }
	
}




*/


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
	self.mapView = nil;
    [super dealloc];
}

@end
