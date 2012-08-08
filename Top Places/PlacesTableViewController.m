//
//  PlacesTableViewController.m
//  Top Places
//
//  Created by Henry Tsai on 7/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PlacesTableViewController.h"
#import "FlickrFetcher.h"
#import "PhotoListViewController.h"
#import "SplitViewBarButtonItemPresenter.h"
#import "PhotoDetailViewController.h"
#import "FlickerPhoto.h"

@interface PlacesTableViewController ()<UISplitViewControllerDelegate,PhotoListViewControllerDelegate>
@property (strong,nonatomic) NSMutableSet *photoList;
@property (strong,nonatomic) NSMutableDictionary *topPlacesGroupByCountry;
@property (strong,nonatomic) NSMutableArray *countryList;
@end

@implementation PlacesTableViewController

@synthesize photoList = _photoList;
@synthesize topPlacesGroupByCountry = _topPlacesGroupByCountry;
@synthesize countryList = _countryList;

- (NSMutableArray*)countryList{
    if(_countryList == nil){
        _countryList = [[NSMutableArray alloc]init];
    }
    return _countryList;
}

- (NSMutableSet *)photoList{
    if(_photoList==nil){
        _photoList = [[NSMutableSet alloc]init];
    }
    return _photoList;
}


- (UITableView*)tableView{
    UITableView  *result;
    if([self.view isKindOfClass:[UITableView class]]){
        result = (UITableView*)self.view;
    }
    return result;
}

- (NSMutableDictionary*)topPlacesGroupByCountry{
    if(_topPlacesGroupByCountry==nil){
        _topPlacesGroupByCountry = [[NSMutableDictionary alloc]init];
    }
    return _topPlacesGroupByCountry;
}

- (void)reloadData{
    NSMutableSet *countrySet =  [[NSMutableSet alloc]init ];
    [self.topPlacesGroupByCountry removeAllObjects];
    for (id object in [FlickrFetcher topPlaces]) {
        NSArray *placeTokens = [[FlickerPhoto getPlaceStringFromFlickerDataEntry:object] componentsSeparatedByString:@","];
        NSString *countryString = (NSString*)[placeTokens lastObject];
        countryString = [countryString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSMutableArray *placesInCountry = [[self.topPlacesGroupByCountry objectForKey:countryString]mutableCopy];
        if(placesInCountry==nil){
            placesInCountry = [[NSMutableArray alloc]init];
        }
        [placesInCountry addObject:object];
        [self.topPlacesGroupByCountry setObject:placesInCountry forKey:countryString];
        [countrySet addObject:countryString];
    }
    [self.countryList removeAllObjects];
    for(id object in countrySet){
        [self.countryList  addObject:object];
    }
	// sort country in array
    
    NSArray *sortedArray;
    sortedArray = [self.countryList sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        return [a compare:b];
    }];
    self.countryList = [sortedArray mutableCopy];
    // sort place in each country
    
    NSMutableDictionary *tmpDictionaray = [[NSMutableDictionary alloc]init];
    for(NSString *key in [self.topPlacesGroupByCountry copy]){
        NSMutableArray *placesInCountry = [self.topPlacesGroupByCountry objectForKey:key];
        NSArray *sortedArray;
        sortedArray = [placesInCountry sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
            NSString *first =  [[FlickerPhoto class] getPlaceStringFromFlickerDataEntry:(NSDictionary*)a]; 
            NSString *second = [[FlickerPhoto class] getPlaceStringFromFlickerDataEntry:(NSDictionary*)b]; 
            return [first compare:second];
        }];
        [tmpDictionaray setObject:sortedArray forKey:key];
    }
    self.topPlacesGroupByCountry = tmpDictionaray;
    [self.tableView reloadData];
    //NSLog(@"%@",[self.countryList description]);
    //NSLog(@"%@",[self.topPlacesGroupByCountry description]);
}

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self reloadData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *countryString = [self.countryList objectAtIndex:section];
    return [[self.topPlacesGroupByCountry objectForKey:countryString]count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self.countryList objectAtIndex:section];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.countryList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"PlaceCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    } 
    NSString *countryString = [self.countryList objectAtIndex:indexPath.section];
    NSArray *placesInCountry = [self.topPlacesGroupByCountry objectForKey:countryString];
    NSString *locationString = [[FlickerPhoto class]getPlaceStringFromFlickerDataEntry:[placesInCountry objectAtIndex:indexPath.row]];
    NSString *cityString = [[FlickerPhoto class]getCityStringFromFlickPlaceString:locationString];
    NSString *restStringOtherThanCity = [[FlickerPhoto class]getRestOfPlaceStringOtherFromFlickPlaceString:locationString];
    cell.textLabel.text = cityString;
    cell.detailTextLabel.text = restStringOtherThanCity;
    return cell;
}



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"PushToPhotoListSegue"]) {
        PhotoListViewController *photoListViewController = segue.destinationViewController;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender]; 
        NSString *countryString = [self.countryList objectAtIndex:indexPath.section];
        NSArray *placesInCountry = [self.topPlacesGroupByCountry objectForKey:countryString];        
        
        NSDictionary *selectedLocation = [placesInCountry objectAtIndex:indexPath.row];
        NSArray* photoForPlace = [FlickerPhoto getPhotoListFromFlickerPhotoListResponseData:selectedLocation withLimit:50];
        photoListViewController.photoList = photoForPlace;  
        [self.photoList addObjectsFromArray:photoForPlace];
        
        NSString *locationString = [[FlickerPhoto class]getPlaceStringFromFlickerDataEntry:[placesInCountry objectAtIndex:indexPath.row]];
        NSString *cityString = [[FlickerPhoto class]getCityStringFromFlickPlaceString:locationString];
        //NSLog(@"cityString:%@",cityString);
        photoListViewController.listTitle = cityString;
        photoListViewController.delegate = self;
    } 
}

