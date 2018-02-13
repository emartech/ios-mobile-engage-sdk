//
// Copyright (c) 2018 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreSDK/EMSSQLiteHelper.h>
#import "MEDisplayedIAM.h"
#import <CoreSDK/EMSSQLSpecificationProtocol.h>
#import <CoreSDK/EMSRepositoryProtocol.h>

@interface MEDisplayedIAMRepository : NSObject <EMSRepositoryProtocol>

- (instancetype)initWithDbHelper:(EMSSQLiteHelper *)sqliteHelper;
- (void)add:(MEDisplayedIAM *)item;
- (void)remove:(id<EMSSQLSpecificationProtocol>)sqlSpecification;
- (NSArray<MEDisplayedIAM *> *)query:(id<EMSSQLSpecificationProtocol>)sqlSpecification;

@end