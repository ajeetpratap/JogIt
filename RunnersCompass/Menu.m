//
//  MenuViewController.m
//  RunnersCompass
//
//  Created by Geoff MacDonald on 2012-10-30.
//  Copyright (c) 2012 Geoff MacDonald. All rights reserved.
//

#import "Menu.h"
#import "Constants.h"
#import "RunEvent.h"
#import "Logger.h"
#import "JSSlidingViewController.h"
#import "PerformanceVC.h"
#import "SettingsViewController.h"
#import "GoalsViewController.h"
#import "CreateGoalViewController.h"
#import "RunFormPicker.h"
#import "Analysis.h"

#import "SJCell.h"



@implementation MenuViewController

@synthesize MenuTable;
@synthesize runInProgressAsFarAsICanTell;
@synthesize settingsBut,performanceBut,goalsBut;
@synthesize runningManImage,noRunsLabel;
@synthesize noRunView;

static NSString * cellID = @"HierarchicalCellPrototype";

#pragma mark -
#pragma mark View Lifecycle


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
	core = [DataTest sharedData];
    
    if(!start)
    {
        StartCell * cell  =  [[[NSBundle mainBundle]loadNibNamed:@"StartCell"
                                                           owner:self
                                                         options:nil]objectAtIndex:0];
        [cell setup];
        [cell setDelegate:self];
        
        start = cell;
    }
    
    runs = [[NSMutableArray alloc] initWithCapacity:3];
    cells = [[NSMutableArray alloc] initWithCapacity:3];
    
    
    RunMap * map = [RunMap alloc];

    [map setThumbnail:[UIImage imageNamed:@"map.JPG"]];
    
    for(NSInteger i=0;i <80; i++)
    {
    
        
        //load most recent run on startup, but not intended any other time
        RunEvent * loadRun = [[RunEvent alloc] initWithNoTarget];
        
        //for every 10 days before today 
        [loadRun setDate:[loadRun.date dateByAddingTimeInterval:-(86400 * i * 10)]];
                          
        [loadRun setLive:false];
        
        loadRun.calories = arc4random() % 300;
        loadRun.time = arc4random() % 4000;
        loadRun.avgPace = arc4random() % 7;
        loadRun.distance = arc4random() % 10000;
        [loadRun setMap:map];
        
        [runs addObject:loadRun];
        
    }
    
    
    
    runInProgressAsFarAsICanTell = false;
    
    //no run stuff
    showingNoRuns = false;
    [noRunsLabel setText:NSLocalizedString(@"NoRunsLabel", @"label describing no runs in menu")];
    
    
    //load cell
    [MenuTable registerClass:[HierarchicalCell class] forCellReuseIdentifier:cellID];
    UINib * nib = [UINib nibWithNibName:@"HierarchicalCell" bundle:[NSBundle mainBundle]] ;
    [MenuTable registerNib:nib forCellReuseIdentifier:cellID];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark Menu Table data source

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tv
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{

    CGFloat height = [start getHeightRequired];
    
    
    return height;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if(section == 0)
    {
        if(!start)
        {
            StartCell * cell  =  [[[NSBundle mainBundle]loadNibNamed:@"StartCell"
                                                               owner:self
                                                             options:nil]objectAtIndex:0];
            [cell setDelegate:self];
            [cell setup];
            
            start = cell;
        }
        
        return start;
        
    }
    
    return nil;
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    if([runs count] == 0)
    {
        //if no runs exist, then display running man
        showingNoRuns = true;
        
        [MenuTable setBackgroundView:noRunView];
        
    }
    else{
        if(showingNoRuns)
        {
            showingNoRuns = false;
            [MenuTable setBackgroundView:nil];
        }
    }
    
    //return number of historic run
    return [runs count];
}

// Customize the appearance of table view cells.
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = [indexPath row];
    

    if(row >= [cells count]){
        
        HierarchicalCell * cell = (HierarchicalCell * )[tableView dequeueReusableCellWithIdentifier:cellID];
        
        [cells addObject:cell];
        [cell setDelegate:self];
        [cell setAssociated:[runs objectAtIndex:row]];

        
        return cell;
    }
    else{
        
        
        HierarchicalCell * curCell = [cells objectAtIndex:row];
        
        return curCell;
    }
    
    
    
}


