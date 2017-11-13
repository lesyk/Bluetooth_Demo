#import <Cocoa/Cocoa.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface ContactWindowController : NSWindowController<CBPeripheralManagerDelegate, NSTextFieldDelegate>

@property (weak) IBOutlet NSTextField *imgURL;
@property (weak) IBOutlet NSTextField *centralName;
@property (weak) IBOutlet NSTextField *recievedMsg;
@property (weak) IBOutlet NSTextField *MsgTosend;
@property (weak) IBOutlet NSButton    *choosePicBtn;
@property (weak) IBOutlet NSButton    *sendBtn;

@property (strong, nonatomic) CBPeripheralManager       *peripheralManager;
@property (strong, nonatomic) CBMutableCharacteristic   *transferTextCharacteristic;
@property (strong, nonatomic) CBMutableCharacteristic   *transferImageCharacteristic;
@property (strong, nonatomic) NSString                  *dataToSend;
@property (strong, nonatomic) NSData                    *imgData;
@property (strong ,nonatomic) NSMutableData             *picData;
@property (nonatomic, readwrite) NSInteger              sendDataIndex;

@end
