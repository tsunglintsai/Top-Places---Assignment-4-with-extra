//
//  PhotoListViewController.m
//  Top Places
//
//  Created by Henry Tsai on 7/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PhotoListViewController.h"
#import "FlickrFetcher.h"
#import "PhotoDetailViewController.h"
#import "SplitViewBarButtonItemPresenter.h"

@interface PhotoListViewController ()<UISplitViewControllerDelegate>

@end

@implementation PhotoListViewController
@synthesize photoList = _photoList;
@synthesize listTitle = _listTitle;
@synthesize delegate = _delegate;


-(NSArray*) photoList{
    return [_photoList mutableCopy];
}

- (void) setPhotoList:(NSArray *)photoList{
    _photoList = [photoList mutableCopy];
    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated{
    //NSLog(@"viewWillAppear:%@",self.listTitle);
    self.navigationItem.title = self.listTitle;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.photoList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"PhotoCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }    
    id<TopPlacesPhotoProtocol> photo = [self.photoList objectAtIndex:indexPath.row];
    cell.imageView.image = photo.smallImage;
    cell.textLabel.text = photo.photoTitle;
    cell.detailTextLabel.text = photo.photoSubTitle;
    if(cell.detailTextLabel.text == nil){
        cell.detailTextLabel.text = @"  ";
    }
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"PushToPhotoDetailSegue"]) {
        PhotoDetailViewController *photoDetailViewController = segue.destinationViewController;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        id<TopPlacesPhotoProtocol> selectedPhoto = [self.photoList objectAtIndex:indexPath.row];
        photoDetailViewController.photo = selectedPhoto;
        photoDetailViewController.photoTitle = selectedPhoto.photoTitle;
        [self.delegate photoSelected:selectedPhoto];
    } 
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id viewController = [self.splitViewController.viewControllers lastObject];
    //NSLog(@"viewController:%@",viewController);
    if(viewController!=nil){
        //NSLog(@"viewController2:%@",viewController);
        PhotoDetailViewController *photoDetailViewController  = viewController;
        id<TopPlacesPhotoProtocol> selectedPhoto = [self.photoList objectAtIndex:indexPath.row];
        photoDetailViewController.photo = selectedPhoto;
        photoDetailViewController.photoTitle = selectedPhoto.photoTitle;
        [self.delegate photoSelected:selectedPhoto];
    }
}

@end
