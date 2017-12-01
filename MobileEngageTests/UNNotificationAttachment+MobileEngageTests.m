//
//  Copyright © 2017 Emarsys. All rights reserved.
//

#import "Kiwi.h"
#import "UNNotificationAttachment+MobileEngage.h"
#import "UNNotificationAttachment+Private.h"
#import "MEOsVersionUtils.h"

SPEC_BEGIN(UNNotificationAttachmentMobileEngage)
    if (!SYSTEM_VERSION_LESS_THAN(@"10.0")) {
        describe(@"attachmentWithMediaUrl:options:", ^{
            it(@"should return nil when media file is not available on the url", ^{
                UNNotificationAttachment *attachment = [UNNotificationAttachment attachmentWithMediaUrl:[NSURL URLWithString:@"https://www.sample.com/img.png"]
                                                                                                options:nil];
                [[attachment should] beNil];
            });

            it(@"should return attachment when media file is available on the url", ^{
                UNNotificationAttachment *attachment = [UNNotificationAttachment attachmentWithMediaUrl:[NSURL URLWithString:@"https://cinesnark.files.wordpress.com/2015/05/widow_mace.gif"]
                                                                                                options:nil];
                [[attachment shouldNot] beNil];
            });

            it(@"should return attachment with downloaded media", ^{
                NSURL *fileURL = [UNNotificationAttachment prepareMediaFromURL:[NSURL URLWithString:@"https://cinesnark.files.wordpress.com/2015/05/widow_mace.gif"]];
                [[theValue([[NSFileManager defaultManager] fileExistsAtPath:[fileURL path]]) should] beTrue];

            });


        });
    }
SPEC_END

