//
//  AppDelegate.h
//  image2video
//
//  Created by Jared Bruni on 9/30/18.
//  Copyright © 2018 Jared Bruni. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Controller.h"

@interface AppDelegate : NSObject <NSApplicationDelegate> {
    IBOutlet Controller *controller;
}

@end

