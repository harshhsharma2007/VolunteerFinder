//
//  DataManager.m
//  VolunteerFinder
//
//  Created by Brian Singer on 11/11/13.
//  Copyright (c) 2013 Brian Singer. All rights reserved.
//

#import "DataManager.h"
#import "Utilities.h"
#import "AFNetworking.h"

//#define configUrl @"http://0.0.0.0:3000/feed_config.json"
#define configUrl @"http://api.allforgood.org/api/volopps"

@implementation DataManager

+ (id)instance {
    static DataManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (id)init {
    if (self = [super init]) {
    }
    return self;
}

- (void)dealloc {
    // Should never be called, but just here for clarity really.
}


- (void) syncConfigWithTarget:(id)target callback:(SEL)callback failureCallback:(SEL)failureCallback {
 
//    DebugLog(@"count: %f, %f", [[[Opp MR_findFirst] lat] floatValue], [[[Opp MR_findFirst] lon] floatValue]);
    
    //start network activity indicator
	[[Utilities instance] startActivity];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSMutableSet *acceptableTypes = [[NSMutableSet alloc] initWithSet:manager.responseSerializer.acceptableContentTypes];
    [acceptableTypes addObject:@"application/javascript"];
    [manager.responseSerializer setAcceptableContentTypes:acceptableTypes];
    [manager GET:configUrl parameters:@{@"num":@"100", @"output":@"json", @"key":@"theapptree"} success:^(AFHTTPRequestOperation *operation, id responseObject) {

        if ([responseObject objectForKey:@"items"] && [[responseObject objectForKey:@"items"] isKindOfClass:[NSArray class]]) {
            
            [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {

                [Opp MR_importFromArray:[responseObject objectForKey:@"items"] inContext:localContext];
                
            } completion:^(BOOL success, NSError *error) {
            
               [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
                  
                   //update lats and lons
                   for (NSDictionary *thisOpp in [responseObject objectForKey:@"items"]) {
                       
                       if ([thisOpp objectForKey:@"latlong"]) {
                           
                           NSString *latlong = [thisOpp objectForKey:@"latlong"];
                           NSArray *comps = [latlong componentsSeparatedByString:@","];
                           
                           if (comps && comps.count == 2) {
                               
                               float lat = [(NSString*)[comps objectAtIndex:0] floatValue];
                               float lon = [(NSString*)[comps objectAtIndex:1] floatValue];
                               
                               Opp *oppRecord = [Opp MR_findFirstByAttribute:@"oppID" withValue:[thisOpp objectForKey:@"id"] inContext:localContext];
                               [oppRecord setLat:[NSNumber numberWithFloat:lat]];
                               [oppRecord setLon:[NSNumber numberWithFloat:lon]];
                               
                           }
                           
                       }
                       
                   }
                   
               }];
            
            }];
            
        }

        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        DebugLog(@"Download art failed. Error: %@.", error);
        
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [(id)target performSelector:failureCallback withObject:nil];
        #pragma clang diagnostic pop
        
    }];
    
}

- (void) findOppsWithCenter:(CLLocationCoordinate2D)center distance:(float)dist target:(id)target callback:(SEL)callback failureCallback:(SEL)failureCallback {
    [self findOppsWithCenter:center distance:dist target:target callback:callback failureCallback:failureCallback page:1];
}

- (void) findOppsWithCenter:(CLLocationCoordinate2D)center distance:(float)dist target:(id)target callback:(SEL)callback failureCallback:(SEL)failureCallback page:(int)page {
    
    //params
    NSString *vol_loc = [[NSString alloc] initWithFormat:@"%f,%f", center.latitude, center.longitude];
    int distInt = (floorf(dist) < 1) ? 1 : floorf(dist);
    NSString *vol_dist = [[NSString alloc] initWithFormat:@"%i", distInt];
    NSString *start = [[NSString alloc] initWithFormat:@"%i", page];
    int numInt = 100;
    NSString *num = [[NSString alloc] initWithFormat:@"%i", numInt];
    
    //start network activity indicator
	[[Utilities instance] startActivity];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSMutableSet *acceptableTypes = [[NSMutableSet alloc] initWithSet:manager.responseSerializer.acceptableContentTypes];
    [acceptableTypes addObject:@"application/javascript"];
    [manager.responseSerializer setAcceptableContentTypes:acceptableTypes];
    [manager GET:configUrl parameters:@{@"num":num, @"output":@"json", @"key":@"theapptree", @"vol_loc":vol_loc, @"vol_dist":vol_dist, @"start":start} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if ([responseObject objectForKey:@"items"] && [[responseObject objectForKey:@"items"] isKindOfClass:[NSArray class]]) {
            
            [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
                
                [Opp MR_importFromArray:[responseObject objectForKey:@"items"] inContext:localContext];
                
            } completion:^(BOOL success, NSError *error) {
                
                [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
                    
                    //update lats and lons
                    for (NSDictionary *thisOpp in [responseObject objectForKey:@"items"]) {
                        
                        if ([thisOpp objectForKey:@"latlong"]) {
                            
                            NSString *latlong = [thisOpp objectForKey:@"latlong"];
                            NSArray *comps = [latlong componentsSeparatedByString:@","];
                            
                            if (comps && comps.count == 2) {
                                
                                float lat = [(NSString*)[comps objectAtIndex:0] floatValue];
                                float lon = [(NSString*)[comps objectAtIndex:1] floatValue];
                                
                                Opp *oppRecord = [Opp MR_findFirstByAttribute:@"oppID" withValue:[thisOpp objectForKey:@"id"] inContext:localContext];
                                [oppRecord setLat:[NSNumber numberWithFloat:lat]];
                                [oppRecord setLon:[NSNumber numberWithFloat:lon]];
                                
                            }
                            
                        }
                        
                    }
                    
                } completion:^(BOOL success, NSError *error) {
                    #pragma clang diagnostic push
                    #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                    [(id)target performSelector:callback withObject:nil];
                    #pragma clang diagnostic pop
                    
                    [[Utilities instance] stopActivity];
                }];
                
            }];
            
            if ([[responseObject objectForKey:@"items"] count] >= numInt && page <= 10) {
                
                [self findOppsWithCenter:center distance:dist target:target callback:callback failureCallback:failureCallback page:page+1];
                
            }
            
        }
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        DebugLog(@"Download art failed. Error: %@.", error);
        
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [(id)target performSelector:failureCallback withObject:nil];
        #pragma clang diagnostic pop
        
        [[Utilities instance] stopActivity];
        
    }];
    

    
}

@end