#pragma mark -
#pragma mark Menu Table delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height;
    NSUInteger row = [indexPath row];
    
    if(row >= [cells count]){
        
        HierarchicalCell * cell = (HierarchicalCell * )[tableView dequeueReusableCellWithIdentifier:cellID];
        
        [cells addObject:cell];
        [cell setDelegate:self];
        [cell setAssociated:[runs objectAtIndex:row]];
        
        height = 48.0f;
    }
    else{
        
        HierarchicalCell * cell = [cells objectAtIndex:row];
        
        height = [cell getHeightRequired];
    }

    return height;
}




-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = [indexPath row];
    
    //shouldnt happen
    if(row > ([cells count]))
        return;
    
    
    HierarchicalCell * cell = [cells objectAtIndex:row];
    
    if(!cell.expanded)
    {
        [cell setExpand:true withAnimation:true];
        
        if(row == [cells count])
        {
            //scroll view to see rest of cell below
            [MenuTable scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:true];
        }
    }
    else{
        [cell setExpand:false withAnimation:true];
    }
}


#pragma mark -
#pragma mark HierarchicalCellDelegate

-(void) cellDidChangeHeight:(id) sender
{
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"resetCellDeletionModeAfterTouch"
                                                        object:nil];
    
    //animate with row belows move down nicely
    [MenuTable beginUpdates];
    [MenuTable endUpdates];
    [MenuTable reloadData];//needed to have user interaction on start cell if this is expanded, also removes white line issue
    
    
    //if sender was last cell or second last, then scroll to show expanded view
    //ensure there is at least something to avoid crash from pressing the startcell
    if(sender == [cells lastObject])
    {
        NSIndexPath *path = [MenuTable indexPathForCell:sender];
        [MenuTable scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionNone animated:true];
    }
    else if([cells count] > 1 )
    {
        if(sender == [cells objectAtIndex:([cells count] - 2)])
        {
            NSIndexPath *path = [MenuTable indexPathForCell:sender];
            [MenuTable scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionNone animated:true];
        }
    }
}

-(void)updateGestureFailForCell:(UIGestureRecognizer*)cellGesture
{
    
    [self.delegate updateGesturesNeededtoFail:cellGesture];
}

#pragma mark -
#pragma mark Start Cell Delegate

-(void)selectedRunInProgress:(BOOL)shouldDiscard
{
    //selected the headerview of start cell when run is in progress, slide back to logger
    [self.delegate selectedRunInProgress:shouldDiscard];

}

-(void)selectedNewRun:(RunEvent *) run
{
    [self cleanupForNav];
    
    //set logger with this run
    [self.delegate newRun:run animate:true];
    
    
    //modifiy header to indicate progressing run
    runInProgressAsFarAsICanTell = true;
    [start.timeLabel setHidden:false];
    start.headerLabel.text = NSLocalizedString(@"RunInProgressTitle", @"start cell title for runs in progress");
    [start setExpand:false withAnimation:true];
    start.locked = true;//to prevent expanding
    [start.garbageBut setHidden:false];
    [start.addRunButton setHidden:true];
    [start.folderImage setHidden:true];
    
}


#pragma mark -
#pragma mark Logger Interface

//also heierachical cell delegate method
-(void)selectedRun:(id)sender
{
    [self cleanupForNav];
    
    if(!runInProgressAsFarAsICanTell)
    {
        HierarchicalCell * cell = (HierarchicalCell * )sender;
        
        //set logger with this run
        [self.delegate loadRun:cell.associatedRun close:true];
        
        //refresh start cell
        runInProgressAsFarAsICanTell = false;
        [start.timeLabel setHidden:true];
        [start.headerLabel setText:NSLocalizedString(@"StartRunTitle", @"Title for start cell")];
        start.locked = false;//to prevent expanding
        [start.garbageBut setHidden:true];
        [start.addRunButton setHidden:false];
        [start.folderImage setHidden:false];
    
    }
    else{
        //shake run in progress title
        [AnimationUtil shakeView:start.headerLabel];
    }
}

