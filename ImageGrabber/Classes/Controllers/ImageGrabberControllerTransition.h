//
//  ImageGrabberControllerTransition.h
//  ImageGrabber
//
//  Created by Fanghao Chen on 5/3/14.
//  Copyright (c) 2014 Fanghao Chen. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    TransitionTypeFade = 0
} TransitionType;

@interface ImageGrabberControllerTransition : NSObject <UIViewControllerAnimatedTransitioning>

- (id)initWithType:(TransitionType)type;

@end
