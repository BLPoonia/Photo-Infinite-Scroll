//
//  ThumbnailViewController.m
//  ScrollDemo
//
//  Created by Poonia on 08/11/15.
//  Copyright © 2015 Babu Lal. All rights reserved.
//

#import "ThumbnailViewController.h"
#import "PhotoCollectionViewCell.h"
#import "FullScreenViewController.h"
#import "DataManager.h"

@interface ThumbnailViewController ()<DataManagerDelegate>

@end

@implementation ThumbnailViewController

static NSString *const reuseIdentifier = @"PhotoCollectionViewCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setTitle:@"Flickr Infinite Scroll App"];
    
    self.collectionView.contentInset = UIEdgeInsetsMake(0, 0, 70, 0);
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"PhotoCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:reuseIdentifier];
    
    // Fetch Initial Data
    [[DataManager sharedInstance] setDelegate:self];
    [[DataManager sharedInstance] fetchFlickrPhotosData:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[DataManager sharedInstance] setDelegate:self];
    [self.collectionView reloadData];
}

#pragma mark UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [[[DataManager sharedInstance] photoURLs] count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    PhotoCollectionViewCell *cell = (PhotoCollectionViewCell*)[collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
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

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    FullScreenViewController *fullScreenVC = [[FullScreenViewController alloc] initWithNibName:@"FullScreenViewController" bundle:nil];
    fullScreenVC.currentIndex = indexPath.item;
    [self.navigationController pushViewController:fullScreenVC animated:YES];
}

#pragma mark - DataManager Delegate
- (void)updateCollectionViewWithIndexPaths:(NSArray *)indexPathArray {
    [self.collectionView performBatchUpdates:^{
        [self.collectionView insertItemsAtIndexPaths:indexPathArray];
    } completion:nil];
}

- (void)displayRetryAlertWithError:(NSError *)error {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Error fetching data", @"") message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Dismiss", @"") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Retry", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[DataManager sharedInstance] fetchFlickrPhotosData:nil];
    }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat collectionWidth = CGRectGetWidth(collectionView.bounds);
    CGFloat spacing = [self collectionView:collectionView layout:collectionViewLayout minimumInteritemSpacingForSectionAtIndex:indexPath.section];
    CGFloat itemWidth = collectionWidth / 3 - spacing;
    
    return CGSizeMake(itemWidth, itemWidth);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 1;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 1;
}

#pragma mark - Scroll and fetch more

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGPoint offset = scrollView.contentOffset;
    CGSize contentSize = scrollView.contentSize;
    CGRect rect = scrollView.bounds;
    if(rect.size.height+offset.y > contentSize.height && ![[DataManager sharedInstance] isLoading]){
        [[DataManager sharedInstance] fetchFlickrPhotosData:nil];
    }
}

@end
