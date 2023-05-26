//
//  resource_bundle_accessor.m
//  
//
//  Created by Dima Bulash on 26/05/2023.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface EXAMPLEPACKAGE_EXAMPLETARGET_SWIFTPM_MODULE_BUNDLER_FINDER : NSObject
@end

@implementation EXAMPLEPACKAGE_EXAMPLETARGET_SWIFTPM_MODULE_BUNDLER_FINDER
@end

NSBundle* EXAMPLEPACKAGE_EXAMPLETARGET_SWIFTPM_MODULE_BUNDLE() {
    NSString *bundleName = @"ExamplePackage_ExampleTarget";

    NSArray<NSURL*> *candidates = @[
        NSBundle.mainBundle.resourceURL,
        [NSBundle bundleForClass:[EXAMPLEPACKAGE_EXAMPLETARGET_SWIFTPM_MODULE_BUNDLER_FINDER class]].resourceURL,
        NSBundle.mainBundle.bundleURL
    ];

    for (NSURL* candiate in candidates) {
        NSURL *bundlePath = [candiate URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.bundle", bundleName]];

        NSBundle *bundle = [NSBundle bundleWithURL:bundlePath];
        if (bundle != nil) {
            return bundle;
        }
    }

    @throw [[NSException alloc] initWithName:@"SwiftPMResourcesAccessor" reason:[NSString stringWithFormat:@"unable to find bundle named %@", bundleName] userInfo:nil];
}

NS_ASSUME_NONNULL_END
