//
//  AppDelegate.m
//  NatGeo Downloader
//
//  Created by James Rasmussen on 10/16/14.
//  Copyright (c) 2014 James Rasmussen. All rights reserved.
//

#import "AppDelegate.h"
#import <ServiceManagement/ServiceManagement.h>

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) NSUserDefaults *userDefaults;
@property (nonatomic) BOOL loginItemsEnabled;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [self runDownloaderScript];
    
    self.userDefaults = [NSUserDefaults standardUserDefaults];
    self.loginItemsEnabled = [self.userDefaults boolForKey:@"loginItemsEnabled"];
    if(!self.loginItemsEnabled) {
        self.loginItemsEnabled = YES;
        [self.userDefaults setBool:self.loginItemsEnabled forKey:@"loginItemsEnabled"];
        
        // add the userDefault and check it to YES
        [self.userDefaults synchronize];
        
        // add the app to login items initially.
        [self addAppAsLoginItem];
    }
    
    
    // Fire every 60 seconds
    [self.timer invalidate];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(checkIfTimeToUpdate:) userInfo:nil repeats:YES];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (void)checkIfTimeToUpdate:(NSTimer *)timer {
    
    
    NSDate *lastDownloadTime = [self.userDefaults objectForKey:@"lastDownloadTime"];
    NSLog(@"The last download time is: %@", lastDownloadTime);
    if(!lastDownloadTime || [lastDownloadTime timeIntervalSinceNow] < 0) {
        [self runDownloaderScript];
        
        //pass date into user defaults
        NSDate *nextDate = [self getNextDay2AM];
        [self.userDefaults setObject:nextDate forKey:@"lastDownloadTime"];
        [self.userDefaults synchronize];
        
    }
}

- (NSDate*)getNextDay2AM {
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitHour fromDate:[NSDate date]];
    if(components.hour > 2) {
        components.day = components.day + 1;
    }
    components.hour = 2;
    
    NSCalendar *theCalendar = [NSCalendar currentCalendar];
    NSDate *nextDate = [theCalendar dateFromComponents:components];
    return nextDate;
}

- (void)awakeFromNib {
    _statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    
    NSImage *menuIcon = [NSImage imageNamed:@"tree"];
    NSImage *highlightIcon = [NSImage imageNamed:@"tree"];
    
    [[self statusItem] setImage:menuIcon];
    [[self statusItem] setAlternateImage:highlightIcon];
    [[self statusItem] setMenu:[self menu]];
    [[self statusItem] setHighlightMode:YES];
}

- (void)runDownloaderScript {
    dispatch_async(dispatch_queue_create("downloader", DISPATCH_QUEUE_PRIORITY_DEFAULT), ^{
        NSTask *task = [[NSTask alloc] init];
        task.launchPath = @"/usr/bin/python";
        NSString *scriptPath = [[NSBundle mainBundle] pathForResource:@"downloader" ofType:@"py"];
        task.arguments = [NSArray arrayWithObjects: scriptPath, nil];

        
        NSPipe *pipe;
        pipe = [NSPipe pipe];
        [task setStandardOutput: pipe];
        
        NSFileHandle *file;
        file = [pipe fileHandleForReading];
        
        [task launch];
        
        NSData *data;
        data = [file readDataToEndOfFile];
        
        NSString *filePath;
        filePath = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
        
        NSArray *screens = [NSScreen screens];
        for(NSScreen *screen in screens) {
            NSWorkspace *workspace = [[NSWorkspace alloc] init];
            NSError *error;
            [workspace setDesktopImageURL:[NSURL fileURLWithPath:filePath] forScreen:screen options:nil error:&error];
        }
    });
}

-(void) addAppAsLoginItem{
    NSString * appPath = [[NSBundle mainBundle] bundlePath];
    
    // This will retrieve the path for the application
    // For example, /Applications/test.app
    CFURLRef url = (CFURLRef)CFBridgingRetain([NSURL fileURLWithPath:appPath]);
    
    // Create a reference to the shared file list.
    // We are adding it to the current user only.
    // If we want to add it all users, use
    // kLSSharedFileListGlobalLoginItems instead of
    //kLSSharedFileListSessionLoginItems
    LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL,
                                                            kLSSharedFileListSessionLoginItems, NULL);
    if (loginItems) {
        //Insert an item to the list.
        LSSharedFileListItemRef item = LSSharedFileListInsertItemURL(loginItems,
                                                                     kLSSharedFileListItemLast, NULL, NULL,
                                                                     url, NULL, NULL);
        if (item){
            CFRelease(item);
        }
    }
    
    CFRelease(loginItems);
}

-(void) deleteAppFromLoginItem{
    NSString * appPath = [[NSBundle mainBundle] bundlePath];
    
    // This will retrieve the path for the application
    // For example, /Applications/test.app
    CFURLRef url = (CFURLRef)CFBridgingRetain([NSURL fileURLWithPath:appPath]);
    
    // Create a reference to the shared file list.
    LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL,
                                                            kLSSharedFileListSessionLoginItems, NULL);
    if (loginItems) {
        UInt32 seedValue;
        //Retrieve the list of Login Items and cast them to
        // a NSArray so that it will be easier to iterate.
        NSArray  *loginItemsArray = (NSArray *)CFBridgingRelease(LSSharedFileListCopySnapshot(loginItems, &seedValue));
        for(int i = 0; i < [loginItemsArray count]; i++){
            LSSharedFileListItemRef itemRef = (LSSharedFileListItemRef)CFBridgingRetain([loginItemsArray
                                                                        objectAtIndex:i]);
            //Resolve the item with URL
            if (LSSharedFileListItemResolve(itemRef, 0, (CFURLRef*) &url, NULL) == noErr) {
                NSString * urlPath = [(NSURL*)CFBridgingRelease(url) path];
                if ([urlPath compare:appPath] == NSOrderedSame){
                    LSSharedFileListItemRemove(loginItems,itemRef);
                }
            }
        }
    }
}


- (IBAction)menuAction:(id)sender {
    [self runDownloaderScript];
}

- (IBAction)terminate:(id)sender {
    [NSApp terminate:self];
}

-(IBAction)toggleLaunchAtLogin:(id)sender
{
    /* TODO */
    // Grab the user defaults key and check if it's supposed to be checked (maybe when the nib loads)
    // Change the userDefault key and the login items preferences on update
    int checked = [sender state];
    
    if (checked) {
        NSLog(@"Login Items Checked");
        [self addAppAsLoginItem];
        self.loginItemsEnabled = YES;
    }
    else {
        NSLog(@"Login Items Unchecked");
        [self deleteAppFromLoginItem];
        self.loginItemsEnabled = NO;
    }
    [self.userDefaults setBool:self.loginItemsEnabled forKey:@"loginItemsEnabled"];
    [self.userDefaults synchronize];
}


@end
