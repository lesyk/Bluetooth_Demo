#import "BeCentralVewController.h"
#import "MessageViewController.h"
#import "Constants.h"

@interface BeCentralVewController () {
    CBCentralManager *manager;
    MessageViewController *mvc;
}

@end

@implementation BeCentralVewController

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    manager = [[CBCentralManager alloc]initWithDelegate:self queue:dispatch_get_main_queue()];
    _discoverPeripherals = [[NSMutableArray alloc] init];
    _picData = [[NSMutableData alloc] init];
    _deviceList = [[NSMutableArray alloc] initWithCapacity:7];

    _deviceTable.delegate = self;
    _deviceTable.dataSource = self;
}

//-(void)viewDidAppear:(BOOL)animated {
//    [manager stopScan];
//}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - TableViewDataSource Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _deviceList.count;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kTableSampleIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:kTableSampleIdentifier];
    }
    
    cell.textLabel.text = [_deviceList objectAtIndex:indexPath.row];
    cell.detailTextLabel.text = @"not connected";
    return cell;
}

#pragma mark - CBCentralManagerDelegate Methods

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    switch (central.state) {
        case CBCentralManagerStateUnknown:
            NSLog(@">>>CBCentralManagerStateUnknown");
            break;
        case CBCentralManagerStateResetting:
            NSLog(@">>>CBCentralManagerStateResetting");
            break;
        case CBCentralManagerStateUnsupported:
            NSLog(@">>>CBCentralManagerStateUnsupported");
            break;
        case CBCentralManagerStateUnauthorized:
            NSLog(@">>>CBCentralManagerStateUnauthorized");
            break;
        case CBCentralManagerStatePoweredOff:
            NSLog(@">>>CBCentralManagerStatePoweredOff");
            break;
        case CBCentralManagerStatePoweredOn:
            NSLog(@">>>CBCentralManagerStatePoweredOn");
            // Start scanning peripherals
            [central scanForPeripheralsWithServices:nil options:nil];
            break;
        default:
            break;
    }
}

-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    if (peripheral.name != nil) {
        NSLog(@"Discover peripheral named:%@",peripheral.name);
        
        [_discoverPeripherals removeObject:peripheral];
        [_discoverPeripherals addObject:peripheral];
        [self.deviceList removeObject:peripheral.name];
        [self.deviceList addObject:peripheral.name];
        [_deviceTable reloadData];
    }
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"Connect to peripheral named %@ -Fail:%@", [peripheral name], [error localizedDescription]);
    [_deviceTable reloadData];
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@">>>Peripheral named %@ disconnect: %@\n", [peripheral name], [error localizedDescription]);
    NSIndexPath *indexPath = _deviceTable.indexPathForSelectedRow;
    UITableViewCell *cell = [_deviceTable cellForRowAtIndexPath:indexPath];
    cell.detailTextLabel.text = @"not connected";
    [_deviceTable reloadData];
    
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@">>>Connect to peripheral named（%@）-Successful",peripheral.name);
    
    NSIndexPath *indexPath = _deviceTable.indexPathForSelectedRow;
    UITableViewCell *cell = [_deviceTable cellForRowAtIndexPath:indexPath];
    cell.detailTextLabel.text = @"Connected";
    
    mvc = [self.storyboard instantiateViewControllerWithIdentifier:@"MessageViewController"];
    mvc.connectedDeviceName = peripheral.name;
    mvc.peripheral = peripheral;
    [self.navigationController pushViewController:mvc animated:YES];

    [peripheral setDelegate:self];
    
    [peripheral discoverServices:nil];
    
}

#pragma mark - CBPeripheralDelegate Methods

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    if (error) {
        NSLog(@">>>Discovered services for %@ with error: %@", peripheral.name, [error localizedDescription]);
        return;
    }
    
    for (CBService *service in peripheral.services) {
        [peripheral discoverCharacteristics:nil forService:service];
    }
    
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    if (error) {
        NSLog(@">>>error Discovered characteristics for %@ with error: %@", service.UUID, [error localizedDescription]);
        return;
    }
    
    for (CBCharacteristic *characteristic in service.characteristics) {
//        [peripheral readValueForCharacteristic:characteristic];

        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:kTransferTextCharacteristicUUID]]) {
            // If it is 'kTransferTextCharacteristicUUID', subscribe to it
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        }

        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:kTransferImageCharacteristicUUID]]) {
            // If it is 'kTransferImageCharacteristicUUID', subscribe to it
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        }
    }
    
    for (CBCharacteristic *characteristic in service.characteristics){
        [peripheral discoverDescriptorsForCharacteristic:characteristic];
        
    }
}

-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:kTransferTextCharacteristicUUID]]) {
        NSString *stringFromData = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
        NSLog(@">>>Received: %@", stringFromData);
        mvc.receivedTextView.text = stringFromData;
    }
    
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:kTransferImageCharacteristicUUID]]) {
        NSString *testString = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
        if ([testString isEqualToString:@"EOM"]) {
            NSLog(@">>>Receive image");
            mvc.receivedImageView.image = [UIImage imageWithData:_picData];
            _picData = [[NSMutableData alloc] init];
        }
        else {
            [_picData appendData:characteristic.value];
        }
    }
}

- (void)writeCharacteristic:(CBPeripheral *)peripheral characteristic:(CBCharacteristic *)characteristic value:(NSData *)value {
    if(characteristic.properties & CBCharacteristicPropertyWrite) {
        [peripheral writeValue:value forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
    } else {
        NSLog(@">>>Cannot write！");
    }
    
    
}

// stopScanning and disconnect
- (void)disconnectPeripheral:(CBCentralManager *)centralManager peripheral:(CBPeripheral *)peripheral {
    [centralManager stopScan];

    [centralManager cancelPeripheralConnection:peripheral];
}

#pragma mark - IBAction
- (IBAction)didTapConnectBtn:(id)sender {
    NSIndexPath *indexPath = _deviceTable.indexPathForSelectedRow;
    UITableViewCell *cell = [_deviceTable cellForRowAtIndexPath:indexPath];
    if (cell != nil) {
        [manager connectPeripheral:_discoverPeripherals[indexPath.row] options:nil];
    }
}

@end
