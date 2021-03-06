#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface MessageViewController : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextView *receivedTextView;
@property (weak, nonatomic) IBOutlet UIImageView *receivedImageView;
@property (weak, nonatomic) IBOutlet UITextField *sendTextFiled;

@property (strong, nonatomic) NSString *connectedDeviceName;
@property (strong, nonatomic) CBPeripheral *peripheral;

@end
