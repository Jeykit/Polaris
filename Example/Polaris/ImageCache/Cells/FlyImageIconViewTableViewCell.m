//
//  FlyImageIconViewTableViewCell.m
//  FlyImageView
//
//  Created by Ye Tong on 5/3/16.
//  Copyright © 2016 Augmn. All rights reserved.
//

#import "FlyImageIconViewTableViewCell.h"
#import "UIImageView+CacheM.h"

@implementation FlyImageIconViewTableViewCell

- (id)imageViewWithFrame:(CGRect)frame {
//    int tag = rand()%10+1;
//    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width - tag * 20,frame.size.height - tag * 20)];
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:frame];
	imageView.contentMode = UIViewContentModeScaleAspectFill;
//    imageView.layer.cornerRadius = 10;
	[self addSubview:imageView];
	
	return imageView;
}

- (void)renderImageView:(id)imageView url:(NSURL *)url {
	((UIImageView *)imageView).imageURLString = url.absoluteString;
}

@end
