//
//  Copyright © 2018 Emarsys. All rights reserved.
//

@import Foundation;
@import EmarsysCore;

@interface MEInAppMessage : NSObject

@property (nonatomic, readonly) NSString *campaignId;
@property (nonatomic, readonly) NSString *html;

- (instancetype)initWithResponseParsedBody:(NSDictionary *)parsedBody;

- (BOOL)isEqual:(id)other;

- (BOOL)isEqualToMessage:(MEInAppMessage *)message;

- (NSUInteger)hash;

@end
