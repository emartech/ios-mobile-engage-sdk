//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "EMSRequestModelMatcher.h"


@implementation EMSRequestModelMatcher {
    id _otherSubject;
}

#pragma mark - Getting Matcher Strings

+ (NSArray *)matcherStrings {
    return @[@"beSimilarWithRequest:"];
}

#pragma mark - Getting Failure Messages

- (NSString *)failureMessageForShould {
    return @"expected subject to be similar";
}

- (NSString *)failureMessageForShouldNot {
    return @"expected subject to be NOT similar";
}

#pragma mark - Matching

- (BOOL)evaluate {
    if (self.subject == _otherSubject)
        return YES;
    if (_otherSubject == nil)
        return NO;
    if ([self.subject url] != [_otherSubject url] && ![[self.subject url] isEqual:[_otherSubject url]])
        return NO;
    if ([self.subject method] != [_otherSubject method] && ![[self.subject method] isEqualToString:[_otherSubject method]])
        return NO;
    if ([self.subject body] != [_otherSubject body] && ![[self.subject body] isEqualToData:[_otherSubject body]])
        return NO;
    if ([self.subject headers] != [_otherSubject headers] && ![[self.subject headers] isEqualToDictionary:[_otherSubject headers]])
        return NO;
    return YES;
}

- (void)beSimilarWithRequest:(EMSRequestModel *)model {
    _otherSubject = model;
}


@end