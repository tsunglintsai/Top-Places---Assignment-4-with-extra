#import <Foundation/Foundation.h>

@protocol TopPlacesPhotoProtocol <NSObject>
@property (nonatomic,strong) NSNumber *id;
@property (nonatomic,strong) NSURL *photoSmallURL;
@property (nonatomic,strong) NSURL *photoLargeURL;
@property (nonatomic,strong) NSURL *photoOriginalURL;
@property (nonatomic,strong) NSString *photoTitle;
@property (nonatomic,strong) NSString *photoSubTitle;
@property (nonatomic,strong) UIImage *smallImage;
@property (nonatomic,strong) UIImage *largeImage;
@property (nonatomic,strong) UIImage *originalImage;
@end
