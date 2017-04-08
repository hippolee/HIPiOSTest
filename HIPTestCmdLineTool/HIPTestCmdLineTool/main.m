//
//  main.m
//  HIPTestCmdLineTool
//
//  Created by 李腾飞 on 2017/3/8.
//  Copyright © 2017年 李腾飞. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MessageVersionTester.h"
#import "UrlAnalysisTester.h"
#import "NumAnalysisTester.h"
#import "JUMPJIDTester.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        //        [[MessageVersionTester sharedInstance] test1];
        //        [[MessageVersionTester sharedInstance] test2];
        
        
        
        //        [[UrlAnalysisTester sharedInstance] testUrlRegex];
        //        [[NumAnalysisTester sharedInstance] testNumRegex];
        [[JUMPJIDTester sharedInstance] test];
    }
    return 0;
}
