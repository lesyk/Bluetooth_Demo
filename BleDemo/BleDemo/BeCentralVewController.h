#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface BeCentralVewController : UIViewController <CBCentralManagerDelegate, CBPeripheralDelegate, UITableViewDelegate, UITableViewDataSource>

@property (strong,nonatomic) NSMutableArray *deviceList;
@property (strong, nonatomic) IBOutlet UITableView *deviceTable;
@property (strong ,nonatomic) NSMutableData *picData;
@property (strong,nonatomic) NSMutableArray *discoverPeripherals;

@end
