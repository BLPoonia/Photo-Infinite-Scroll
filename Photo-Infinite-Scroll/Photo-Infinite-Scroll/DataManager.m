//
//  DataManager.m
//  ScrollDemo
//
//  Created by Poonia on 09/11/15.
//  Copyright © 2015 Babu Lal. All rights reserved.
//

#import "DataManager.h"

static NSString *const flickrAPIFeedsURL = @"https://api.flickr.com/services/feeds/photos_public.gne?nojsoncallback=1&format=json";

@implementation DataManager

#pragma mark Singleton implementation

+ (DataManager*) sharedInstance
{
    static DataManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

#pragma mark - Flickr API Calls

- (void)fetchFlickrPhotosData:(void(^)(void))completion {
    self.isLoading = YES;
    
    NSURL *requestURL = [NSURL URLWithString:flickrAPIFeedsURL];
    
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithURL:requestURL completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self handleResponse:response data:data error:error completion:^{
                self.isLoading = NO;
            }];
        });
    }];
    
    [task resume];
}

- (void)handleResponse:(NSURLResponse*)response data:(NSData*)data error:(NSError*)error completion:(void(^)(void))completion {
    
    if(error) {
        if([self.delegate respondsToSelector:@selector(displayRetryAlertWithError:)]){
            [self.delegate displayRetryAlertWithError:error];
        }
        self.isLoading = NO;
        return;
    }
    
    NSError *jsonError;
    NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    jsonString = [jsonString stringByReplacingOccurrencesOfString: @"\\'" withString: @"'"];
    NSData *fixedData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSDictionary *responseDict = (NSDictionary*) [NSJSONSerialization JSONObjectWithData:fixedData options:0 error:&jsonError];
    
    if(jsonError) {
        if([self.delegate respondsToSelector:@selector(displayRetryAlertWithError:)]){
            [self.delegate displayRetryAlertWithError:error];
        }
        self.isLoading = NO;
        return;
    }
    
    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
    NSArray *photos = [responseDict valueForKeyPath:@"items.media.m"];
    NSInteger index = self.photoURLs.count;
    
    if(self.photoURLs == nil){
        self.photoURLs = [[NSMutableArray alloc] init];
    }
    if(self.imageCache == nil){
        self.imageCache = [[NSCache alloc] init];
    }
    
    for(NSString *url in photos) {
        if(![self.photoURLs containsObject:[NSURL URLWithString:url]]){
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index++ inSection:0];
            [self.photoURLs addObject:[NSURL URLWithString:url]];
            [indexPaths addObject:indexPath];
        }
    }
    
    if([self.delegate respondsToSelector:@selector(updateCollectionViewWithIndexPaths:)]){
        [self.delegate updateCollectionViewWithIndexPaths:indexPaths];
    }
    
    if(completion){
        completion();
    }
}

#pragma mark - Download Image from URL
- (void)downloadPhotoFromURL:(NSURL*)URL completion:(void(^)(NSURL *URL, UIImage *image))completion {
    static dispatch_queue_t downloadQueue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        downloadQueue = dispatch_queue_create("Photos.DownloadQueue", DISPATCH_QUEUE_CONCURRENT);
    });
    
    dispatch_async(downloadQueue, ^{
        NSData *data = [NSData dataWithContentsOfURL:URL];
        UIImage *image = [UIImage imageWithData:data];
        
        if(image) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.imageCache setObject:image forKey:URL];
                
                if(completion) {
                    completion(URL, image);
                }
            });
        }
    });
}

@end
