//
//  Use this file to import your target's public headers that you would like to expose to Swift.
//
#import <Foundation/Foundation.h>

@interface DemoClass : NSObject
{
  int* someInt;
  NSString* someString;
}

@property int someProperty;

+(void)printHelloWorld;
+(void)printHelloWorldAnd:(NSString*)string;

@end
