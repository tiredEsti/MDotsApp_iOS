//
//  MeasureViewController.m
//  MDots
//
//  Created by Estela Alvarez on 28/4/24.
//

#import "MeasureViewController.h"
#import "DeviceMeasureCell.h"
#import "UIDeviceCategory.h"
#import "UIViewCategory.h"
#import <MovellaDotSdk/DotSyncManager.h>
#import <MovellaDotSdk/DotDefine.h>
#import <MovellaDotSdk/DotUtils.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import <FirebaseFirestore/FirebaseFirestore.h>

/// @class MeasureViewController
/// @discussion A view controller that handles the measurement process of different types of physical tests (Sit and Reach, Lunge, Hip Rotation) using Dot devices. It also manages the synchronization and upload of test results to Firebase.
@interface MeasureViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) NSString *patientID;
@property (nonatomic, strong) NSString *testType;
@property (nonatomic, strong) NSString *side;

@property (strong, nonatomic) UILabel *modeLabel;
@property (strong, nonatomic) UILabel *pathLabel;
@property (strong, nonatomic) UIButton *startButton;
@property (assign, nonatomic) UILabel *syncStatusLabel;
@property (assign, nonatomic) UILabel *logFilePathLabel;
@property (strong, nonatomic) UITableView *tableView;

@property (strong, nonatomic) NSMutableArray *measures;

/// the progress hud of syncing.
@property (assign, nonatomic) MBProgressHUD *syncingHud;
/// Check the measureing is started
@property (assign, nonatomic) BOOL startFlag;
/// Enable the  log file in sdk.
/// Log file path:  Log file(s) stored in: \n Files -> On My iPhone -> YourApp -> Logs
@property (assign, nonatomic) BOOL logEnable;
/// the result of synchronization
@property (assign, nonatomic) BOOL syncResult;
/// the sync flag(enable or disable sync)
@property (assign, nonatomic) BOOL syncEnable;

@end

@implementation MeasureViewController

/// Called after the controller’s view is loaded into memory.
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self localInfoSetup];
    [self navigationItemsSetup];
    [self setupViews];
}

/// Notifies the view controller that its view is about to be added to a view hierarchy.
/// @param animated If YES, the view is being added to the window using an animation.
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // Add notification
    [self addObserver];
}

/// Notifies the view controller that its view is about to be removed from a view hierarchy.
/// @param animated If YES, the disappearance of the view is being animated.
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    // Remove notification
    [self removeObserver];
}

/// Notifies the view controller that its view was removed from a view hierarchy.
/// @param animated If YES, the disappearance of the view was animated.
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    if (self.startFlag)
    {
        [self cancelMeasurement];
    }
}

/// Sets up local variables and initial states.
- (void)localInfoSetup
{
    _syncResult = YES;
    _logEnable = NO;
    _syncEnable = NO;
}

/// Configures the navigation items for the view controller.
- (void)navigationItemsSetup
{
    self.title = @"Measure";
    UINavigationBar *navigationBar = self.navigationController.navigationBar;
    navigationBar.tintColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.startButton];
}

/// Lazily loads and configures the start button.
/// @return The start button instance.
- (UIButton *)startButton
{
    if (_startButton == nil)
    {
        _startButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_startButton setTitle:@"START" forState:UIControlStateNormal];
        //[_startButton setTintColor:[UIColor blueColor]];
        _startButton.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightBold];
        [_startButton addTarget:self action:@selector(handleStartButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _startButton;
}

/// Sets up the views and UI elements.
- (void)setupViews
{
    UIView *baseView = self.view;
    CGFloat edge = 15;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    //baseView.backgroundColor = [UIColor whiteColor];
    
    
    UILabel *syncStatusTitle = [[UILabel alloc]initWithFrame:CGRectMake(edge, edge, 60, 20)];
    syncStatusTitle.text = @"Sync: ";
    syncStatusTitle.font = [UIFont boldSystemFontOfSize:16.f];
    //syncStatusTitle.textColor = [UIColor blackColor];
    
    UILabel *syncStatusLabel = [[UILabel alloc]initWithFrame:CGRectMake(syncStatusTitle.right, edge, 120, 20)];
    syncStatusLabel.text = @"-";
    syncStatusLabel.font = [UIFont systemFontOfSize:14.f];
    syncStatusLabel.textColor = [UIColor grayColor];
    
    UILabel *syncLabel = [[UILabel alloc]initWithFrame:CGRectMake(edge, edge, 50, 20)];
    syncLabel.text = @"";
    
    UISwitch *syncSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(syncLabel.right+100, edge - 5, 50, 30)];
    syncSwitch.on = _syncEnable;
    [syncSwitch addTarget:self action:@selector(handleSyncSwitch:) forControlEvents:UIControlEventTouchUpInside];
    
    
    CGRect frame = baseView.bounds;
    frame.origin.y = syncStatusTitle.bottom + 10;
    frame.size.height -= syncStatusTitle.bottom;
    UITableView *tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
    tableView.showsVerticalScrollIndicator = NO;
    tableView.dataSource = self;
    tableView.clipsToBounds = YES;
    tableView.scrollEnabled = YES;
    tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    tableView.rowHeight = DeviceMeasureCell.cellHeight;
    tableView.delegate = self;
    tableView.hidden = YES;
    self.tableView = tableView;
    
    [baseView addSubview:syncStatusTitle];
    [baseView addSubview:syncStatusLabel];
    [baseView addSubview:syncLabel];
    [baseView addSubview:syncSwitch];
    [baseView addSubview:tableView];
    
    self.syncStatusLabel = syncStatusLabel;
    
}

