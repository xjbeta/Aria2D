//
//  DMSwiftKevlar.m
//  Examples
//
//  Created by Dmytro Tretiakov on 6/15/15.
//  Copyright © 2015 DevMate Inc. All rights reserved.
//

#import "DMSwiftKevlar.h"

void InvalidateAppLicense(void)
{
    @autoreleasepool
    {
        [NSApp invalidateLicense];
    }
}