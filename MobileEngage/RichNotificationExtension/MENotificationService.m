//
//  Copyright © 2017. Emarsys. All rights reserved.
//

#import <CoreSDK/EMSDictionaryValidator.h>
#import "MENotificationService.h"

#define IMAGE_URL @"image_url"

typedef void(^AttachmentsBlock)(NSArray<UNNotificationAttachment *> *);

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

        __weak typeof(self) weakSelf = self;
        [[UNUserNotificationCenter currentNotificationCenter] getNotificationCategoriesWithCompletionHandler:^(NSSet<UNNotificationCategory *> *categories) {
            [[UNUserNotificationCenter currentNotificationCenter] setNotificationCategories:[categories setByAddingObjectsFromArray:@[category]]];
            [weakSelf attachmentsForContent:request.content
                           attachmentsBlock:^(NSArray<UNNotificationAttachment *> *attachments) {
                               content.attachments = attachments;
                               contentHandler(content.copy);
                           }];
        }];
    } else {
        [self attachmentsForContent:request.content
                   attachmentsBlock:^(NSArray<UNNotificationAttachment *> *attachments) {
                       content.attachments = attachments;
                       contentHandler(content.copy);
                   }];
    }
}

- (void)serviceExtensionTimeWillExpire {
    self.contentHandler(self.bestAttemptContent);
}

- (UNMutableNotificationContent *)mutableCopyOfContent:(UNNotificationRequest *)request {
    return (UNMutableNotificationContent *) [request.content mutableCopy];
}

- (void)attachmentsForContent:(UNNotificationContent *)content
             attachmentsBlock:(AttachmentsBlock)attachmentsBlock {
    NSURL *mediaUrl = [NSURL URLWithString:content.userInfo[IMAGE_URL]];
    if (mediaUrl) {
        __weak typeof(self) weakSelf = self;
        NSURLSessionDownloadTask *task = [[NSURLSession sharedSession] downloadTaskWithURL:mediaUrl
                                                                         completionHandler:^(NSURL *_Nullable location, NSURLResponse *_Nullable response, NSError *_Nullable error) {
                                                                             NSError *moveError;
                                                                             NSURL *mediaFileUrl = [weakSelf createLocalTempUrlFromRemoteUrl:mediaUrl];
                                                                             if (location && mediaFileUrl) {
                                                                                 BOOL moveSuccess = [[NSFileManager defaultManager] moveItemAtURL:location
                                                                                                                                            toURL:mediaFileUrl
                                                                                                                                            error:&moveError];
                                                                                 if (moveSuccess && !moveError) {
                                                                                     NSError *attachmentCreationError;
                                                                                     UNNotificationAttachment *attachment = [UNNotificationAttachment attachmentWithIdentifier:mediaFileUrl.lastPathComponent
                                                                                                                                                                           URL:mediaFileUrl
                                                                                                                                                                       options:nil
                                                                                                                                                                         error:&attachmentCreationError];
                                                                                     if (attachment && !attachmentCreationError) {
                                                                                         attachmentsBlock(@[attachment]);
                                                                                     } else {
                                                                                         attachmentsBlock(nil);
                                                                                     }
                                                                                 } else {
                                                                                     attachmentsBlock(nil);
                                                                                 }
                                                                             } else {
                                                                                 attachmentsBlock(nil);
                                                                             }
                                                                         }];
        [task resume];
    } else {
        attachmentsBlock(nil);
    }
}

- (NSURL *)createLocalTempUrlFromRemoteUrl:(NSURL *)remoteUrl {
    NSURL *mediaFileUrl;
    NSString *mediaFileName = remoteUrl.lastPathComponent;
    NSString *tmpSubFolderName = [[NSProcessInfo processInfo] globallyUniqueString];
    NSURL *tmpSubFolderUrl = [[NSURL fileURLWithPath:NSTemporaryDirectory()] URLByAppendingPathComponent:tmpSubFolderName];
    NSError *directoryCreationError;
    [[NSFileManager defaultManager] createDirectoryAtURL:tmpSubFolderUrl
                             withIntermediateDirectories:YES
                                              attributes:nil
                                                   error:&directoryCreationError];
    if (!directoryCreationError && tmpSubFolderName && mediaFileName) {
        mediaFileUrl = [tmpSubFolderUrl URLByAppendingPathComponent:mediaFileName];
    }
    return mediaFileUrl;
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
            if ([typeSpecificErrors count] == 0 && [[NSURL alloc] initWithString:urlString] == nil) {
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
                                                        options:UNNotificationActionOptionForeground];
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