/// Sets the start flag and updates the start button title.
/// @param startFlag A boolean indicating whether the measurement has started.
- (void)setStartFlag:(BOOL)startFlag
{
    _startFlag = startFlag;
    if (startFlag)
    {
        [self.startButton setTitle:@"STOP" forState:UIControlStateNormal];
    }
    else
    {
        [self.startButton setTitle:@"START" forState:UIControlStateNormal];
    }
}

/// Sets the patient ID.
/// @param patientId The patient ID to set.
- (void)setPatientID:(NSString *)patientId {
    _patientID = patientId;
}

/// Sets the test type.
/// @param testtype The test type to set.
- (void)setTestType:(NSString *)testtype {
    _testType = testtype;
}

/// Sets the side.
/// @param side The side to set.
- (void)setSide:(NSString *)side {
    _side = side;
}

#pragma mark - Logic

/// Shows the progress HUD for synchronization.
- (void)showSyncingHud
{
    _syncingHud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    _syncingHud.backgroundView.style = MBProgressHUDBackgroundStyleSolidColor;
    _syncingHud.backgroundView.color = [UIColor colorWithWhite:0.f alpha:0.1f];
    _syncingHud.label.text = NSLocalizedString(@"Syncing...", @"Sync title");
}

/// Hides the progress HUD.
- (void)hideProgressHud
{
    [self.syncingHud hideAnimated:YES];
}

/// Starts the real-time streaming measurement process.
- (void)startMeasure
{
    [self setupViews];
    self.startFlag = YES;
    self.tableView.hidden = NO;
    for (DotDevice *device in self.measureDevices)
    {
        device.plotMeasureMode = XSBleDevicePayloadCompleteEuler;
        device.plotLogEnable = self.logEnable;
        device.plotMeasureEnable = YES;
    }
}


/// Sets up data plotting for a device.
/// @param device The device for which to get plot data.
- (void)getPlotData:(DotDevice *)device {
    __block BOOL canSave = true;
    
    [device setDidParsePlotDataBlock:^(DotPlotData * _Nonnull
                                       instant) {
        if (canSave) {
            
            canSave = false;
            
            NSMutableArray *numArray = [[NSMutableArray alloc]initWithObjects:[NSNumber numberWithDouble:instant.euler0], [NSNumber numberWithDouble:instant.euler1], [NSNumber numberWithDouble:instant.euler2], nil];
            
            if (!self.measures) {
                self.measures = [NSMutableArray array];
            }
            
            [self.measures addObject: numArray];
        }
    }];
}

