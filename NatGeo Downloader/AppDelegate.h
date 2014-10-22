//
//  AppDelegate.h
//  NatGeo Downloader
//
//  Created by James Rasmussen on 10/16/14.
//  Copyright (c) 2014 James Rasmussen. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (readwrite, retain) IBOutlet NSMenu *menu;
@property (readwrite, retain) IBOutlet NSStatusItem *statusItem;
@property (assign) IBOutlet NSButton *launchAtLoginButton;

- (IBAction)menuAction:(id)sender;
- (IBAction)terminate:(id)sender;
-(IBAction)toggleLaunchAtLogin:(id)sender;

@end

