//
//  DemoClass.m
//  CameraDemo
//
//  Created by Ivan Esparza on 2/11/19.
//  Copyright © 2019 ivanebernal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CameraDemo-Bridging-Header.h"


@implementation DemoClass

@synthesize someProperty= _someProperty;

+ (void)printHelloWorld {
  NSLog(@"Hello, World!");
}

+ (void)printHelloWorldAnd:(NSString *)string {
  NSLog(@"Hello, World! %@", string);
}

@end
