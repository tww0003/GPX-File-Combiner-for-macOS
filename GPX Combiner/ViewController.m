//
//  ViewController.m
//  GPX Combiner
//
//  Created by Tyler Williamson on 9/6/17.
//  Copyright © 2017 Tyler Williamson Software. All rights reserved.
//

#import "ViewController.h"


@interface ViewController()

@property NSXMLDocument *gpxFile;

@end
@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.mapView.mapType = MKMapTypeHybrid;
    
}

- (void) startGPXCombination:(NSArray *) urls {
    self.gpxFile = nil;
    [self.mapView removeOverlays:self.mapView.overlays];
    [self.mapView removeAnnotations:self.mapView.annotations];
    NSMutableArray *gpxTracks = [NSMutableArray new];
    
    for(NSURL *url in urls){
        GPXParser *parser = [[GPXParser alloc] init];
        if([parser parseDocumentWithURL:url]){
            [gpxTracks addObject:[parser tracks]];
        }
    }
    
    NSMutableArray *wayPoints = [NSMutableArray new];
    for(NSArray *trackArray in gpxTracks) {
        GPXTrack *track = (GPXTrack *) trackArray[0];
        [wayPoints addObjectsFromArray:[track trackPoints]];
    }
    
    GPXRoute *fullRoute = [[GPXRoute alloc] init];
    fullRoute.wayPoints = wayPoints;
    fullRoute.routeName = @"Full Route";
    NSXMLElement *root = [[NSXMLElement alloc] initWithName:@"gpx"];
    [root addAttribute:[NSXMLNode attributeWithName:@"creator" stringValue:@"StravaGPX iPhone"]];
    [root addAttribute:[NSXMLNode attributeWithName:@"xmlns" stringValue:@"http://www.topografix.com/GPX/1/1"]];
    [root addAttribute:[NSXMLNode attributeWithName:@"version" stringValue:@"1.1"]];
    [root addAttribute:[NSXMLNode attributeWithName:@"xmlns:xsi" stringValue:@"http://www.w3.org/2001/XMLSchema-instance"]];
    [root addAttribute:[NSXMLNode attributeWithName:@"xsi:schemaLocation" stringValue:@"http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd http://www.garmin.com/xmlschemas/GpxExtensions/v3 http://www.garmin.com/xmlschemas/GpxExtensionsv3.xsd http://www.garmin.com/xmlschemas/TrackPointExtension/v1 http://www.garmin.com/xmlschemas/TrackPointExtensionv1.xsd"]];

    NSXMLElement *childElement1 = [[NSXMLElement alloc] initWithName:@"metadata"];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZZ"];
    [childElement1 addChild:[[NSXMLElement alloc] initWithName:@"time" stringValue:[df stringFromDate:[NSDate new]]]];
    [root addChild:childElement1];
    
    NSXMLElement *childElement2 = [[NSXMLElement alloc] initWithName:@"trk"];
    [childElement2 addChild:[[NSXMLElement alloc] initWithName:@"name" stringValue:@"FullRoute"]];
    CLLocationCoordinate2D coordinates[fullRoute.wayPoints.count];
    int i = 0;
    double west = 0;
    double east = 0;
    double north = 0;
    double south = 0;
    for(GPXWaypoint *wayPoint in fullRoute.wayPoints){
        if(i == 0){
            MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
            [annotation setCoordinate:CLLocationCoordinate2DMake(wayPoint.latitude, wayPoint.longitude)];
            [annotation setTitle:@"Start"];
            [self.mapView addAnnotation:annotation];

            west = wayPoint.longitude;
            east = wayPoint.longitude;
            north = wayPoint.latitude;
            south = wayPoint.latitude;
        } else {
            if(wayPoint.longitude < west){
                west = wayPoint.longitude;
            }
            if (wayPoint.longitude > east){
                east = wayPoint.longitude;
            }
            if(wayPoint.latitude > north) {
                north = wayPoint.latitude;
            }
            if(wayPoint.latitude < south){
                south = wayPoint.latitude;
            }
        }
        if (i == fullRoute.wayPoints.count - 1){
            MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
            [annotation setCoordinate:CLLocationCoordinate2DMake(wayPoint.latitude, wayPoint.longitude)];
            [annotation setTitle:@"Finish"];
            [self.mapView addAnnotation:annotation];
            
        }
        CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(wayPoint.latitude, wayPoint.longitude);
        coordinates[i] = coord;
        i++;
        NSXMLElement *trkseg = [[NSXMLElement alloc] initWithName:@"trkseg"];
        [childElement2 addChild:trkseg];

        NSXMLElement *trkpt = [[NSXMLElement alloc] initWithName:@"trkpt"];
        [trkpt addAttribute:[NSXMLNode attributeWithName:@"lat" stringValue:[NSString stringWithFormat:@"%f", wayPoint.latitude]]];
        [trkpt addAttribute:[NSXMLNode attributeWithName:@"lon" stringValue:[NSString stringWithFormat:@"%f", wayPoint.longitude]]];
        [trkpt addChild:[[NSXMLElement alloc] initWithName:@"ele" stringValue:[NSString stringWithFormat:@"%f", wayPoint.elevation]]];
        [trkpt addChild:[[NSXMLElement alloc] initWithName:@"time" stringValue:[NSString stringWithFormat:@"%@", wayPoint.time]]];
        [trkseg addChild:trkpt];
    }
    MKPolyline *routeLine = [MKPolyline polylineWithCoordinates:coordinates count:fullRoute.wayPoints.count];
    [self.mapView addOverlay:routeLine];
    double longitude = (west + east) / 2;
    double latitude = (north + south) / 2;
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(latitude, longitude);
    [self.mapView setRegion:MKCoordinateRegionMake(center, MKCoordinateSpanMake((east-west) + .2, (north-south) + .2)) animated:YES];
    [self.mapView updateLayer];
    [root addChild:childElement2];
    
    NSXMLDocument *xmlRequest = [NSXMLDocument documentWithRootElement:root];
    [xmlRequest setVersion:@"1.0"];
    [xmlRequest setCharacterEncoding:@"UTF-8"];
    self.gpxFile = xmlRequest;
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    if ([overlay isKindOfClass:[MKPolyline class]])
    {
        MKPolylineRenderer *pr = [[MKPolylineRenderer alloc] initWithPolyline:overlay];
        pr.strokeColor = [NSColor blueColor];
        pr.lineWidth = 5;
        return pr;
    }
    
    return nil;
}

- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    
    if([annotation.title isEqualToString:@"Start"]){
        MKPinAnnotationView *start = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"start"];
        [start setAnimatesDrop:YES];
        [start setPinTintColor:[NSColor greenColor]];
        return start;
    } else if ([annotation.title isEqualToString:@"Finish"]){
        MKPinAnnotationView *end = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"start"];
        [end setAnimatesDrop:YES];
        [end setPinTintColor:[NSColor redColor]];
        return end;

    }
    return nil;
}

- (IBAction) openGPXFiles:(id) sender {
    [[NSApplication sharedApplication] mainMenu];
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    
    [panel setCanChooseFiles:YES];
    [panel setCanChooseDirectories:NO];
    [panel setAllowsMultipleSelection:YES];
    [panel setAllowedFileTypes:@[@"gpx"]];
    
    [panel beginWithCompletionHandler:^(NSInteger result){
        if (result == NSFileHandlingPanelOKButton) {
            [self startGPXCombination:[panel URLs]];
            [panel close];
        }
    }];

}

- (IBAction) saveGPXFile:(id) sender {
    if(!self.gpxFile) return;
    
    NSOpenPanel *openPanel	= [NSOpenPanel openPanel];
    [openPanel setCanChooseDirectories:YES];
    [openPanel setCanChooseFiles:NO];
    [openPanel setPrompt:@"Save"];
    NSXMLNode *nameElement = [[[self.gpxFile rootElement] children][1] children][0];
    
    [openPanel setNameFieldStringValue:[NSString stringWithFormat:@"%@.gpx", nameElement.stringValue]];
    [openPanel beginWithCompletionHandler:^(NSInteger integer){
        if(integer == NSModalResponseOK){
            NSData *document = [self.gpxFile XMLDataWithOptions:NSXMLNodePrettyPrint];
            NSError *error = nil;
            NSURL *saveURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@.gpx",[[openPanel URL] absoluteString], nameElement.stringValue]];
            BOOL res = [document writeToURL:saveURL options:NSDataWritingAtomic error:&error];
            if (!res) {
                NSLog(@"Unable to write to %@: %@", [openPanel nameFieldLabel], error);
            }
        } else {
            return;
        }
    }];
}

@end
