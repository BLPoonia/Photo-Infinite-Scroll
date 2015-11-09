//
//  FullScreenViewController.m
//  ScrollDemo
//
//  Created by Poonia on 08/11/15.
//  Copyright © 2015 Babu Lal. All rights reserved.
//

#import "FullScreenViewController.h"
#import "FullScreenCollectionViewCell.h"
#import "DataManager.h"

@interface FullScreenViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, DataManagerDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation FullScreenViewController

static NSString *const reuseIdentifier = @"FullScreenCollectionViewCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setTitle:@"Zoom & Pinch"];
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"FullScreenCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:reuseIdentifier];
    [[DataManager sharedInstance] setDelegate:self];

}

- (void) viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    self.collectionView.contentOffset=CGPointMake(self.view.bounds.size.width*self.currentIndex, 0);
}

#pragma mark UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [[[DataManager sharedInstance] photoURLs] count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    FullScreenCollectionViewCell *cell = (FullScreenCollectionViewCell*)[collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    NSURL *photoURL = [[[DataManager sharedInstance] photoURLs] objectAtIndex:indexPath.item];
    UIImage *image = [[[DataManager sharedInstance] imageCache] objectForKey:photoURL];
    
    cell.imageView.image = image;
    
    if(!image) {
        [[DataManager sharedInstance] downloadPhotoFromURL:photoURL completion:^(NSURL *URL, UIImage *image) {
            NSIndexPath *indexPath_ = [collectionView indexPathForCell:cell];
            if([indexPath isEqual:indexPath_]) {
                cell.imageView.image = image;
            }
        }];
    }
    
    return cell;
}

#pragma mark - DataManager Delegate
- (void)updateCollectionViewWithIndexPaths:(NSArray *)indexPathArray {
    [self.collectionView performBatchUpdates:^{
        [self.collectionView insertItemsAtIndexPaths:indexPathArray];
    } completion:nil];
}

- (void)displayRetryAlertWithError:(NSError *)error {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error fetching data" message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Retry" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[DataManager sharedInstance] fetchFlickrPhotosData:nil];
    }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat collectionWidth = CGRectGetWidth(collectionView.bounds);
    CGFloat collectionHeight = CGRectGetHeight(collectionView.bounds);
    
    return CGSizeMake(collectionWidth, collectionHeight);
}

#pragma mark - Scroll and fetch more

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    CGPoint offset = scrollView.contentOffset;
    CGSize contentSize = scrollView.contentSize;
    CGRect rect = scrollView.bounds;
    if(rect.size.width+offset.x >= contentSize.width && ![[DataManager sharedInstance] isLoading] && contentSize.width>0){
        [[DataManager sharedInstance] fetchFlickrPhotosData:nil];
    }
}

@end
