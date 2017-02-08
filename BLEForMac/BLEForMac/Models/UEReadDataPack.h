//
//  UEReadDataPack.h
//  BlueDemo
//
//  Created by wulanzhou on 16/4/19.
//  Copyright © 2016年 wulanzhou. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UEReadDataPack : NSObject

@property (nonatomic,assign) NSUInteger totalLen;
@property (nonatomic,assign) NSUInteger readTotalLen;
@property (nonatomic,assign) BOOL isTotalReadFinished;
@property (nonatomic,strong) NSMutableData *readTotalData;

@property (nonatomic,assign) NSUInteger bodyLen;
@property (nonatomic,assign) NSUInteger readBodyLen;
@property (nonatomic,strong) NSMutableData *readBodyData;
@property (nonatomic,assign) BOOL isBodyReadFinished;

@property (nonatomic,assign) BOOL isReadFinished;
@property (nonatomic,readonly) float progress;

@end
