//
//  YMVoiceConverter.m
//  Jeans
//
//  Created by Jeans Huang on 12-7-22.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "YMVoiceConverter.h"
#import "wav.h"
#import "interf_dec.h"
#import "dec_if.h"
#import "interf_enc.h"
#import "YMAmrFileCodec.h"

@implementation YMVoiceConverter

+ (int)amrToWav:(NSString*)_amrPath wavSavePath:(NSString*)_savePath{
    
    if (! YM_DecodeAMRFileToWAVEFile([_amrPath cStringUsingEncoding:NSASCIIStringEncoding], [_savePath cStringUsingEncoding:NSASCIIStringEncoding]))
        return 0;
    
    return 1;
}

+ (int)wavToAmr:(NSString*)_wavPath amrSavePath:(NSString*)_savePath{
    
    if (YM_EncodeWAVEFileToAMRFile([_wavPath cStringUsingEncoding:NSASCIIStringEncoding], [_savePath cStringUsingEncoding:NSASCIIStringEncoding], 1, 16))
        return 0;
    
    return 1;
}
    
    
@end