- (void)photoSelected:(id<TopPlacesPhotoProtocol>)photoSelected{
    // save selected photo to nsuserdefault   
    for (id object in self.photoList) { 
        if([object isEqual:photoSelected] && [object isKindOfClass:[FlickerPhoto class]] ){
            FlickerPhoto *selectedPhoto = object;
            [[FlickerPhoto class] addFavoritPhoto:selectedPhoto.photoData];
            break;
        }
    }    
    
}

#pragma mark - ╭━━━━━━━━━━━━━━━━━━━━━━━━━━━╮
#pragma mark - ┃ SplitView              {  ┃
#pragma mark - ╰━━━━━━━━━━━━━━━━━━━━━━━━━━━╯
- (void)awakeFromNib  // always try to be the split view's delegate
{
    [super awakeFromNib];
    self.splitViewController.delegate = self;
    self.splitViewController.presentsWithGesture = NO;
}

- (id <SplitViewBarButtonItemPresenter>)splitViewBarButtonItemPresenter
{
    //NSLog(@"splitViewBarButtonItemPresenter");
    id detailVC = [self.splitViewController.viewControllers lastObject];
    if (![detailVC conformsToProtocol:@protocol(SplitViewBarButtonItemPresenter)]) {
        detailVC = nil;
    }
    return detailVC;
}

- (BOOL)splitViewController:(UISplitViewController *)svc
   shouldHideViewController:(UIViewController *)vc
              inOrientation:(UIInterfaceOrientation)orientation
{
    //NSLog(@"shouldHideViewController");

    return [self splitViewBarButtonItemPresenter] ? UIInterfaceOrientationIsPortrait(orientation) : NO;
}

- (void)splitViewController:(UISplitViewController *)svc
     willHideViewController:(UIViewController *)aViewController
          withBarButtonItem:(UIBarButtonItem *)barButtonItem
       forPopoverController:(UIPopoverController *)pc
{
    //NSLog(@"willHideViewController");
    barButtonItem.title = @"Menu";
    [self splitViewBarButtonItemPresenter].splitViewBarButtonItem = barButtonItem;
}

- (void)splitViewController:(UISplitViewController *)svc
     willShowViewController:(UIViewController *)aViewController
  invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    //NSLog(@"willShowViewController");
    [self splitViewBarButtonItemPresenter].splitViewBarButtonItem = nil;
}


#pragma mark - ╭━━━━━━━━━━━━━━━━━━━━━━━━━━━╮
#pragma mark - ┃ SplitView              }  ┃
#pragma mark - ╰━━━━━━━━━━━━━━━━━━━━━━━━━━━╯

@end
