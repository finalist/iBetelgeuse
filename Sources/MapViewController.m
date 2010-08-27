//
//  MapViewController.m
//  iBetelgeuse
//
//  Created by hillebrand on 16-08-10.
//  Copyright 2010 Finalist IT Group. All rights reserved.
//

#import "MapViewController.h"
#import <MapKit/MapKit.h>

@implementation MapViewController

//@synthesize locations;

- (void)registerLocations:(NSDictionary *)theLocations {
	locations = theLocations;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}

- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>) annotation{
	DebugLog(@"LOCrrrr");
    MKPinAnnotationView *annView=[[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"currentloc"] autorelease];
    annView.pinColor = MKPinAnnotationColorGreen;
    annView.animatesDrop=TRUE;
    annView.canShowCallout = YES;
    annView.calloutOffset = CGPointMake(-5, 5);
    return annView;
}

@end
