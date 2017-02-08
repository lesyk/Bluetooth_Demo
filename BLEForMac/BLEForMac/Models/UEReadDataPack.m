//
//  UEReadDataPack.m
//  BlueDemo
//
//  Created by wulanzhou on 16/4/19.
//  Copyright © 2016年 wulanzhou. All rights reserved.
//

#import "UEReadDataPack.h"

@implementation UEReadDataPack

- (id)init{

    if (self=[super init]) {
        
        self.readTotalData=[[NSMutableData alloc] initWithCapacity:1024];
        self.isTotalReadFinished=NO;
        
        self.readBodyData=[[NSMutableData alloc] initWithCapacity:1024];
        self.isBodyReadFinished=NO;
        
        self.isReadFinished=NO;
    }
    return self;
}

- (float)progress{

    if (self.bodyLen==0||!self.isTotalReadFinished) {
        return 0.0;
    }
    
    return self.readBodyLen*1.0/self.bodyLen;
}

@end
