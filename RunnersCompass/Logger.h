//
//  CompassSecondViewController.h
//  RunnersCompass
//
//  Created by Geoff MacDonald on 2012-10-30.
//  Copyright (c) 2012 Geoff MacDonald. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "RunEvent.h"
#import "JSSlidingViewController.h"
#import "CorePlot-CocoaTouch.h"
#import "DataTest.h"
#import "CrumbPath.h"
#import "CrumbPathView.h"
#import "Util.h"


#define mapZoomDefault 500 //m
#define mapViewYOffset 173
#define mapDragCutoff 250
#define mapDragPreventOpposite 5
#define mapDragPullYOffset 20
#define paceGraphBarWidth 25
#define paceGraphSplitLoadOffset 20
#define paceGraphSplitObjects 30
#define kSelectedPlot @"selected"
#define kPlot @"plot"
#define logRequiredAccuracy 50 //50m maximum

#define IS_IPHONE5 (([[UIScreen mainScreen] bounds].size.height-568)?NO:YES)


@protocol LoggerViewControllerDelegate <NSObject>

- (void)menuButtonPressed:(id)sender;
- (void)finishedRun:(RunEvent *)run;
- (void)pauseAnimation:(void(^)(void))completion;
-(void)selectedGhostRun:(RunEvent *)run;

@end



@interface LoggerViewController : UIViewController <JSSlidingViewControllerDelegate,CPTPlotDataSource,CPTBarPlotDelegate,UIScrollViewDelegate,UIActionSheetDelegate,CLLocationManagerDelegate,MKMapViewDelegate>
{
    UIActionSheet *sheet;
    NSInteger selectedBarIndex;
    CPTXYGraph *barChart;
    NSTimer *timer;
    CPTBarPlot * selectedPlot;
    CPTBarPlot * barPlot;
    CPTXYPlotSpace *plotSpace;
    NSInteger lastCacheMinute;
    BOOL scrollEnabled;
    BOOL paused;
    BOOL inMapView;
    UIScrollView *mapScroll;
    NSTimer * shadeTimer;
    CGFloat countdown;
    BOOL kmPaceShowMode;
    NSUInteger numMinutesAtKmSelected;
    CLLocationManager *locationManager;
    NSMutableArray *crumbPaths;
    NSMutableArray *crumbPathViews;
    NSTimeInterval timeSinceMapCenter;
    NSTimeInterval timeSinceMapIconRefresh;
    NSTimeInterval lastMapTouch;
    NSTimeInterval lastCalculate;
    BOOL readyForPathInit;
    NSInteger badSignalCount;
    NSInteger consecutiveHeadingCount;
    NSInteger timeSinceChartReload;
}


//delegate
@property (weak, nonatomic) id <LoggerViewControllerDelegate>delegate;

//objects
@property (nonatomic, strong, setter = setRun:) RunEvent * run;
@property (nonatomic) BOOL paused;


//UI
@property (strong, nonatomic)  IBOutlet MKMapView *map;
@property (strong, nonatomic) IBOutlet UILabel *runTitle;
@property (strong, nonatomic) IBOutlet UIView *mapView;
@property (strong, nonatomic) IBOutlet UIPanGestureRecognizer *panGesture;
@property (strong, nonatomic) IBOutlet UIButton *statusBut;
@property (strong, nonatomic) IBOutlet CPTGraphHostingView *chart;
@property (strong, nonatomic) IBOutlet UIButton *finishBut;
@property (strong, nonatomic) IBOutlet UIButton *mapButton;
@property (strong, nonatomic) IBOutlet UIView *shadeView;
@property (strong, nonatomic) IBOutlet UIButton *dragButton;
@property (strong, nonatomic) IBOutlet UILabel *countdownLabel;
@property (strong, nonatomic) IBOutlet UIScrollView *paceScroll;
@property (strong, nonatomic) IBOutlet UILabel *oldpace1;
@property (strong, nonatomic) IBOutlet UILabel *oldpace2;
@property (strong, nonatomic) IBOutlet UILabel *oldpace3;
@property (strong, nonatomic) IBOutlet UILabel *currentPaceLabel;
@property (strong, nonatomic) IBOutlet UILabel *currentPaceValue;
@property (strong, nonatomic) IBOutlet UIButton *invisibleLastKmButton;
@property (strong, nonatomic) IBOutlet UILabel *lastKmLabel;
@property (strong, nonatomic) IBOutlet UILabel *lastKmPace;
@property (strong, nonatomic) IBOutlet UIImageView *goalAchievedImage;
@property (strong, nonatomic) IBOutlet UILabel *distanceUnitLabel;
@property (strong, nonatomic) IBOutlet UILabel *paceUnitLabel1;
@property (strong, nonatomic) IBOutlet UILabel *paceUnitLabel2;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) IBOutlet UILabel *distanceLabel;
@property (strong, nonatomic) IBOutlet UILabel *caloriesLabel;
@property (strong, nonatomic) IBOutlet UILabel *paceLabel;
@property (strong, nonatomic) IBOutlet UIButton *ghostBut;
@property (strong, nonatomic) IBOutlet UILabel *caloriesTitle;
@property (strong, nonatomic) IBOutlet UILabel *avgPaceTitle;
@property (strong, nonatomic) IBOutlet UILabel *distanceTitle;
@property (strong, nonatomic) IBOutlet UILabel *timeTitle;
@property (strong, nonatomic) IBOutlet UILabel *swipeToPauseLabel;



//IB
- (IBAction)hamburgerTapped:(id)sender;
- (IBAction)handlePanGesture:(id)sender;
- (IBAction)mapIconTapped:(id)sender;
- (IBAction)finishTapped:(id)sender;
- (IBAction)invisibleButtonTapped:(id)sender;
- (IBAction)statusButTapped:(id)sender;
- (IBAction)ghostButTapped:(id)sender;

-(void) stopRun;
- (void)newRun:(RunEvent*)newRunTemplate animate:(BOOL)animate;

@end

#define RAD_TO_DEG(r) ((r) * (180 / M_PI))

@interface CLLocation (Direction)
- (CLLocationDirection)directionToLocation:(CLLocation *)location;
@end

// .m
@implementation CLLocation (Direction)

- (CLLocationDirection)directionToLocation:(CLLocation *)location {
    
    CLLocationCoordinate2D coord1 = self.coordinate;
    CLLocationCoordinate2D coord2 = location.coordinate;
    
    CLLocationDegrees deltaLong = coord2.longitude - coord1.longitude;
    CLLocationDegrees yComponent = sin(deltaLong) * cos(coord2.latitude);
    CLLocationDegrees xComponent = (cos(coord1.latitude) * sin(coord2.latitude)) - (sin(coord1.latitude) * cos(coord2.latitude) * cos(deltaLong));
    
    CLLocationDegrees radians = atan2(yComponent, xComponent);
    CLLocationDegrees degrees = RAD_TO_DEG(radians) + 360;
    
    return fmod(degrees, 360);
}

@end
