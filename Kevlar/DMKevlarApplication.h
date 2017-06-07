//
//  DMKevlarApplication.h
//  Kevlar
//
//  Copyright (c) 2012-2016 DevMate Inc. All rights reserved.
//

#ifndef DMKevlarApplication_h
#define DMKevlarApplication_h

#import <Cocoa/Cocoa.h>
#import <AvailabilityMacros.h>
#import <sys/types.h>
#import <sys/ptrace.h>

#define KEVLAR_VERSION  @"4.2.2"

// -------------------------------------------------------------------------------------------------
// SOME ADDITIONAL INLINE FUNCTIONS

NS_INLINE void DMKStopDebug(void)
{
#ifndef DEBUG
    ptrace(PT_DENY_ATTACH, 0, 0, 0);
#endif
}

//! CodeSign validation function that will raise an excetions in case when signature is wrong
#define DMKCheckBundleSignatureWithURL mC6FA5P56bdb9rh
FOUNDATION_EXTERN void DMKCheckBundleSignatureWithURL(CFURLRef bundleURL, SecCSFlags validationFlags);

NS_INLINE void DMKCheckMainBundleSignature(void)
{
    CFURLRef mainBundleURL = CFBundleCopyBundleURL(CFBundleGetMainBundle());
    @try
    {
        DMKCheckBundleSignatureWithURL(mainBundleURL, kSecCSDefaultFlags);
    }
    @finally
    {
        CFRelease(mainBundleURL);
    }
}

// -------------------------------------------------------------------------------------------------

FOUNDATION_EXTERN NSString *const DMKevlarErrorDomain;

typedef NS_ENUM (NSInteger, DMKevlarError)
{
    DMKevlarTestError                       = NSIntegerMax, // proposed to init your var with this test code. After validation it should be changed to one of the other codes below.
    
    DMKevlarNoError                         = 0,
    
    DMKevlarGeneralError                    = -100,
    DMKevlarActivationInProcess             = -101,
    
    DMKevlarEmptyProduct                    = 1,
    DMKevlarNoSuchProduct                   = 2,
    DMKevlarAbsentUsername                  = 3,
    DMKevlarAbsentActivationCode            = 4,
    DMKevlarNeedProductUpgrade              = 5,
    DMKevlarOldKeyUsed                      = 6,
    DMKevlarWrongActivationNumber           = 7,
    DMKevlarKeyAlreadyActivated             = 8,
    DMKevlarFailedToReactivate              = 9,
    DMKevlarKeyExpired                      = 10,
    DMKevlarInternalServerError             = 11,
    DMKevlarKeyForOtherProduct              = 12,
    DMKevlarReactivationKeyNotFound         = 14,
    DMKevlarBetaOnlyKeyError                = 15,
    DMKevlarProductVersionExpired           = 16,
    DMKevlarServerValidationError           = 17,
    DMKevlarProductDeactivated              = 18,
    DMKevlarOrderWasRefunded                = 19,
    DMKevlarSubscriptionWasCanceled         = 20,
    DMKevlarSubscriptionChargeFailed        = 21,
    DMKevlarSubscriptionExpired             = 22,
    
    DMKevlarLicenseAbsentError              = 100,
    DMKevlarLicenseSignatureError           = 101,
    DMKevlarLicenseValidationError          = 102,
};

typedef NS_OPTIONS(NSUInteger, DMKLicenseStorageLocation)
{
    DMKLicenseStorageUnknown                = 0,
    DMKLicenseStoragePreferencesMask		= 1 << 0,
    DMKLicenseStorageApplicationSupportMask = 1 << 1,
    DMKLicenseStorageSharedMask             = 1 << 2, // to support in sandboxed app, add com.apple.security.temporary-exception.files.absolute-path.read-write with "/Users/Shared/" to your entitlements file
    DMKLicenseStorageKeychainMask           = 1 << 3, // !!! not supported yet
    
    DMKLicenseStorageAllMask                = DMKLicenseStoragePreferencesMask | DMKLicenseStorageApplicationSupportMask | DMKLicenseStorageSharedMask | DMKLicenseStorageKeychainMask
};

//! Activation info keys for activating product
FOUNDATION_EXTERN NSString *const DMKevlarRequestFullName; // NSString
FOUNDATION_EXTERN NSString *const DMKevlarRequestUserEmail; // NSString
FOUNDATION_EXTERN NSString *const DMKevlarRequestActivationKey; // NSString
FOUNDATION_EXTERN NSString *const DMKevlarRequestReactivationBundle; // NSString
FOUNDATION_EXTERN NSString *const DMKevlarRequestReactivationIdentifier; // NSString
FOUNDATION_EXTERN NSString *const DMKevlarRequestAdditionalInfo; // NSDictionary

