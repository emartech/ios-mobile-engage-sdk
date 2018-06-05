//
//  Copyright © 2017. Emarsys. All rights reserved.
//

#import <CoreSDK/EMSDictionaryValidator.h>
#import "MENotificationService.h"
#import "UNNotificationAttachment+MobileEngage.h"

#define IMAGE_URL @"image_url"

@interface MENotificationService ()

@property(nonatomic, strong) void (^contentHandler)(UNNotificationContent *contentToDeliver);
@property(nonatomic, strong) UNMutableNotificationContent *bestAttemptContent;

@end

@implementation MENotificationService

#pragma mark - UNNotificationServiceExtension

- (void)didReceiveNotificationRequest:(UNNotificationRequest *)request
                   withContentHandler:(void (^)(UNNotificationContent *_Nonnull))contentHandler {
    self.contentHandler = contentHandler;
    self.bestAttemptContent = [self mutableCopyOfContent:request];

    UNMutableNotificationContent *content = [self mutableCopyOfContent:request];
    if (!content) {
        contentHandler(request.content);
        return;
    }

    NSArray *actionArray = [self extractActionsFromContent:content];
    if (actionArray) {
        NSMutableArray *actions = [NSMutableArray array];
        for (NSDictionary *actionDict in actionArray) {
            UNNotificationAction *action = [self createActionFromActionDictionary:actionDict];
            if (action) {
                [actions addObject:action];
            }
        }
        NSString *const categoryIdentifier = [NSUUID UUID].UUIDString;
        UNNotificationCategory *category = [UNNotificationCategory categoryWithIdentifier:categoryIdentifier
                                                                                  actions:actions
                                                                        intentIdentifiers:@[]
                                                                                  options:0];
        content.categoryIdentifier = categoryIdentifier;

        [[UNUserNotificationCenter currentNotificationCenter] getNotificationCategoriesWithCompletionHandler:^(NSSet<UNNotificationCategory *> *categories) {
            [[UNUserNotificationCenter currentNotificationCenter] setNotificationCategories:[categories setByAddingObjectsFromArray:@[category]]];
            [self setAttachmentsWithRequest:request
                                    content:content];
            contentHandler(content.copy);
        }];
    } else {
        [self setAttachmentsWithRequest:request
                                content:content];
        contentHandler(content.copy);
    }
}

- (void)setAttachmentsWithRequest:(UNNotificationRequest *)request content:(UNMutableNotificationContent *)content {
    NSArray<UNNotificationAttachment *> *attachments = [self attachmentsForContent:request.content];
    if (attachments) {
        content.attachments = attachments;
    }
}

- (void)serviceExtensionTimeWillExpire {
    self.contentHandler(self.bestAttemptContent);
}

- (UNMutableNotificationContent *)mutableCopyOfContent:(UNNotificationRequest *)request {
    return (UNMutableNotificationContent *) [request.content mutableCopy];
}

- (NSArray<UNNotificationAttachment *> *)attachmentsForContent:(UNNotificationContent *)content {
    NSURL *mediaUrl = [NSURL URLWithString:content.userInfo[IMAGE_URL]];
    NSArray<UNNotificationAttachment *> *attachments;
    if (mediaUrl) {
        UNNotificationAttachment *attachment = [UNNotificationAttachment attachmentWithMediaUrl:mediaUrl
                                                                                        options:nil];
        if (attachment) {
            attachments = @[attachment];
        }
    }
    return attachments;
}

- (UNNotificationAction *)createActionFromActionDictionary:(NSDictionary *)actionDictionary {
    UNNotificationAction *result;
    NSArray *commonKeyErrors = [actionDictionary validate:^(EMSDictionaryValidator *validate) {
        [validate valueExistsForKey:@"id" withType:[NSString class]];
        [validate valueExistsForKey:@"title" withType:[NSString class]];
        [validate valueExistsForKey:@"type" withType:[NSString class]];
    }];
    if ([commonKeyErrors count] == 0) {
        NSArray *typeSpecificErrors;
        NSString *type = actionDictionary[@"type"];
        if ([type isEqualToString:@"MEAppEvent"]) {
            typeSpecificErrors = [actionDictionary validate:^(EMSDictionaryValidator *validate) {
                [validate valueExistsForKey:@"name" withType:[NSString class]];
            }];
        } else if ([type isEqualToString:@"OpenExternalUrl"]) {
            typeSpecificErrors = [actionDictionary validate:^(EMSDictionaryValidator *validate) {
                [validate valueExistsForKey:@"url" withType:[NSString class]];
            }];
            NSString *const urlString = actionDictionary[@"url"];
            if([typeSpecificErrors count] == 0 && [[NSURL alloc] initWithString:urlString] == nil) {
                typeSpecificErrors = @[[NSString stringWithFormat:@"Invalid URL: %@", urlString]];
            }
        } else if ([type isEqualToString:@"MECustomEvent"]) {
            typeSpecificErrors = [actionDictionary validate:^(EMSDictionaryValidator *validate) {
                [validate valueExistsForKey:@"name" withType:[NSString class]];
            }];
        }
        if (typeSpecificErrors && [typeSpecificErrors count] == 0) {
            result = [UNNotificationAction actionWithIdentifier:actionDictionary[@"id"]
                                                          title:actionDictionary[@"title"]
                                                        options:UNNotificationActionOptionNone];
        }
    }
    return result;
}

- (NSArray *)extractActionsFromContent:(UNMutableNotificationContent *)content {
    NSArray *actions;
    NSArray *emsErrors = [content.userInfo validate:^(EMSDictionaryValidator *validate) {
        [validate valueExistsForKey:@"ems"
                           withType:[NSDictionary class]];
    }];
    if ([emsErrors count] == 0) {
        NSDictionary *ems = content.userInfo[@"ems"];
        NSArray *actionsErrors = [ems validate:^(EMSDictionaryValidator *validate) {
            [validate valueExistsForKey:@"actions"
                               withType:[NSArray class]];
        }];
        if ([actionsErrors count] == 0) {
            actions = content.userInfo[@"ems"][@"actions"];
        }
    }
    return actions;
}

@end
