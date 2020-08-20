//
//  MoviesViewController.m
//  Flix
//
//  Created by Anna Goncharenko on 8/20/20.
//  Copyright © 2020 annagoncharenko. All rights reserved.
//

#import "MoviesViewController.h"

@interface MoviesViewController ()

// "property" makes private instance variable and automatically makes a getter/setter
// "strong" holds on to reference, increments retain count of movies
@property (nonatomic, strong) NSArray *movies;

@end

@implementation MoviesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
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
               
               // array of movies from "results" key
               self.movies = dataDictionary[@"results"];
               for (NSDictionary *movie in self.movies) { // check to see movies
                   NSLog(@"%@", movie[@"title"]);
               }
               // TODO: Get the array of movies
               // TODO: Store the movies in a property to use elsewhere
               // TODO: Reload your table view data
           }
       }];
    [task resume];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