//! License info keys
FOUNDATION_EXTERN NSString *const DMKevlarLicenseActivationIdKey; // NSString, license identifier
FOUNDATION_EXTERN NSString *const DMKevlarLicenseActivationNumberKey; // NSString, activation number that was used to activate app
FOUNDATION_EXTERN NSString *const DMKevlarLicenseUserNameKey; // NSString
FOUNDATION_EXTERN NSString *const DMKevlarLicenseUserEmailKey; // NSString
FOUNDATION_EXTERN NSString *const DMKevlarLicenseCompanyKey; // NSString, may be absent
FOUNDATION_EXTERN NSString *const DMKevlarLicenseOrderDateKey; // NSDate
FOUNDATION_EXTERN NSString *const DMKevlarLicenseActivationDateKey; // NSDate
FOUNDATION_EXTERN NSString *const DMKevlarLicenseExpirationDateKey; // NSDate, may be absent in case of lifetime
FOUNDATION_EXTERN NSString *const DMKevlarLicenseExpirationVersionKey; // NSString, may be absent in case of lifetime
FOUNDATION_EXTERN NSString *const DMKevlarLicenseActivationTagKey; // NSString, may be absent
FOUNDATION_EXTERN NSString *const DMKevlarLicenseBetaOnlyKey; // NSNumber with BOOL
FOUNDATION_EXTERN NSString *const DMKevlarLicenseIsSubscriptionKey; // NSNumber with BOOL, may be nil
FOUNDATION_EXTERN NSString *const DMKevlarLicenseSubscriptionUpdateDateKey; // NSDate, last subscription charging date, may be nil
FOUNDATION_EXTERN NSString *const DMKevlarLicenseSubscriptionExpirationDateKey; // NSDate, date that subscription was charged to, may be nil
FOUNDATION_EXTERN NSString *const DMKevlarLicenseLastServerConnectionDateKey; // NSDate, date of last successfull connection date

//! Notifications
FOUNDATION_EXTERN NSString *const DMKBundleIntegrityDidChangeNotification;
FOUNDATION_EXTERN NSString *const DMKApplicationActivationStatusDidChangeNotification;


//! Function help with running timer for advanced check
#define DMKRunNewIntegrityCheckTimer dJLa7Bay32ylTp41k
FOUNDATION_EXTERN void DMKRunNewIntegrityCheckTimer(NSUInteger num, NSTimeInterval checkFrequency);

//! Checks if applicaion activated
#define DMKIsApplicationActivated YkJsvOBlL802Crpxgg
FOUNDATION_EXTERN BOOL DMKIsApplicationActivated(DMKevlarError *outKevlarError);

//! Returns user license info
#define DMKCopyLicenseUserInfo qbAw9wHuiDLE8WNeocu
FOUNDATION_EXTERN CFDictionaryRef DMKCopyLicenseUserInfo(void) CF_RETURNS_RETAINED;

//! Forces license validation request on DevMate server
#define DMKValidateLicense Y2UpDIGNPViBrVX4W6YZ
FOUNDATION_EXTERN void DMKValidateLicense(void (^completionHandler)(NSError *errorOrNil));

//! Deactivates application and invalidates license info
#define DMKInvalidateLicense zld889ivLA59KRvmxfb7N
FOUNDATION_EXTERN BOOL DMKInvalidateLicense(void);

/**
 This category will extend functionality of NSApplication to be complies with Kevlar concept of protection.
 Rigth now, some helper inteface have been declare there, because it is kind of complicated to load category.
 */
#define com_devmate_Kevlar MdHXMpVAQi
@interface NSApplication (com_devmate_Kevlar)

/**
 Deprecated. Property is not used for storing license info anymore.
 */
#define licenseStorageFormat cuC5lDRCR1y
@property (nonatomic) NSPropertyListFormat licenseStorageFormat DEPRECATED_MSG_ATTRIBUTE("Property is not used for storing license info anymore.");

/**
 Deprecated. Use licenseStorageLocation property instead.
 */
#define licenseStoragePath sIVfcThzXKM5
@property (nonatomic) NSSearchPathDirectory licenseStoragePath DEPRECATED_MSG_ATTRIBUTE("Use licenseStorageLocation property instead.");

/**
 License could be store in different location, this option provied information to application, where to find and where to store license. Property is bitwise mask.
 Default is DMKLicenseStorageAllMask
 */
#define licenseStorageLocation HtaYcLY198SvKj6Be
@property (nonatomic) DMKLicenseStorageLocation licenseStorageLocation;

/** 
 Indicate application activation status. This option is usefull for bindings. For more security use DMKIsApplicationActivated function.
 */
#define isActivated Iwl450qahiIuIdi
@property (nonatomic, readonly) BOOL isActivated;

/**
 Return user-friendly information about license, with out any system information. For more security use DMKCopyLicenseUserInfo function.
 */
#define licenseUserInfo VNCd4jWT5R8Of5
@property (nonatomic, readonly) NSDictionary *licenseUserInfo;

/**
 Removes all license info on local storages and sends server request to deactivate it.
 In case, if license was invalidated, this method removes all license information
 */
#define invalidateLicense wA4gZImVxrFts
- (BOOL)invalidateLicense;

/** 
 Activate process 
 @param activationInfo data that will be used for action
 @param handler block will invoke to handle actiontion proccess
 */
- (void)activateWithInfo:(NSDictionary *)activationInfo completionHandler:(void (^)(BOOL success, NSError *error))handler;

/** 
 Setup public key
 @param publicKey String with public key
 */
#define setPublicKeyWithString AGQRw30liVDbLaGS
+ (void)setPublicKeyWithString:(NSString *)keyString DEPRECATED_MSG_ATTRIBUTE("Does nothing now.");

@end

#endif // DMKevlarApplication_h
