//
//  MainViewController.h
//  MDots
//
//  Created by Estela Alvarez on 28/4/24.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// @class MainViewController
/// @discussion A view controller that handles the main interface for patient tests. This view controller manages the user interface and interactions for conducting and managing patient tests.
@interface MainViewController : UIViewController

/// Sets the patient ID for the current test session.
/// @param patientId The unique identifier for the patient.
/// ```objc
/// [mainViewController setPatientID:@"12345"];
/// ```

- (void)setPatientID:(NSString *)patientId;

/// Sets the type of test to be conducted.
/// @param testtype The type of test (e.g., lunge, hip rotation).
/// ```objc
/// [mainViewController setTestType:@"Lunge"];
/// ```

- (void)setTestType:(NSString *)testtype;

/// Sets the side (left, right, single,e tc) for the test.
/// @param side The side of the body to be tested (e.g., left, right).
/// ```objc
/// [mainViewController setSide:@"L"];
/// ```
- (void)setSide:(NSString *)side;

@end

NS_ASSUME_NONNULL_END

