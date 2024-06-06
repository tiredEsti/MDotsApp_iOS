//
//  MeasureViewController.h
//  MDots
//
//  Created by Estela Alvarez on 28/4/24.
//

#import <UIKit/UIKit.h>
#import <MovellaDotSdk/DotDevice.h>
#import <Firebase.h>
#import <FirebaseFirestore/FirebaseFirestore.h>

NS_ASSUME_NONNULL_BEGIN

/// @class MeasureViewController
/// @discussion A view controller that handles the measurement process using connected devices. This view controller manages the user interface and interactions for setting up and conducting measurements.
@interface MeasureViewController : UIViewController

/// The measuring devices
@property (strong, nonatomic) NSArray<DotDevice *> *measureDevices;

/// Sets the patient ID for the current test session.
/// @param patientId The unique identifier for the patient.
/// ```objc
/// [measureViewController setPatientID:@"12345"];
/// ```
- (void)setPatientID:(NSString *)patientId;

/// Sets the type of test to be conducted.
/// @param testtype The type of test (e.g., lunge, hip rotation).
/// ```objc
/// [measureViewController setTestType:@"Lunge"];
/// ```
- (void)setTestType:(NSString *)testtype;

/// Sets the side (left, right, single, etc.) for the test.
/// @param side The side of the body to be tested (e.g., left, right).
/// ```objc
/// [measureViewController setSide:@"L"];
/// ```
- (void)setSide:(NSString *)side;

@end

NS_ASSUME_NONNULL_END
