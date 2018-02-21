//
//  Copyright © 2018 Emarsys. All rights reserved.
//

@import Foundation;
@import EmarsysCore;

#import "MEButtonClick.h"

@interface MEButtonClickRepository : NSObject <EMSRepositoryProtocol>

- (instancetype)initWithDbHelper:(EMSSQLiteHelper *)sqliteHelper;
- (void)add:(MEButtonClick *)item;
- (void)remove:(id<EMSSQLSpecificationProtocol>)sqlSpecification;
- (NSArray<MEButtonClick *> *)query:(id<EMSSQLSpecificationProtocol>)sqlSpecification;

@end
