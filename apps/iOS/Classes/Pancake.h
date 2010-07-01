//
//  Pancake.h
//  Wondew
//
//  Created by Nathan Nichols on 6/30/10.
//  Copyright 2010 InfoLab, Northwestern Univeristy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSON.h"


@interface Pancake : NSObject {
    @private
    SBJSON *json;
    NSMutableData *responseData;
}

-(void)load;
-(void)addWondew:(NSString *)text inProject:(NSString *)projectTitle;
@end
