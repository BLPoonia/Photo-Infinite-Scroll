//
//  DataManager.h
//  ScrollDemo
//
//  Created by Poonia on 09/11/15.
//  Copyright © 2015 Babu Lal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol DataManagerDelegate <NSObject>

@optional

- (void) updateCollectionViewWithIndexPaths:(NSArray *) indexPathArray;
- (void) displayRetryAlertWithError:(NSError *) error;

@end

@interface DataManager : NSObject

@property NSMutableArray *photoURLs;
@property NSCache *imageCache;
@property BOOL isLoading;
@property (nonatomic, weak) id<DataManagerDelegate> delegate;

+ (DataManager*) sharedInstance;
- (void)fetchFlickrPhotosData:(void(^)(void))completion;
- (void)downloadPhotoFromURL:(NSURL*)URL completion:(void(^)(NSURL *URL, UIImage *image))completion;

@end
