//
//  FirstViewController.m
//  RuntimeTest
//
//  Created by wdyzmx on 2019/8/24.
//  Copyright © 2019 wdyzmx. All rights reserved.
//

#import "FirstViewController.h"
#import <objc/runtime.h>
#import "SecondViewController.h"

@interface FirstViewController ()

@end

@implementation FirstViewController

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SEL originalSelector = NSSelectorFromString(@"viewDidLoad");
        SEL swizzledSelector = @selector(myViewDidLoad);
        
        Method originalMethod = class_getInstanceMethod([self class], originalSelector);
        Method swizzledMethod = class_getInstanceMethod([self class], swizzledSelector);
        
        //判断是否添加成功，未成功表示已经添加过方法
        BOOL didAddMethod = class_addMethod([self class], originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
        if (didAddMethod) {
            //替换方法
            class_replaceMethod([self class], swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
        } else {
            //交换方法
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    });
}

- (void)myViewDidLoad {
    NSLog(@"替换的方法");
    self.view.backgroundColor = [UIColor orangeColor];
    [self performSelector:NSSelectorFromString(@"foo")];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"原方法");
    self.view.backgroundColor = [UIColor redColor];
    // Do any additional setup after loading the view.
}
#pragma mark -
//+ (BOOL)resolveInstanceMethod:(SEL)sel {
//    if (sel == NSSelectorFromString(@"foo")) {
//        SEL selector = @selector(fooMethod);
//        Method method = class_getInstanceMethod([self class], selector);
//        class_addMethod([self class], sel, method_getImplementation(method), "v@:");
//        return YES;
//    }
//    return [super resolveInstanceMethod:sel];
//}
//- (void)foo {
//    NSLog(@"Doing foo");
//}

//- (void)fooMethod {
//    NSLog(@"Doing fooMethod");
//}
//
//void fooMethod(id obj, SEL _cmd) {
//    NSLog(@"Doing foo");
//}
#pragma mark -
+ (BOOL)resolveInstanceMethod:(SEL)sel {
//    if ([NSStringFromSelector(sel) isEqualToString:@"foo"]) {
//        SEL selector = @selector(fooMethod);
//        Method method = class_getInstanceMethod([self class], selector);
//        class_addMethod([self class], sel, method_getImplementation(method), "v@:");
//        return YES;
//    }
//    return [super resolveInstanceMethod:sel];
    
    return NO;//进入下一层转发forwardingTargetForSelector
}
#pragma mark -
//当resolveInstanceMethod返回NO时，接着执行forwardingTargetForSelector
- (id)forwardingTargetForSelector:(SEL)aSelector {
//    if ([NSStringFromSelector(aSelector) isEqualToString:@"foo"]) {
//        return [SecondViewController new];//返回self对象，让self对象接收这个消息
//    }
//    return [super forwardingTargetForSelector:aSelector];
    
    return nil;//进入下一层转发methodSignatureForSelector
}
#pragma mark -
//当forwardingTargetForSelector返回nil时，接着执行methodSignatureForSelector和forwardInvocation
- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    if ([NSStringFromSelector(aSelector) isEqualToString:@"foo"]) {
        return [NSMethodSignature signatureWithObjCTypes:"v@:"];//签名，进入forwardInvocation
    }
    return [super methodSignatureForSelector:aSelector];
}
#pragma mark -
- (void)forwardInvocation:(NSInvocation *)anInvocation {
    SEL sel = anInvocation.selector;
    SecondViewController *viewController = [SecondViewController new];
    if([viewController respondsToSelector:sel]) {
        [anInvocation invokeWithTarget:viewController];
    }
    else {
        [self doesNotRecognizeSelector:sel];
    }
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
