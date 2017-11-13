#import "ContactWindowController.h"
#import "Constants.h"

@interface ContactWindowController () {
    int serviceNum;
    Boolean isSendingImg;
}

@end

@implementation ContactWindowController

#pragma mark - View Lifecycle
- (void)windowDidLoad {
    [super windowDidLoad];
    _recievedMsg.layer.borderWidth = 1.0;
    _recievedMsg.layer.borderColor = [NSColor darkGrayColor].CGColor;
    
    isSendingImg = NO;
    _picData = [[NSMutableData alloc] init];
    
    [_MsgTosend setDelegate:self];
}

#pragma mark - CBPeripheralManagerDelegate Methods
- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
    if (peripheral.state != CBPeripheralManagerStatePoweredOn) {
        NSLog(@">>>Powered off");
        NSAlert *hint = [[NSAlert alloc] init];
        [hint addButtonWithTitle:@"Define"];
        [hint setInformativeText:@"Bluetooth is turned off, turn on it"];
        [hint setAlertStyle:NSWarningAlertStyle];
        [hint runModal];
        return;
    }
    
    NSLog(@">>>Powered on.");

    [self setUp];
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(NSError *)error {
    if (error == nil) {
        serviceNum++;
    }
    
    if (serviceNum == 3) {
        [_peripheralManager startAdvertising:@{
                                              CBAdvertisementDataServiceUUIDsKey : @[[CBUUID UUIDWithString:kServiceUUID1],[CBUUID UUIDWithString:kServiceUUID2], [CBUUID UUIDWithString:kTransferTextServiceUUID]]
                                              }
         ];
    }
}

- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error {
    NSLog(@"PeripheralManager did start advertisiong");
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic{
    NSLog(@"Central %@ subscribed to characteristic %@", central.identifier, characteristic.UUID);
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic {
    NSLog(@"Central unsubscribed to characteristic %@",characteristic.UUID);
    NSAlert *hint = [[NSAlert alloc] init];
    [hint addButtonWithTitle:@"Define"];
    [hint setInformativeText:@"Disconnect the center equipment, please check the center equipment！"];
    [hint setAlertStyle:NSWarningAlertStyle];
    [hint runModal];
    [self.window orderOut:nil];
}

- (void)sendTextData {
    [_peripheralManager updateValue:[_dataToSend dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:_transferTextCharacteristic onSubscribedCentrals:nil];
    // NSLog(@"%@",_dataToSend);
}

- (void)sendImageData {
    isSendingImg = YES;
    // First up, check if we're meant to be sending an EOM
    static BOOL sendingEOM = NO;
    if (sendingEOM) {
        // Send it
        BOOL didSend = [self.peripheralManager updateValue:[@"EOM" dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:_transferImageCharacteristic onSubscribedCentrals:nil];
        
        if (didSend) {
            sendingEOM = NO;
            NSLog(@"EOM sent");
            isSendingImg = NO;
            _sendDataIndex = 0;
            _picData = [[NSMutableData alloc] init];
        }
        
        // It didn't send, so we'll exit and wait for peripheralManagerIsReadyToUpdateSubscribers to call sendData again
        return;
    }
    
    // We're not sending an EOM, so we're sending data
    
    // Is there any left to send?
    if (_sendDataIndex >= _imgData.length) {//no. then done
        return;
    }
    
    // There's data left, so send until the callback fails, or we're done.
    BOOL didSend = YES;
    while (didSend) {
        // Make the next chunk
        
        // Set the amount of data
        NSInteger amountToSend = _imgData.length - _sendDataIndex;
        
        if (amountToSend >= 20) {
            amountToSend = 20;
        }
        NSData *chunk = [NSData dataWithBytes:_imgData.bytes + _sendDataIndex length:amountToSend];
        
        // Send it
        didSend = [self.peripheralManager updateValue:chunk forCharacteristic:_transferImageCharacteristic onSubscribedCentrals:nil];
        // If it didn't work, drop out and wait for the callback
        if (!didSend) {
            return;
        }
        
        [_picData appendData:chunk];
        NSLog(@"%.2f%%", _picData.length * 1.0/_imgData.length*100.0);

        // It did send, so update our index and sent percentage
        _sendDataIndex += amountToSend;
        // Was it the last one?
        if (_sendDataIndex >= _imgData.length) {
            
            sendingEOM = YES;
            // Going to send an eom
            BOOL eomSent = YES;
            eomSent = [self.peripheralManager updateValue:[@"EOM" dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:_transferImageCharacteristic onSubscribedCentrals:nil];
            
            if (eomSent) {
                sendingEOM = NO;
                _imgData = nil;
                NSLog(@"Sent EOM");
                isSendingImg = NO;
                _sendDataIndex = 0;
                _picData = [[NSMutableData alloc] init];
            }
            
            // If not sent, then return
            return;
        }
    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request {
    NSLog(@"didReceiveReadRequests");

    if (request.characteristic.properties & CBCharacteristicPropertyRead) {
        NSData *data = request.characteristic.value;
        [request setValue:data];

        [_peripheralManager respondToRequest:request withResult:CBATTErrorSuccess];
    }else{
        [_peripheralManager respondToRequest:request withResult:CBATTErrorWriteNotPermitted];
    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray *)requests {
    NSLog(@"didReceiveWriteRequests");
    CBATTRequest *request = requests[0];
    
    if (request.characteristic.properties & CBCharacteristicPropertyWrite) {
        // Convert to CBMutableCharacteristic, and then can be written
        CBMutableCharacteristic *c =(CBMutableCharacteristic *)request.characteristic;
        c.value = request.value;
        NSString *sfd = [[NSString alloc] initWithData:c.value encoding:NSUTF8StringEncoding];
        _recievedMsg.stringValue = sfd;
        
        [_peripheralManager respondToRequest:request withResult:CBATTErrorSuccess];
        
    } else {
        [_peripheralManager respondToRequest:request withResult:CBATTErrorWriteNotPermitted];
    }
    
    
}

- (void)peripheralManagerIsReadyToUpdateSubscribers:(CBPeripheralManager *)peripheral{
    if (isSendingImg) {
        // Start sending again
        [self sendImageData];
    }
}

- (void)setUp {
    _transferImageCharacteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:kTransferImageCharacteristicUUID] properties:CBCharacteristicPropertyNotify value:nil permissions:CBAttributePermissionsReadable];
    
    CBMutableCharacteristic *readwriteCharacteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:kReadwriteCharacteristicUUID] properties:CBCharacteristicPropertyWrite | CBCharacteristicPropertyRead value:nil permissions:CBAttributePermissionsReadable | CBAttributePermissionsWriteable];
    
    CBMutableCharacteristic *readCharacteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:kReadCharacteristicUUID] properties:CBCharacteristicPropertyRead value:nil permissions:CBAttributePermissionsReadable];
    
    _transferTextCharacteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:kTransferTextCharacteristicUUID] properties:CBCharacteristicPropertyNotify value:nil permissions:CBAttributePermissionsReadable];
    
    CBMutableService *service1 = [[CBMutableService alloc] initWithType:[CBUUID UUIDWithString:kServiceUUID1] primary:YES];
    [service1 setCharacteristics:@[_transferImageCharacteristic, readwriteCharacteristic]];
    
    CBMutableService *service2 = [[CBMutableService alloc] initWithType:[CBUUID UUIDWithString:kServiceUUID2] primary:YES];
    [service2 setCharacteristics:@[readCharacteristic]];
    
    CBMutableService *transferService = [[CBMutableService alloc] initWithType:[CBUUID UUIDWithString:kTransferTextServiceUUID] primary:YES];
    transferService.characteristics = @[_transferTextCharacteristic];
    
    [_peripheralManager addService:service1];
    [_peripheralManager addService:service2];
    [_peripheralManager addService:transferService];
}

#pragma mark - IBAction
- (IBAction)advertiseMsg:(id)sender {
    _dataToSend = _MsgTosend.stringValue;
    [self sendTextData];
}

- (IBAction)choosePic:(id)sender {
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    // Only choose picture
    panel.allowedFileTypes = [NSArray arrayWithObjects: @"png", @"jpg", nil];
    [panel setMessage:@""];
    [panel setPrompt:@"Send"];
    [panel setCanChooseDirectories:NO];
    [panel setCanCreateDirectories:NO];
    [panel setCanChooseFiles:YES];

    NSString *path_all;
    NSInteger result = [panel runModal];
    if (result == NSFileHandlingPanelOKButton)
    {
        path_all = [[panel URL] path];
        NSImage *img = [[NSImage alloc] initWithContentsOfURL:[panel URL]];
        _imgData = [img TIFFRepresentation];
        [self sendImageData];
        self.imgURL.stringValue = path_all;
        self.choosePicBtn.title = @"Reselect";
    }
}


@end