/// Uploads test data to Firebase.
/// @param devices The devices whose data will be uploaded.
/// @warning 1 second delay before uploading data to Firebase to ensure most recent data is uploaded.
- (void)uploadTestData:(NSArray *)devices {
    // Switch statement based on the testType string
    for (DotDevice *device in self.measureDevices)
    {
        [self getPlotData: device];
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                // Code inside this block will execute after a 1-second delay
                double result = 0;
                if ([self->_testType isEqualToString:@"Sit and Reach"]) {
                    
                    NSArray *firstInnerArray = self.measures[0];
                    NSNumber *firstDoubleNumber = firstInnerArray[1];
                    
                    NSArray *secondInnerArray = self.measures[1];
                    NSNumber *secondDoubleNumber = secondInnerArray[1];
                    
                    if(firstDoubleNumber.doubleValue > secondDoubleNumber.doubleValue) {
                        result = firstDoubleNumber.doubleValue - secondDoubleNumber.doubleValue;
                    } else {
                        result = secondDoubleNumber.doubleValue - firstDoubleNumber.doubleValue;
                    }
                    
                    //NSLog(@"resta: %f", result);
                } else if ([self->_testType isEqualToString:@"Lunge"]) {
                    NSLog(@"Test Type lunge selected");
                    NSArray *firstInnerArray = self.measures[0];
                    NSNumber *firstDoubleNumber = firstInnerArray[1];
                    result = fabs(firstDoubleNumber.doubleValue);
                    
                } else if ([self->_testType isEqualToString:@"Hip Rotation"]) {
                    NSLog(@"Test Type hip rotation selected");
                    NSArray *firstInnerArray = self.measures[0];
                    NSNumber *firstYNumber = firstInnerArray[1];
                    NSNumber *firstXNumber = firstInnerArray[0];
                    
                    NSArray *secondInnerArray = self.measures[1];
                    NSNumber *secondYNumber = secondInnerArray[1];
                    NSNumber *secondXNumber = secondInnerArray[0];
                    
                    if(self.side.length>1){
                        self.side = [self.side substringToIndex:1];
                    }
                    //the smaller one is in the femur positon because its looking up
                    if(firstYNumber.doubleValue > secondYNumber.doubleValue){
                        if ([self->_side isEqualToString:@"L"]) {
                            //For left leg: if x number of tibial is positive its external otherwise interrnal rotation
                            //External rotation
                            if(firstXNumber.doubleValue > 0){
                                self.side = [self.side stringByAppendingString:@"e"];
                                result = 90 - firstYNumber.doubleValue - secondXNumber.doubleValue;
                            } else { //Internal rotation
                                self.side = [self.side stringByAppendingString:@"i"];
                                result = 90 - firstYNumber.doubleValue + secondXNumber.doubleValue;
                            }
                        } else {
                            //For right leg: if x number of tibial is positive its internal otherwise external rotation
                            //Internal rotation
                            if(firstXNumber.doubleValue > 0){
                                self.side = [self.side stringByAppendingString:@"i"];
                                result = 90 - firstYNumber.doubleValue - secondXNumber.doubleValue;
                            } else { //External rotation
                                self.side = [self.side stringByAppendingString:@"e"];
                                result = 90 - firstYNumber.doubleValue + secondXNumber.doubleValue;
                            }
                        }
                        
                    } else {
                        if ([self->_side isEqualToString:@"L"]) {
                            //For left leg: if x number of tibial is positive its external otherwise interrnal rotation
                            //External rotation
                            if(secondXNumber.doubleValue > 0){
                                self.side = [self.side stringByAppendingString:@"e"];
                                result = 90 - secondYNumber.doubleValue - firstXNumber.doubleValue;
                            } else { //Internal rotation
                                self.side = [self.side stringByAppendingString:@"i"];
                                result = 90 - secondYNumber.doubleValue + firstXNumber.doubleValue;
                            }
                        } else {
                            //For right leg: if x number of tibial is positive its internal otherwise external rotation
                            //Internal rotation
                            if(secondXNumber.doubleValue > 0){
                                self.side = [self.side stringByAppendingString:@"i"];
                                result = 90 - secondYNumber.doubleValue - firstXNumber.doubleValue;
                            } else { //External rotation
                                self.side = [self.side stringByAppendingString:@"e"];
                                result = 90 - secondYNumber.doubleValue + firstXNumber.doubleValue;
                            }
                        }
                    }
                    
                }
        
                [self uploadToFirebaseWithResult:result];
        
            });
}

/// Uploads test data to Firebase with the provided result.
/// @param result The result value to upload.
- (void)uploadToFirebaseWithResult:(double)result {
    NSNumber *resultNumber = @(result);
    NSDictionary *testData = @{
        @"testDate": [FIRTimestamp timestampWithDate:[NSDate date]],
        @"value": resultNumber,
        @"side": _side
    };
    
    FIRFirestore *db = [FIRFirestore firestore];
    FIRAuth *auth = [FIRAuth auth];
    
    // Get the current user ID
    FIRUser *currentUser = auth.currentUser;
    if (!currentUser) {
        NSLog(@"Error: Current user not available.");
        return;
    }
    NSString *currentUserID = currentUser.uid;
    
    // Access the patients collection for the current user
    FIRCollectionReference *patientsRef = [db collectionWithPath:[NSString stringWithFormat:@"users/%@/patients", currentUserID]];
    
    // Access the specific patient document using patientID
    FIRDocumentReference *patientDocRef = [patientsRef documentWithPath: self.patientID];
    
    FIRCollectionReference *testRef = [patientDocRef collectionWithPath: self.testType];
    
    // Save data to the lunge test collection
    [testRef addDocumentWithData:testData completion:^(NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"Error uploading test data: %@", error.localizedDescription);
        } else {
            NSLog(@"Test data uploaded successfully.");
        }
    }];
}

