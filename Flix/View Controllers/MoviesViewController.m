//
//  MoviesViewController.m
//  Flix
//
//  Created by Anna Goncharenko on 8/20/20.
//  Copyright © 2020 annagoncharenko. All rights reserved.
//

#import "MoviesViewController.h"
#import "MovieCell.h"
#import "UIImageView+AFNetworking.h"
#import "DetailsViewController.h"

@interface MoviesViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

// "property" makes private instance variable and automatically makes a getter/setter
// "strong" holds on to reference, increments retain count of movies
@property (nonatomic, strong) NSArray *movies;

@property (nonatomic, strong) NSArray *filteredMovies;

@property (nonatomic, strong) UIRefreshControl *refreshControl;

@end

@implementation MoviesViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // setting to self calls this object to do the required methods
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    // set search bar
    self.searchBar.delegate = self;
    
    // get movies/ load up table view
    [self fetchMovies];
    
    // add refresh control to tableview
    // addtarget - call fetch events when refreshed
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(fetchMovies) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex:0];
    
}

- (void)fetchMovies {
    // set up: url, request, and session
    NSURL *url = [NSURL URLWithString:@"https://api.themoviedb.org/3/movie/now_playing?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    
    // ^(...) block syntax
    // lines inside block are called once network request is finished (done in background)
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
           if (error != nil) { // check if error, print it out
               NSLog(@"%@", [error localizedDescription]);
           }
           else { // API gave a response
               NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
               
               NSLog(@"%@", dataDictionary);
               
               // TODO: Get the array of movies
               // TODO: Store the movies in a property to use elsewhere
               // TODO: Reload your table view data
               
               // array of movies from "results" key
               self.movies = dataDictionary[@"results"];
               for (NSDictionary *movie in self.movies) { // check to see movies
                   NSLog(@"%@", movie[@"title"]);
               }
               self.filteredMovies = self.movies;
               
               // reload table view
               [self.tableView reloadData];
           }
        // stop refresh control
        [self.refreshControl endRefreshing];
       }];
    [task resume];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.filteredMovies.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // use movie cell template
    // "dequeue reusable" give used cell to reconfigure, if none exist then make new (for efficient memory allocation)
    MovieCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MovieCell"];
    
    // access movie of interest - movie associated with row
    NSDictionary *movie = self.filteredMovies[indexPath.row];
    cell.titleLabel.text = movie[@"title"];
    cell.synopsisLabel.text = movie[@"overview"];
    
    // format URL for image of movie
    NSString *baseURLString = @"https://image.tmdb.org/t/p/w500";
    NSString *posterURLString = movie[@"poster_path"];
    NSString *fullPosterURLString = [baseURLString stringByAppendingString:posterURLString];
    
    // create URL from string
    NSURL *posterURL = [NSURL URLWithString:fullPosterURLString];
    
    // set image with URL (using imported category function from pod)
    cell.posterView.image = nil; // clear out old image before so it doesn't flicker
    [cell.posterView setImageWithURL:posterURL];
    
    return cell;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length != 0) {
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title contains[cd] %@", searchText];
        
        self.filteredMovies = [self.movies filteredArrayUsingPredicate:predicate];
        
        NSLog(@"%@", self.filteredMovies);
        
    }
    else {
        self.filteredMovies = self.movies;
    }
    
    [self.tableView reloadData];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    NSLog(@"Tapping on a movie");
    // id = table view cell that was tapped on
    UITableViewCell *tappedCell = sender;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:tappedCell];
    NSDictionary *movie = self.filteredMovies[indexPath.row];
    
    DetailsViewController *detailsViewController = [segue destinationViewController];
    // set public property to be the selected movie
    detailsViewController.movie = movie;
};


@end
