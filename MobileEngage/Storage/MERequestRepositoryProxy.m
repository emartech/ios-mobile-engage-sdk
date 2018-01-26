//
// Copyright (c) 2018 Emarsys. All rights reserved.
//

#import "MERequestRepositoryProxy.h"
#import "MEButtonClickRepository.h"
#import "MEDisplayedIAMRepository.h"
#import "MERequestModelSelectEventsSpecification.h"
#import "EMSRequestModelBuilder.h"
#import "EMSCompositeRequestModel.h"
#import "MERequestTools.h"

@interface MERequestRepositoryProxy ()

@property(nonatomic, strong) EMSRequestModelRepository *requestModelRepository;

@end

@implementation MERequestRepositoryProxy

- (instancetype)initWithRequestModelRepository:(EMSRequestModelRepository *)requestModelRepository
                         buttonClickRepository:(MEButtonClickRepository *)buttonClickRepository
                        displayedIAMRepository:(MEDisplayedIAMRepository *)displayedIAMRepository {
    self = [super init];
    if (self) {
        _requestModelRepository = requestModelRepository;
    }

    return self;
}

- (void)add:(EMSRequestModel *)item {
    [self.requestModelRepository add:item];
}

- (void)remove:(id <EMSSQLSpecificationProtocol>)sqlSpecification {
    [self.requestModelRepository remove:sqlSpecification];
}

- (NSArray<EMSRequestModel *> *)query:(id <EMSSQLSpecificationProtocol>)sqlSpecification {
    NSArray<EMSRequestModel *> *queriedArray = [self.requestModelRepository query:sqlSpecification];
    NSMutableArray<EMSRequestModel *> *resultModels = [NSMutableArray array];
    BOOL shouldCreateComposite = YES;

    for (EMSRequestModel *requestModel in queriedArray) {
        if ([self isCustomEvent:requestModel]) {
            if (shouldCreateComposite) {
                [resultModels addObject:[self createCompositeRequestModel:requestModel]];
                shouldCreateComposite = NO;
            }
        } else {
            [resultModels addObject:requestModel];
        }
    }

    return resultModels;
}

- (EMSRequestModel *)createCompositeRequestModel:(EMSRequestModel *)requestModel {
    NSArray *allCustomEvents = [self.requestModelRepository query:[MERequestModelSelectEventsSpecification new]];
    NSMutableArray <NSString *> *requestIds = [NSMutableArray array];
    EMSCompositeRequestModel *composite = [EMSCompositeRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
        [builder setUrl:[[requestModel url] absoluteString]];
        NSMutableArray *eventNames = [NSMutableArray new];
        for (EMSRequestModel *model in allCustomEvents) {
            [eventNames addObject:[model.payload[@"events"] firstObject]];
            [requestIds addObject:model.requestId];
        }
        [builder setPayload:@{@"events": eventNames}];
    }];
    composite.originalRequestIds = [NSArray arrayWithArray:requestIds];
    return composite;
}

- (BOOL)isCustomEvent:(EMSRequestModel *)requestModel {
    return [MERequestTools isRequestCustomEvent:requestModel];
}

- (BOOL)isEmpty {
    return [self.requestModelRepository isEmpty];
}

@end