/// Cancels the measurement process.
- (void)cancelMeasurement
{
    self.startFlag = NO;
    
    for (DotDevice *device in self.measureDevices)
    {
        device.plotMeasureEnable = NO;
        
    }
    self.measures = [NSMutableArray array];
    NSLog(@"Measurement canceled successfully.");
}

/// Stops the real-time streaming measurement process and uploads the test data.
- (void)stopMeasure
{
    self.startFlag = NO;
    [self uploadTestData: self.measureDevices];
    
    for (DotDevice *device in self.measureDevices)
    {
        device.plotMeasureEnable = NO;
        
    }
    self.measures = [NSMutableArray array];
}

/// Starts the synchronization process.
- (void)startSync
{
    __weak __typeof(self) wself = self;
    DotSyncResultBlock block = ^(NSArray *array)
    {
        for (int i = 0; i < array.count; i++)
        {
            NSDictionary *resultDic = array[i];
            wself.syncResult |= [[resultDic objectForKey:@"success"] boolValue];
        }
        
        [wself hideProgressHud];
        if (wself.syncResult)
        {
            wself.syncStatusLabel.text = @"Success";
            [wself startMeasure];
        }
        else
        {
            wself.syncStatusLabel.text = @"Fail";
        }
    };
    
    [self showSyncingHud];
    [DotSyncManager startSync:self.measureDevices result:block];
}

/// Start heading reset or revert
- (void)startHeading
{
    for (DotDevice *device in self.measureDevices) {
        if (device.isSupportHeadingReset)
        {
            device.headingResetResult = ^(int result) {
                NSLog(@"Heading result %d", result);
                result != 0? [self showHeadingSuccess] : [self showHeadingFail];
            };
            
            if (device.headingStatus == XSHeadingStatusXrmHeading)
            {
                [device startHeadingRevert];
            }
            else if (device.headingStatus == XSHeadingStatusXrmDefaultAlignment ||
                     device.headingStatus == XSHeadingStatusXrmNone){
                [device startHeadingReset];
            }
        }
    }
}

/// Shows a success message for heading reset.
- (void)showHeadingSuccess
{
    MBProgressHUD *hud =  [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.offset = CGPointMake(0, 200);
    hud.label.text = @"Heading success";
    [hud hideAnimated:YES afterDelay:1.0f];
}

/// Shows a failure message for heading reset.
- (void)showHeadingFail
{
    MBProgressHUD *hud =  [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.offset = CGPointMake(0, 200);
    hud.label.text = @"Heading fail";
    [hud hideAnimated:YES afterDelay:1.0f];
}


#pragma mark - TouchEvent

/// Handles the tap event for the START button.
/// @param sender The button that was tapped.
- (void)handleStartButton:(UIButton *)sender
{
    if (self.startFlag)
    {
        [self stopMeasure];
    }
    else
    {
        if (self.syncEnable)
        {
            [self startSync];
        }
        else
        {
            [self startMeasure];
        }
    }
}

/// Handles the tap event for the sync switch.
/// @param sender The switch object.
- (void)handleSyncSwitch:(UISwitch *)sender
{
    self.syncEnable = sender.on;
}


#pragma mark - Notification

/// Receives the notification for the log file path.
/// @param sender The notification object.
- (void)onLogPathReceive:(NSNotification *)sender
{
    NSString *logText = [NSString stringWithFormat:@"APP -> Logs -> %@",sender.object];
    self.logFilePathLabel.text = logText;
}

/// Add the notification for Log file path
- (void)addObserver
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(onLogPathReceive:) name:kDotNotificationDeviceLoggingPath object:nil];
}

/// Remove the notification for Log file path
- (void)removeObserver
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self name:kDotNotificationDeviceLoggingPath object:nil];
}

#pragma mark -- UITableViewDataSource &  UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.measureDevices.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *indentifier = [DeviceMeasureCell cellIdentifier];;
    DeviceMeasureCell *cell = [tableView dequeueReusableCellWithIdentifier:indentifier];
    if (cell == nil)
    {
        cell = [[DeviceMeasureCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:indentifier];
    }
    
    cell.device = self.measureDevices[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return DeviceMeasureCell.cellHeight;
}
@end
