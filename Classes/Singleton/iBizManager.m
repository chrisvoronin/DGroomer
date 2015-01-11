//
//  iBizManager.m
//  iBiz
//
//  Created by Oleksandr Shelestyuk on 4/14/14.
//  Copyright (c) 2014 SalonTechnologies, Inc. All rights reserved.
//

#import "iBizManager.h"

@implementation iBizManager

+ (iBizManager *)sharedManager {
    static iBizManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (sharedManager == nil) {
            sharedManager = [[iBizManager alloc] init];
            [sharedManager setup];
        }
    });
    return sharedManager;
}

- (id)init {
    if (self = [super init]) {
        [self setup];
    }
    return self;
}

- (void)dealloc {
}

- (void)setup {
}

@end
