//
//  FlickerPhoto.m
//  Top Places
//
//  Created by Henry Tsai on 7/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FlickerPhoto.h"
#import "FlickrFetcher.h"

#define RECENT_PHOTO_KEY @"RECENT_PHOTO"
#define UKNOWN_PHOTO_TITLE_STRING @"Unknown"

@interface FlickerPhoto ()
@end

@implementation FlickerPhoto
@synthesize photoSmallURL = _photoSmallURL;
@synthesize photoLargeURL = _photoLargeURL;
@synthesize photoOriginalURL = _photoOriginalURL;
@synthesize photoTitle = _photoTitle;
@synthesize photoSubTitle = _photoSubTitle;
@synthesize smallImage = _smallImage;
@synthesize largeImage = _largeImage;
@synthesize originalImage = _originalImage;
@synthesize photoData = _photoData;
@synthesize id = _id;

- (BOOL)isEqual:(id)anObject{
    BOOL result = false;
    if([anObject conformsToProtocol:@protocol(TopPlacesPhotoProtocol)]){
        FlickerPhoto *b = anObject;
        result = [self.id isEqual:b.id];
    }
    return result;
}

- (NSUInteger)hash{
    return self.id.hash;
}

-(UIImage*) smallImage{
    if(_smallImage==nil){
        if(self.photoSmallURL!=nil){
            _smallImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:self.photoSmallURL]];
        }
    }
    return _smallImage;
}

-(UIImage*) largeImage{
    if(_largeImage==nil){
        if(self.photoLargeURL!=nil){
            _largeImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:self.photoLargeURL]];
        }
    }
    return _largeImage;
}

-(UIImage*) originalImage{
    if(_originalImage==nil){
        if(self.photoOriginalURL!=nil){
            _originalImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:self.photoOriginalURL]];
        }
    }
    return _originalImage;
}

+ (NSArray*) getPhotoListFromFlickerPhotoListResponseData:(NSDictionary*)photoDataList withLimit:(int) limit{
    NSArray *photoList = [FlickrFetcher photosInPlace:photoDataList maxResults:limit];
    NSMutableArray *photoListForPhotoListView = [[NSMutableArray alloc]init];
    for (id photo in photoList) {
        FlickerPhoto *flickerPhoto = [[FlickerPhoto class]getPhotoFromFlickerPhotoResposneData:photo];
        [photoListForPhotoListView addObject:flickerPhoto];                
    }        
    return photoListForPhotoListView;
}


+ (NSArray*) getFavoritePhotoList{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];    
    NSMutableArray *result = [[NSMutableArray alloc]init];
    NSArray *photoDataList = [prefs objectForKey:@"RECENT_PHOTO"];
    for (id photo in photoDataList) {
        FlickerPhoto *flickerPhoto = [[self class]getPhotoFromFlickerPhotoResposneData:photo];
        flickerPhoto.photoData = photo;
        [result addObject:flickerPhoto];                
    }    
    return result;
}

+ (void) addFavoritPhoto:(NSDictionary*)photo{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];    
    NSMutableArray *recentPhotoList = [[prefs objectForKey:RECENT_PHOTO_KEY]mutableCopy];
    if(recentPhotoList==nil){
        recentPhotoList = [[NSMutableArray alloc]init];
    }
    if([recentPhotoList containsObject:photo]){
        for (id object in recentPhotoList) {
            if([object isEqual:photo]){
                [recentPhotoList removeObject:object];
                break;
            }
        }
    }
    [recentPhotoList insertObject:photo atIndex:0];    
    [prefs setObject:recentPhotoList forKey:RECENT_PHOTO_KEY];
    [prefs synchronize];
}

+ (NSString*) getCityStringFromFlickPlaceString:(NSString*)flickerPlaceString{
    NSString *result;
    if([flickerPlaceString isKindOfClass:[NSString class]]){
        NSRange fristCommonRange = [flickerPlaceString rangeOfString:@","];
        if(!fristCommonRange.location!=NSNotFound){ // if found common 
            result = [flickerPlaceString substringToIndex:fristCommonRange.location];
        }else{
            result = flickerPlaceString;
        }
    }    
    return result;
}

+ (NSString*) getRestOfPlaceStringOtherFromFlickPlaceString:(NSString*)flickerPlaceString{
    NSString *result;
    if([flickerPlaceString isKindOfClass:[NSString class]]){
        NSRange fristCommonRange = [flickerPlaceString rangeOfString:@","];
        if(!fristCommonRange.location!=NSNotFound){ // if found common 
            result = [[flickerPlaceString substringFromIndex:fristCommonRange.location+1]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        }else{
            result = flickerPlaceString;
        }
    }    
    return result;
}

+ (NSString*) getPlaceStringFromFlickerDataEntry:(NSDictionary*)dataEntry{
    NSString *result;
    if([dataEntry isKindOfClass:[NSDictionary class]]){
        result = [dataEntry objectForKey:FLICKR_PLACE_NAME];
    }
    return result;
    
}

+ (FlickerPhoto*)getPhotoFromFlickerPhotoResposneData:(NSDictionary*)photoData{
    FlickerPhoto *photoEntry = [[FlickerPhoto alloc]init];
    photoEntry.photoSmallURL = [FlickrFetcher urlForPhoto:photoData format:FlickrPhotoFormatSquare];
    photoEntry.photoLargeURL = [FlickrFetcher urlForPhoto:photoData format:FlickrPhotoFormatLarge];
    photoEntry.photoOriginalURL = [FlickrFetcher urlForPhoto:photoData format:FlickrPhotoFormatOriginal];
    photoEntry.photoData = photoData;
    photoEntry.id = (NSNumber*)[photoData objectForKey:FLICKR_PHOTO_ID];
    NSString *titleInResponseData = [photoData valueForKey:FLICKR_PHOTO_TITLE];
    NSString *descriptionInResponseData = [photoData valueForKeyPath:FLICKR_PHOTO_DESCRIPTION];
    if(![titleInResponseData isEqualToString:@""]){
        photoEntry.photoTitle = titleInResponseData;
    }
    if(photoEntry.photoTitle==nil){
        if(![descriptionInResponseData isEqualToString:@""]){
            photoEntry.photoTitle = descriptionInResponseData;
        }else{
            photoEntry.photoTitle = UKNOWN_PHOTO_TITLE_STRING;
        }
    }else{
        if(![descriptionInResponseData isEqualToString:@""]){
            photoEntry.photoSubTitle = descriptionInResponseData;
        }        
    }
    //NSLog(@"%@",photoData);
    return photoEntry;
}

@end