-(void) finishedRun:(RunEvent*)run
{
    
    //save run and add it to the menu if it exists
    if(run)
    {
        //must be at 0th index to be at top and reload correctly
        [runs insertObject:run atIndex:0];
        [MenuTable insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationLeft];
        [cells removeAllObjects];
        [MenuTable reloadData];
    }
    
    //refresh start cell
    runInProgressAsFarAsICanTell = false;
    [start.timeLabel setHidden:true];
    [start.headerLabel setText:NSLocalizedString(@"StartRunTitle", @"Title for start cell")];
    start.locked = false;//to prevent expanding
    [start.garbageBut setHidden:true];
    [start.addRunButton setHidden:false];
    [start.folderImage setHidden:false];
}

-(void)updateTimeString:(NSString *)updatedTimeString
{
    //update label
    [start.timeLabel setText:updatedTimeString];
    
}

#pragma mark -
#pragma mark Action sheet delegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    NSLog(@"Button %d", buttonIndex);
    
    //for discarding active run
    if(buttonIndex == 0)
    {
        //pass nil
        [self.delegate finishedRun:nil];
    }
}


#pragma mark -
#pragma mark Nav Bar Action

-(void)cleanupForNav
{
    //stuff to do before navigation like take down garbage cans
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"resetCellDeletionModeAfterTouch"
                                                        object:nil];
}
- (IBAction)performanceNavPressed:(id)sender {
    
    //nav bar cleanup
    [self cleanupForNav];
    
    //prepare analyze data
    //fake analysis data
    Analysis * analysisToSet = [[Analysis alloc] setupFakeWithRuns:runs];
    [core setAnalysis:analysisToSet];
    
    PerformanceVC * vc = [[PerformanceVC alloc] initWithNibName:@"Performance" bundle:nil];
    [self presentViewController:vc animated:true completion:nil];
}
- (IBAction)goalsNavPressed:(id)sender {
    
    //nav bar cleanup
    [self cleanupForNav];
    
    if(!core.curGoal)
    {
        GoalsViewController * vc = [[GoalsViewController alloc] initWithNibName:@"Goals" bundle:nil];
        CreateGoalViewController * vc2 = [[CreateGoalViewController alloc] initWithNibName:@"CreateGoal" bundle:nil];
        
        [self presentViewController:vc animated:true completion:^{
            
            [vc presentViewController:vc2 animated:true completion:nil];
        }];
    }
    else
    {
        GoalsViewController * vc = [[GoalsViewController alloc] initWithNibName:@"Goals" bundle:nil];
        
        [self presentViewController:vc animated:true completion:nil];
    }
}

- (IBAction)settingsNavPressed:(id)sender {
    
    //nav bar cleanup
    [self cleanupForNav];
    
    SettingsViewController * vc = [[SettingsViewController alloc] initWithNibName:@"Settings" bundle:nil];
    
    [self presentViewController:vc animated:true completion:nil];
}

#pragma mark -
#pragma mark StartCell Actions

