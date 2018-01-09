//
// Copyright (c) 2018 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSSQLiteHelper.h"
#import "MEDisplayedIAM.h"
#import "MESQLSpecification.h"

@interface MEDisplayedIAMRepository : NSObject

- (instancetype)initWithDbHelper:(EMSSQLiteHelper *)sqliteHelper;
- (void)add:(MEDisplayedIAM *)item;
- (void)remove:(id<MESQLSpecification>)sqlSpecification;
- (NSArray<MEDisplayedIAM *> *)query:(id<MESQLSpecification>)sqlSpecification;

@end