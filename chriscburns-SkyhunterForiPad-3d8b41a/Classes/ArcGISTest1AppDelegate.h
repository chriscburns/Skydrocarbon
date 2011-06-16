//
//  ArcGISTest1AppDelegate.h
//  ArcGISTest1
//
//  Created by Chris Burns on 11-05-04.
//  Copyright University of Calgary. 2011. All rights reserved.
//

#import <UIKit/UIKit.h>


@class ArcGISTest1ViewController;
@class MBProgressHUD; 

@interface ArcGISTest1AppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    ArcGISTest1ViewController *viewController;
	

	
	MBProgressHUD *hud; 
	
	
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet ArcGISTest1ViewController *viewController;




@end

