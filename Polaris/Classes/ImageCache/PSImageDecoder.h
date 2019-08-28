//
//  PSImageDecoder.h
//  Expecta
//
//  Created by Jekity on 2019/8/26.
//

#import <Foundation/Foundation.h>
#import "PSImageCacheUtils.h"


@interface PSImageDecoder : NSObject

- (UIImage*)imageWithFile:(void*)file
              contentType:(PSImageContentType)contentType
                    bytes:(void*)bytes
                   length:(size_t)length
                 drawSize:(CGSize)drawSize
          contentsGravity:(NSString* const)contentsGravity
             cornerRadius:(CGFloat)cornerRadius;

@end

