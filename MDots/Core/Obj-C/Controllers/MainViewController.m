//
//  MainViewController.m
//  MDots
//
//  Created by Estela Alvarez on 28/4/24.
//

#import "MainViewController.h"
#import "DeviceConnectCell.h"
#import "MeasureViewController.h"
#import "UIDeviceCategory.h"
#import "UIViewCategory.h"

#import <MBProgressHUD/MBProgressHUD.h>
#import <MovellaDotSdk/DotDevice.h>
#import <MovellaDotSdk/DotLog.h>
#import <MovellaDotSdk/DotDevicePool.h>
#import <MovellaDotSdk/DotConnectionManager.h>
#import <MovellaDotSdk/DotReconnectManager.h>
#import <MJRefresh.h>

/// @class MainViewController
/// @discussion A view controller that handles the main interface for patient tests. This view controller manages the user interface and interactions for conducting and managing patient tests.
@interface MainViewController ()<UITableViewDelegate,UITableViewDataSource, DotConnectionDelegate>

@property (nonatomic, strong) NSString *patientID;
@property (nonatomic, strong) NSString *testType;
@property (nonatomic, strong) NSString *side;

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSMutableArray<DotDevice *> *deviceList;
@property (strong, nonatomic) NSMutableArray *connectList;
@property (strong, nonatomic) UIButton *measureButton;


@end

@implementation MainViewController


/// Called when the view is about to appear on the screen.
/// Sets up necessary delegates, enables logging and reconnection, and adds observers.
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    /// Set Dot connection delegate
    [DotConnectionManager setConnectionDelegate:self];
    /// Set log enable
    [DotLog setLogEnable:YES];
    /// Set reconnection enable
    [DotReconnectManager setEnable:YES];
    /// Add notifications
    [self addObservers];
    
    /// Refresh tableview back from MeasureViewController
    if (self.connectList.count != 0)
    {
        [self.tableView reloadData];
    }
}

/// Called when the view is about to disappear from the screen.
/// Ends refreshing and stops Bluetooth scan.
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.tableView.mj_header endRefreshing];
    /// Stop ble scan
    [DotConnectionManager stopScan];
    /// Remove notifications
    [self removeObservers];
}

/// Called after the view has been loaded.
/// Sets up the initial state of the view controller.
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.deviceList = [NSMutableArray arrayWithCapacity:20];
    self.connectList = [NSMutableArray arrayWithCapacity:20];
    [self navigationItemsSetup];
    [self setupViews];
    [self disconnectAll];
}

/// Sets up the navigation items for the view controller.
- (void)navigationItemsSetup
{
    self.title = @"DOT Example";
    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithTitle:@"Menu" menu:[self createMenu]];
    [item setTintColor:UIColor.whiteColor];
    UINavigationBar *navigationBar = self.navigationController.navigationBar;
    navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
    navigationBar.barTintColor = [UIColor orangeColor];
    self.navigationItem.rightBarButtonItem = item;
}

/// Creates a menu for the navigation bar item. For development purposes.
/// @return nil.
- (UIMenu *)createMenu{
    return nil;
}

/// Sets up the views for the view controller.
- (void)setupViews
{
    UIView *baseView = self.view;
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self scanDevices];
    }];
    header.lastUpdatedTimeLabel.hidden = YES;
    header.stateLabel.hidden = YES;
    
    CGRect frame = baseView.bounds;
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
    tableView.showsVerticalScrollIndicator = NO;
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.mj_header = header;
    self.tableView = tableView;
    
    [baseView addSubview:tableView];
    
    [baseView addSubview:self.measureButton];
}

/// Lays out the subviews.
/// Adjusts the frame of the measure button.
- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    // Layout the measure button
    
    CGFloat buttonWidth = 120;
    CGFloat buttonHeight = 40;
    CGFloat buttonX = (self.view.bounds.size.width - buttonWidth) / 2;
    CGFloat buttonY = self.view.bounds.size.height - buttonHeight - 20; // Adjust the Y position as needed
    self.measureButton.frame = CGRectMake(buttonX, buttonY, buttonWidth, buttonHeight);
}

