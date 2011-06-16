//
//  ArcGISTest1AppDelegate.m
//  ArcGISTest1
//
//  Created by Chris Burns on 11-05-04.
//  Copyright University of Calgary. 2011. All rights reserved.
//

#import "ArcGISTest1AppDelegate.h"
#import "ArcGISTest1ViewController.h"
#import "MBProgressHUD.h"
#import "Reachability.h"

@implementation ArcGISTest1AppDelegate

@synthesize window;
@synthesize viewController;




- (void)applicationDidFinishLaunching:(UIApplication *)application {    
    
	/*
	
	//Send a request to server for a port number to setup socket connections 
	sender = [[MethodSender alloc] init];
	[sender registerDevice:self andSelector:@selector(setupMethodReceiver:)]; //target = self, action = setupMethodReceiver
	
	
	
	hud = [[MBProgressHUD alloc] initWithView:self.viewController.view]; 
	hud.labelText = @"Connecting to Surface";
	
	[self.viewController.view addSubview:hud]; 
	
	[hud show:YES]; 
	 
	*/
	
	[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(reachabilityChanged:) name: kReachabilityChangedNotification object: nil];
	
    //Change the host name here to change the server your monitoring
	reach = [[Reachability reachabilityForInternetConnection] retain]; 
	[reach startNotifier];
	
	
    // Override point for customization after app launch    
    [window addSubview:viewController.view];
    [window makeKeyAndVisible];
}

//Called by Reachability whenever status changes.
- (void) reachabilityChanged: (NSNotification* )note {
	
	UIAlertView *alert = [[UIAlertView alloc]
						  initWithTitle: @"Lost Connection"
						  message: @"You have lost connection to the internet"
						  delegate: nil
						  cancelButtonTitle:@"OK"
						  otherButtonTitles:nil];
	[alert show];
	[alert release];
	
}

/*

Setup Method Receiver -  Receives from the Server a valid port number that corresponds to a socket created 
 for it's use. A method receiver will then access this port and listen on it for new MethodCalls
- (void) setupMethodReceiver: (NSData*) portAsData {

	[hud hide:YES]; 
	
	NSString *portAsString = [[[NSString alloc] initWithData:portAsData encoding:NSUTF8StringEncoding] deserializeString]; 
	
	//Instantiate the receiver object using the port returned from the server
	receiver = [[MethodReceiver alloc] initWithPort:[portAsString integerValue]];
	[receiver startReceiving]; //Begins receiving 

	//For the current view the returned port may have arrived after the view controller was loaded. Call it's "registerAsMethodResponder" method
	[viewController registerAllListeners];

	
}

*/













- (void)dealloc {
    [viewController release];
    [window release];
	[reach release]; 
    [super dealloc];
}


@end
