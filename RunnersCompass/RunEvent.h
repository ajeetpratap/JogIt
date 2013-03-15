//
//  RunEvent.h
//  RunnersCompass
//
//  Created by Geoff MacDonald on 2013-01-12.
//  Copyright (c) 2013 Geoff MacDonald. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RunMap.h"

@interface RunPos : NSObject{
    CGPoint pos;
    CGFloat elevation;
    NSTimeInterval pace;
    NSTimeInterval time;
}

@property (nonatomic) CGPoint pos;
@property (nonatomic) CGFloat elevation;
@property (nonatomic) NSTimeInterval pace;
@property (nonatomic) NSTimeInterval time;//seconds after the pausePoint


@end


@interface RunEvent : NSObject


typedef enum {
    EventTypeRun,
    EventTypeBike,
    EventTypeWalk,
    EventTypeHike
} RunType;

typedef enum 
{
    NoMetricType,
    MetricTypeDistance,
    MetricTypePace,
    MetricTypeTime,
    MetricTypeCalories,
    MetricTypeClimbed,
    MetricTypeCadence,
    MetricTypeStride
} RunMetric;


//meta data
@property (nonatomic) NSString *name;//customized in init, to be displayed on the logger, not the hierarchial cells
@property (nonatomic) NSDate *date;//just set to now for all events on init
@property (nonatomic) RunType eventType;//not useful yet
@property (nonatomic) RunMetric metric;
@property (nonatomic) CGFloat metricGoal;
@property (nonatomic) BOOL live;
@property (nonatomic) BOOL ghost;

//total/averages for display/data collection

//updated every 5 sec
@property (nonatomic) CGFloat distance;
@property (nonatomic) NSTimeInterval avgPace;
@property (nonatomic) CGFloat calories;
@property (nonatomic) CGFloat climbed;
@property (nonatomic) CGFloat stride;
@property (nonatomic) CGFloat cadence;
//updated every second
@property (nonatomic) NSTimeInterval time;



//data ( all arrays of RunPos) , must be strong to retain
@property (nonatomic, strong) NSMutableArray * pos; //actual CLLocation positions
@property (nonatomic, strong) NSMutableArray * distanceCheckpoints; //metrics @ km checkpoints
@property (nonatomic, strong) NSMutableArray * checkpoints; //metrics by time unit for graph
@property (nonatomic, strong) NSMutableArray * pausePoints; //NSDate for pauses
@property (nonatomic, strong) RunMap *map;


-(id)initWithTarget:(RunMetric)type withValue:(CGFloat)value;
-(id)initWithNoTarget;

+(NSString * )stringForMetric:(RunMetric) metric;


@end