/// Lazily initializes the measure button.
/// @return A UIButton object.
- (UIButton *)measureButton
{
    if (_measureButton == nil)
    {
        _measureButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_measureButton setTitle:@"Measure" forState:UIControlStateNormal];
        //[_measureButton setTintColor:[UIColor whiteColor]];
        _measureButton.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightBold];
        [_measureButton addTarget:self action:@selector(handleMeasure:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _measureButton;
}

/// Updates the status of visible UITableViewCells.
- (void)updateDeviceCellStatus
{
    NSArray *cells = self.tableView.visibleCells;
    if(cells.count > 0)
    {
        for(DeviceConnectCell *cell in cells)
        {
            [cell refreshDeviceStatus];
        }
    }
}

/// Starts a Bluetooth scan for devices. If Bluetooth is not powered on, a message is logged.
- (void)scanDevices
{
    if(![DotConnectionManager managerStateIsPoweredOn])
    {
        [self.tableView.mj_header endRefreshing];
        NSLog(@"Please enable bluetoooth first");
        return;
    }
    [self.deviceList removeAllObjects];
    if (self.connectList.count != 0)
    {
        [self.deviceList addObjectsFromArray:self.connectList];
    }
    [self.tableView reloadData];
    /// Start scan
    [DotConnectionManager scan];
}

/// Sets the patient ID for the current test session.
/// @param patientId The unique identifier for the patient.
- (void)setPatientID:(NSString *)patientId {
    _patientID = patientId;
}

/// Sets the type of test to be conducted.
/// @param testtype The type of test (e.g., lunge, hip rotation).
- (void)setTestType:(NSString *)testtype {
    _testType = testtype;
}

/// Sets the side (left, right, single, etc.) for the test.
/// @param side The side of the body to be tested (e.g., left, right).
- (void)setSide:(NSString *)side {
    _side = side;
}

#pragma mark -- Logic

/// Disconnect all sensors.
- (void)disconnectAll
{
    for (DotDevice *device in [DotDevicePool allBoundDevices])
    {
        /// Disconnect the sensor
        [DotConnectionManager disconnect:device];
        /// Remove from the DevicePool
        [DotDevicePool unbindDevice:device];
    }
    
    [self.connectList removeAllObjects];
}

/// Checks the number of connected sensors.
/// @return A Boolean indicating whether the correct number of sensors are connected.
- (Boolean)checkSensorsNumber
{
    if ([_testType isEqualToString:@"Sit and Reach"]) {
        if(self.connectList.count != 2){
            [self processInteger:2];
            return false;
        }
        else return true;
    } else if ([_testType isEqualToString:@"Lunge"]) {
        if(self.connectList.count != 1){
            [self processInteger:1];
            return false;
        }
        else return true;
    } else if ([_testType isEqualToString:@"Hip Rotation"]) {
        if(self.connectList.count != 2){
            [self processInteger:2];
            return false;
        }
        else return true;
    }
    return false;
}

/// Displays a HUD indicating no sensors are connected.
- (void)showUnconnectHud
{
    MBProgressHUD *hud =  [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.offset = CGPointMake(0, 200);
    hud.label.text = @"Please connect at least a sensor";
    [hud hideAnimated:YES afterDelay:1.0f];
}

/// Processes the integer number of sensors needed according to the test type.
/// @param number The number of sensors required.
- (void)processInteger:(int)number {
    
    MBProgressHUD *hud =  [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.offset = CGPointMake(0, 200);
    NSString *errorMessage = @"";
    if(number == 1){
        errorMessage = [NSString stringWithFormat:@"Please connect %d sensor", number];
    }
    else {
        errorMessage = [NSString stringWithFormat:@"Please connect %d sensors", number];
    }
    hud.label.text = errorMessage;
    [hud hideAnimated:YES afterDelay:1.0f];
}

/// Displays a HUD indicating sensors are not initialized.
- (void)showNotInitialized
{
    MBProgressHUD *hud =  [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.offset = CGPointMake(0, 200);
    hud.label.text = @"Please wait for sensor initialization";
    [hud hideAnimated:YES afterDelay:1.0f];
}


#pragma mark -- TouchEvent

/// Handles the switch button of a UITableViewCell being tapped.
/// @param cell The cell whose button was tapped.
- (void)onCellConnectButtonTapped:(DeviceConnectCell *)cell
{
    DotDevice *device = cell.device;
    
    if(device.state != CBPeripheralStateConnected)
    {
        // Check if the device is already in the connectList before adding it
        if (![self.connectList containsObject:device]) {
            [self.connectList addObject:device];
            /// connect a sensor
            [DotConnectionManager connect:device];
            /// add to DevicePool.
            /// Reconnection has Two conditions,please also unbind it after disconnected .
            /// 1. [DotReconnectManager setEnable:YES];
            /// 2. [DotDevicePool bindDevice:device]
            [DotDevicePool bindDevice:device];
        }
    }
    else
    {
        [self.connectList removeObject:device];
        /// Disconnect the sensor
        [DotConnectionManager disconnect:device];
        /// Remove from the DevicePool
        [DotDevicePool unbindDevice:device];
    }
    //NSLog(@"device count: %d", self.connectList.count);
    [cell refreshDeviceStatus];
}

/// Handles the measure button being tapped.
/// @param sender The measure button.
- (void)handleMeasure:(UIButton *)sender
{
    if (self.connectList.count == 0)
    {
        [self showUnconnectHud];
    }
    else
    {
        if([self checkSensorsNumber]){
            MeasureViewController *measureViewController = [MeasureViewController new];
            measureViewController.measureDevices = self.connectList;
           
            [measureViewController setPatientID:_patientID];
            [measureViewController setTestType:_testType];
            [measureViewController setSide:_side];
            [self.navigationController pushViewController:measureViewController animated:YES];
        }
    }
}


#pragma mark -- XSConnectionDelegate


/// Called when the Bluetooth scan is completed.
- (void)onScanCompleted
{
    [self.tableView.mj_header endRefreshing];
}

/// Called when a device connection fails.
/// @param device The device that failed to connect.
- (void)onDeviceConnectFailed:(DotDevice *)device
{
    [self updateDeviceCellStatus];
}

/// Called when a device is disconnected.
/// @param device The device that was disconnected.
- (void)onDeviceDisconnected:(DotDevice *)device
{
    [self updateDeviceCellStatus];
}

/// Called when a device successfully connects.
/// @param device The device that connected.
- (void)onDeviceConnectSucceeded:(DotDevice *)device
{
    [self updateDeviceCellStatus];
}

/// Called when a Dot device is discovered.
/// @param device The discovered device.
- (void)onDiscoverDevice:(DotDevice *)device
{
    NSInteger index = [self.deviceList indexOfObject:device];
    if(index == NSNotFound)
    {
        if(![self.deviceList containsObject:device])
        {
            [self.deviceList addObject:device];
            [self.tableView reloadData];
        }
    }
}

/// Called when the Bluetooth manager state updates.
/// @param managerState The new state of the Bluetooth manager.
- (void)onManagerStateUpdate:(XSDotManagerState)managerState
{
    [self updateDeviceCellStatus];
    if(managerState != XSDotManagerStatePoweredOn)
    {
        [self.tableView.mj_header endRefreshing];
    }
    else
    {
        if([UIApplication sharedApplication].applicationState != UIApplicationStateBackground)
        {
            [self.tableView.mj_header beginRefreshing];
        }
    }
}

#pragma mark -- Notification

/// Called when the battery level of a device updates.
/// @param sender The notification sender.
- (void)onDeviceBatteryUpdated:(NSNotification *)sender
{
    [self updateDeviceCellStatus];
}

/// Called when the name of a device is read.
/// @param sender The notification sender.
- (void)onDeviceTagRead:(NSNotification *)sender
{
    [self updateDeviceCellStatus];
}

/// Add notifications
- (void)addObservers
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(onDeviceBatteryUpdated:) name:kDotNotificationDeviceBatteryDidUpdate object:nil];
    [center addObserver:self selector:@selector(onDeviceTagRead:) name:kDotNotificationDeviceNameDidRead object:nil];
}

/// Remove notifications
- (void)removeObservers
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self name:kDotNotificationDeviceBatteryDidUpdate object:nil];
    [center removeObserver:self name:kDotNotificationDeviceNameDidRead object:nil];
}


#pragma mark -- UITableViewDataSource &  UITableViewDelegate

/// Returns the cell for a row at a specified index path.
/// @param tableView The table view.
/// @param indexPath The index path.
/// @return The table view cell.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.deviceList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *indentifier = [DeviceConnectCell cellIdentifier];;
    DeviceConnectCell *cell = [tableView dequeueReusableCellWithIdentifier:indentifier];
    if (cell == nil)
    {
        cell = [[DeviceConnectCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:indentifier];
        cell.connectAction = ^(DeviceConnectCell * _Nonnull cell) {
            [self onCellConnectButtonTapped:cell];
        };
    }
    
    cell.device = self.deviceList[indexPath.row];
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return DeviceConnectCell.cellHeight;
}

@end
