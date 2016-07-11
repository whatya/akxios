//
//  DXAnnotationSettings.m
//  CustomCallout
//
//  Created by Selvin on 12/04/15.
//  Copyright (c) 2015 S3lvin. All rights reserved.
//

#import "DXAnnotationSettings.h"

@implementation DXAnnotationSettings

+ (instancetype)defaultSettings {
    DXAnnotationSettings *newSettings = [[super alloc] init];
    if (newSettings) {
        newSettings.calloutOffset = 0.0f;

        newSettings.shouldRoundifyCallout = YES;
        newSettings.calloutCornerRadius = 25.0f;

        newSettings.shouldAddCalloutBorder = YES;
        newSettings.calloutBorderColor = [UIColor colorWithRed:211/255.0 green:211/255.0 blue:211/255.0 alpha:1];
        newSettings.calloutBorderWidth = 0.0;

        newSettings.animationType = DXCalloutAnimationZoomIn;
        newSettings.animationDuration = 0.25;
    }
    return newSettings;
}

@end
