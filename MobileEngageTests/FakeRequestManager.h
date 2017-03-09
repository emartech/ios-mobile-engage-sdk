//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSRequestManager.h"

typedef enum {
    ResponseTypeSuccess,
    ResponseTypeFailure
} ResponseType;

@interface FakeRequestManager : EMSRequestManager

@property(nonatomic, assign) ResponseType responseType;

@end