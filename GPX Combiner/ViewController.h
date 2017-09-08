//
//  ViewController.h
//  GPX Combiner
//
//  Created by Tyler Williamson on 9/6/17.
//  Copyright © 2017 Tyler Williamson Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <MapKit/MapKit.h>
#import "GPXKit.h"
#import "GPXTrack.h"

@interface ViewController : NSViewController <MKMapViewDelegate>

@property IBOutlet MKMapView *mapView;
- (IBAction) openGPXFiles:(id) sender;
- (IBAction) saveGPXFile:(id) sender;

@end

