//
//  TempObject.m
//  TestGoogleCast
//
//  Created by DavidLi on 12/10/14.
//  Copyright (c) 2014 DavidLi. All rights reserved.
//

#import "TempObject.h"

@implementation TempObject

-(void)test{
    dispatch_queue_t myQueue = dispatch_queue_create("DavidLiQueue", NULL);
    dispatch_async(myQueue, ^{
        //
    });
    
}
@end

