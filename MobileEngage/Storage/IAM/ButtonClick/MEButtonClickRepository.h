//
//  Copyright © 2018 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <CoreSDK/EMSSQLiteHelper.h>
#import <CoreSDK/EMSSQLSpecificationProtocol.h>
#import "MEButtonClick.h"
#import <CoreSDK/EMSRepositoryProtocol.h>

@interface MEButtonClickRepository : NSObject <EMSRepositoryProtocol>

- (instancetype)initWithDbHelper:(EMSSQLiteHelper *)sqliteHelper;
- (void)add:(MEButtonClick *)item;
- (void)remove:(id<EMSSQLSpecificationProtocol>)sqlSpecification;
- (NSArray<MEButtonClick *> *)query:(id<EMSSQLSpecificationProtocol>)sqlSpecification;

@end
