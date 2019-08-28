//
//  FlyImageTableViewCell.m
//  Demo
//
//  Created by Norris Tong on 4/14/16.
//  Copyright © 2016 NorrisTong. All rights reserved.
//

#import "FlyImageTableViewCell.h"
#import "UIImageView+CacheM.h"
//#import "ProgressImageView.h"

@implementation FlyImageTableViewCell

- (id)imageViewWithFrame:(CGRect)frame {
//    int tag = rand()%10+1;
//    frame.size = CGSizeMake(tag*10+100, tag*10+100);
  UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame];
//    UIImageView *imageView = [[UIImageView alloc]initWithFrame:frame];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    [self addSubview:imageView];
	
    return imageView;
}

- (void)renderImageView:(id)imageView url:(NSURL *)url {
//    [imageView setImageURLString:url.absoluteString placeHolderImage:@"聊天框蓝" cornerRadius:10];
    [imageView setProgressImageURLString:url.absoluteString placeHolderImage:@"加载图(横版)" cornerRadius:20 progress:^(UIImageView *imageView, UIImage *image) {
        
    }];
//    [imageView setProgressImageURLString:url.absoluteString placeHolderImageName:@"聊天框蓝" cornerRadius:10];
}

@end
