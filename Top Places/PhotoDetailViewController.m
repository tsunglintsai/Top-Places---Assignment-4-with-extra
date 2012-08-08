//
//  PhotoDetailViewController.m
//  Top Places
//
//  Created by Henry Tsai on 7/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PhotoDetailViewController.h"
#import "SplitViewBarButtonItemPresenter.h"

@interface PhotoDetailViewController ()<UIScrollViewDelegate,SplitViewBarButtonItemPresenter>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;
@end

@implementation PhotoDetailViewController
@synthesize scrollView = _scrollView;
@synthesize imageView = _imageView;
@synthesize photo = _photo;
@synthesize photoTitle = _photoTitle;
@synthesize splitViewBarButtonItem = _splitViewBarButtonItem;
@synthesize toolBar = _toolBar;

- (void)updateImageView{
    self.scrollView.zoomScale = 1.0; // reset zoomScale
    self.imageView.image = self.photo.largeImage;
    if(self.imageView.image!=nil){
        self.imageView.frame = CGRectMake(0, 0, self.photo.largeImage.size.width, self.photo.largeImage.size.height);
        self.scrollView.delegate = self;
        self.scrollView.contentSize = self.photo.largeImage.size;
        float xScale = self.scrollView.frame.size.width/self.imageView.image.size.width;
        float yScale = self.scrollView.frame.size.height/self.imageView.image.size.height;
        CGRect zoomToRect;
        float xOffset = 0;
        float yOffset = 0;
        if(yScale > xScale){
            xOffset = (self.imageView.bounds.size.width * yScale - self.scrollView.bounds.size.width )/2;
            zoomToRect = CGRectMake(0, 0, 0, self.imageView.image.size.height);
        }else{
            yOffset = (self.imageView.frame.size.height * xScale - self.scrollView.frame.size.height )/2;
            zoomToRect = CGRectMake(0, 0, self.imageView.image.size.width, 0);
        }
        [self.scrollView zoomToRect:zoomToRect animated:false];
        self.scrollView.contentOffset = CGPointMake(xOffset , yOffset );
    }
}

- (void)viewWillLayoutSubviews{
    [self updateImageView];
}

- (void)setPhoto:(id<TopPlacesPhotoProtocol>)photo{
    _photo = photo;
    [self updateImageView];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationItem.title = self.photoTitle;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

- (void)setSplitViewBarButtonItem:(UIBarButtonItem *)splitViewBarButtonItem
{
    if (splitViewBarButtonItem != _splitViewBarButtonItem) {
        NSMutableArray *toolbarItems = [self.toolBar.items mutableCopy];
        if (_splitViewBarButtonItem) [toolbarItems removeObject:_splitViewBarButtonItem];
        if (splitViewBarButtonItem) [toolbarItems insertObject:splitViewBarButtonItem atIndex:0];
        self.toolBar.items = toolbarItems;
        _splitViewBarButtonItem = splitViewBarButtonItem;
    }
}

- (void)viewDidUnload {
    [self setImageView:nil];
    [self setScrollView:nil];
    [super viewDidUnload];
}
@end
