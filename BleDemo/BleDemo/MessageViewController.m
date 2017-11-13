#import "MessageViewController.h"
#import "Constants.h"
#import <CoreLocation/CoreLocation.h>

@interface MessageViewController ()

@end

@implementation MessageViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    _titleLabel.text = [[NSString alloc] initWithFormat:@"Connected computer: %@", _connectedDeviceName];
    _receivedTextView.layer.borderWidth = 1.0;
    _receivedTextView.layer.borderColor = [UIColor darkGrayColor].CGColor;
    _receivedImageView.layer.borderWidth = 1.0;
    _receivedImageView.layer.borderColor = [UIColor darkGrayColor].CGColor;
    
    _sendTextFiled.delegate = self;
}

#pragma mark - IBAction
- (IBAction)didTapSendBtn:(id)sender {
    NSString *sentDataString = _sendTextFiled.text;
    
    for (CBService *service in _peripheral.services) {
        for (CBCharacteristic *characteristic in service.characteristics) {
            if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:kReadwriteCharacteristicUUID]]) {
                [_peripheral writeValue:[sentDataString dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
            }
        }
    }
}

#pragma mark - TextFiledDelegate Methods
// Dismiss the keyboard
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [_sendTextFiled resignFirstResponder];
}

@end
