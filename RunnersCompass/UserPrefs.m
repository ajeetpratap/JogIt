//
//  UserPrefs.m
//  RunnersCompass
//
//  Created by Geoff MacDonald on 2013-02-06.
//  Copyright (c) 2013 Geoff MacDonald. All rights reserved.
//

#import "UserPrefs.h"

@implementation UserPrefs

@synthesize facebook,twitter,autopause,weight,fullname,birthdate,metric,countdown;

+ (id)defaultUser{
    UserPrefs * new = [[UserPrefs alloc] init];
    
    new.countdown = [NSNumber numberWithInt:3];
    new.autopause = [NSNumber numberWithInt:0];
    new.twitter = [NSNumber numberWithInt:0];
    new.facebook = [NSNumber numberWithInt:0];
    //find systems default unit measure
    NSLocale *locale = [NSLocale currentLocale];
    BOOL isMetric = [[locale objectForKey:NSLocaleUsesMetricSystem] boolValue];
    new.metric = [NSNumber numberWithInt:isMetric];
    new.weight = [NSNumber numberWithInt:150];
    
    //best to leave these blank so user does not have to backspace them
    new.fullname = nil;
    new.birthdate = nil;
    
    return new;
}

-(NSString*)getDistanceUnit
{
    
    //should not need to be translated
    
    if([self.metric boolValue])
        return NSLocalizedString(@"KmMetricUnitShort", @"shortform for km");
    else
        return NSLocalizedString(@"MiImperialUnitShort", @"shortform for mi");
    
}


-(NSString*)getTimeString:(NSTimeInterval) f
{
    //should not need to be converted to other units just hh:mm
    
    
    NSString * stringToReturn;
    
    NSInteger minutes = f / 60;
    NSInteger seconds = f - (minutes * 60);
    
    stringToReturn = [NSString stringWithFormat:@"%d:%d", minutes, seconds];
    
    return stringToReturn;
    
    
}


-(NSString*)getTimeStringWithSeconds:(NSTimeInterval) f
{
    //should not need to be converted to other units just hh:mm:ss
    
    NSString * stringToReturn;
    
    NSInteger hours = f / 3600;
    NSInteger minutes = f - (hours * 3600);
    NSInteger seconds = f - (minutes * 60);
    
    stringToReturn = [NSString stringWithFormat:@"%d:%d:%d", hours, minutes, seconds];
    
    return stringToReturn;
}



@end
