//
//  FullScreenCollectionViewCell.m
//  ScrollDemo
//
//  Created by Poonia on 08/11/15.
//  Copyright © 2015 Babu Lal. All rights reserved.
//

#import "FullScreenCollectionViewCell.h"

#define MinZoomScale 1.0f
#define MaxZoomScale 2.0f

@implementation FullScreenCollectionViewCell

- (void)awakeFromNib {
    
    // Pinch Zoom
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    self.pinchRecognizer = pinch;
    self.pinchRecognizer.delegate = self;
    
    // DoubleTap Zoom
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    self.doubleTapRecognizer = doubleTap;
    self.doubleTapRecognizer.delegate = self;
    self.doubleTapRecognizer.numberOfTapsRequired = 2;
    self.doubleTapRecognizer.numberOfTouchesRequired = 1;
    
    [self addGestureRecognizer:self.doubleTapRecognizer];
    [self.imageView addGestureRecognizer:self.pinchRecognizer];
    [self.imageView setUserInteractionEnabled:YES];
    
    self.imageScrollView.maximumZoomScale = MaxZoomScale;
    self.imageScrollView.minimumZoomScale = MinZoomScale;
    self.imageScrollView.delegate = self;
    self.imageScrollView.contentSize = self.imageView.frame.size;
}

- (void)handlePinch:(UIPinchGestureRecognizer*)recognizer {
    recognizer.view.transform = CGAffineTransformScale(recognizer.view.transform, recognizer.scale, recognizer.scale);
    recognizer.scale = 1;
}

- (void)handleDoubleTap:(UITapGestureRecognizer*)recognizer {
    if (self.imageScrollView.maximumZoomScale!=self.imageScrollView.minimumZoomScale){
        CGPoint pointInView = [recognizer locationInView:self.imageView];
        CGFloat newZoomScale;
        
        if(self.imageScrollView.zoomScale < MaxZoomScale) {
            // Zoom IN
            newZoomScale = MaxZoomScale;
        }else {
            // Zoom OUT
            newZoomScale = MinZoomScale;
        }
        
        CGRect rectToZoomTo = [self getZoomedRectForScale:newZoomScale withCenter:pointInView];
        [self.imageScrollView zoomToRect:rectToZoomTo animated:YES];
    }
}

- (CGRect)getZoomedRectForScale:(CGFloat)scale withCenter:(CGPoint)center {
    
    CGRect zoomRect;
    zoomRect.size.height = [self.imageScrollView frame].size.height / scale;
    zoomRect.size.width  = [self.imageScrollView frame].size.width  / scale;
    zoomRect.origin.x    = center.x - (zoomRect.size.width  / 2.0);
    zoomRect.origin.y    = center.y - (zoomRect.size.height / 2.0);
    
    return zoomRect;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    
}

#pragma mark - prepare for reuse

-(void)prepareForReuse {
    self.imageScrollView.zoomScale = 1.0;
}

@end