-(void)paceRunStart:(NSNumber*)selectedIndex
{
    CGFloat pace = [selectedIndex integerValue] ; //min/km to m/s
    
    RunEvent * new = [[RunEvent alloc] initWithTarget:MetricTypePace withValue:pace];
    
    [self selectedNewRun:new];
    
}
-(void)distanceRunStart:(NSNumber*)selectedIndex
{
    CGFloat distance = 0.5 + ([selectedIndex intValue] * 0.5);
    
    RunEvent * new = [[RunEvent alloc] initWithTarget:MetricTypeDistance withValue:distance*1000];
    
    [self selectedNewRun:new];
    
}
-(void)timeRunStart:(NSNumber*)selectedIndex
{
    NSTimeInterval time = ([selectedIndex intValue] * 60);
    
    RunEvent * new = [[RunEvent alloc] initWithTarget:MetricTypeTime withValue:time];
    
    [self selectedNewRun:new];
    
}
-(void)caloriesRunStart:(NSNumber*)selectedIndex
{
    CGFloat calories = 25 + ([selectedIndex intValue] * 25);
    
    RunEvent * new = [[RunEvent alloc] initWithTarget:MetricTypeCalories withValue:calories];
    
    [self selectedNewRun:new];
    
}
-(void)justGoStart
{
    
    RunEvent * new = [[RunEvent alloc] initWithNoTarget];
    
    [self selectedNewRun:new];
    
}
- (IBAction)paceTapped:(id)sender {
    PacePicker *pace = [[PacePicker alloc] initWithTitle:[NSString stringWithFormat:@"Pace (min/%@)", [core.prefs getDistanceUnit]]  rows:nil initialSelection:0 target:self successAction:@selector(paceRunStart:) cancelAction:@selector(actionPickerCancelled:) origin:sender];
    
    [pace addCustomButtonWithTitle:@"PR" value:nil];
    
    [pace showRunFormPicker];
    
}
- (IBAction)timeTapped:(id)sender {
    
    TimePicker *time = [[TimePicker alloc] initWithTitle:@"Time" rows:nil initialSelection:0 target:self successAction:@selector(timeRunStart:) cancelAction:@selector(actionPickerCancelled:) origin:sender];
    
    [time addCustomButtonWithTitle:@"PR" value:nil];
    
    [time showRunFormPicker];
}

- (IBAction)calorieTapped:(id)sender {
    CaloriePicker *cal = [[CaloriePicker alloc] initWithTitle:@"Calories" rows:nil initialSelection:0 target:self successAction:@selector(caloriesRunStart:) cancelAction:@selector(actionPickerCancelled:) origin:sender];
    
    [cal addCustomButtonWithTitle:@"PR" value:nil];
    
    [cal showRunFormPicker];
}

- (IBAction)justGoTapped:(id)sender {
    
    [self justGoStart];
}

- (IBAction)distanceTapped:(id)sender {
    
    
    DistancePicker *distance = [[DistancePicker alloc] initWithTitle:[NSString stringWithFormat:@"Distance (%@)", [core.prefs getDistanceUnit]] rows:nil initialSelection:0 target:self successAction:@selector(distanceRunStart:) cancelAction:@selector(actionPickerCancelled:) origin:sender];
    
    [distance addCustomButtonWithTitle:@"PR" value:nil];
    
    [distance showRunFormPicker];
}

- (IBAction)garbageTapped:(id)sender {
    
    //remove cell
    UIButton * cellButtonTapped = sender;
    NSUInteger indexOfCell = 10000;
    
    //must find owner of the button that this was tapped by
    for(int i = 0; i < [cells count]; i++)
    {
        if([cellButtonTapped isDescendantOfView:[cells objectAtIndex:i]])
        {
            indexOfCell = i;
            break;
        }
    }
    
    if(indexOfCell != 10000)
    {
        HierarchicalCell * cellToDelete = [cells objectAtIndex:indexOfCell];
        
        //gauranteed to be the correct row number since the array is reloaded along with the table
        NSIndexPath * indexToDelete = [NSIndexPath indexPathForRow:indexOfCell inSection:0];
        
        NSArray *arrayToDeleteCells = [NSArray arrayWithObject:indexToDelete];
        
        RunEvent * runDeleting = [cellToDelete associatedRun];
        
        //if run is currently loaded in the logger replace with something else
        [self.delegate preventUserFromSlidingRunInvalid:runDeleting];
        
        //remove both run and cell, run is most necessary
        [runs removeObject:runDeleting];
        [cells removeObjectAtIndex:indexOfCell];
        
        //commit and reload table here
        [MenuTable deleteRowsAtIndexPaths:arrayToDeleteCells withRowAnimation:UITableViewRowAnimationLeft];
        
        //reload 
        [MenuTable reloadData];

    }
    else{
        NSLog(@"Cant find cell to delete");
    }
}

@end
