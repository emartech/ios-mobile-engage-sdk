//
//  Copyright © 2018 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "EMSSQLiteHelper.h"
#import "MESQLSpecification.h"
#import "MEButtonClick.h"

@interface MEButtonClickRepository : NSObject

- (instancetype)initWithDbHelper:(EMSSQLiteHelper *)sqliteHelper;
- (void)add:(MEButtonClick *)item;
- (void)remove:(id<MESQLSpecification>)sqlSpecification;
- (NSArray<MEButtonClick *> *)query:(id<MESQLSpecification>)sqlSpecification;

@end
