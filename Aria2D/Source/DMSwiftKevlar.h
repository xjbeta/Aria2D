//
//  DMSwiftKevlar.h
//  Examples
//
//  Created by Dmytro Tretiakov on 6/15/15.
//  Copyright © 2015 DevMate Inc. All rights reserved.
//

#import "DMKevlarApplication.h"

typedef BOOL (*DMKIsApplicationActivatedFunc)(NSInteger *);
static DMKIsApplicationActivatedFunc string_check = &DMKIsApplicationActivated;

typedef CFDictionaryRef (*DMKCopyLicenseUserInfoFunc)(void);
static DMKCopyLicenseUserInfoFunc string_info = &DMKCopyLicenseUserInfo;

void InvalidateAppLicense(void);

