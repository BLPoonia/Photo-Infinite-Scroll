//
//  FullScreenCollectionViewCell.h
//  ScrollDemo
//
//  Created by Poonia on 08/11/15.
//  Copyright © 2015 Babu Lal. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FullScreenCollectionViewCell : UICollectionViewCell<UIGestureRecognizerDelegate, UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *imageScrollView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) UITapGestureRecognizer *doubleTapRecognizer;
@property (weak, nonatomic) UIPinchGestureRecognizer *pinchRecognizer;

@end
