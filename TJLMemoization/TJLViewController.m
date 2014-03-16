//
//  TJLViewController.m
//  TJLMemoization
//
//  Created by Terry Lewis II on 3/6/14.
//  Copyright (c) 2014 Blue Plover Productions LLC. All rights reserved.
//

#define ADNStreamURL @"https://alpha-api.app.net/stream/0/posts/stream/global"

static NSString *const cellIdentifier = @"CELL";

static NSString *const root_user_key = @"user";

static NSString *const root_name_key = @"name";

static NSString *const root_text_key = @"text";

#import "TJLViewController.h"
#import "NSObject+Memoization.h"

@interface TJLViewController () <UITableViewDataSource, UITableViewDelegate>
@property(weak, nonatomic) IBOutlet UITableView *tableView;
@property(strong, nonatomic) NSArray *postsArray;

@end

@implementation TJLViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    __strong UITableView *strongTableView = self.tableView;
    strongTableView.dataSource = self;
    strongTableView.delegate = self;

    [self getTimeLineAndReloadTableView];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.postsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    NSDictionary *postDict = self.postsArray[(NSUInteger)indexPath.row];

    cell.textLabel.text = postDict[root_user_key][root_name_key];
    cell.detailTextLabel.numberOfLines = 10;
    cell.detailTextLabel.text = postDict[root_text_key];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *post = self.postsArray[(NSUInteger)indexPath.row];
    NSString *text = post[root_text_key];
    return [[self memoizeAndInvokeSelector:@selector(calculateHeightForText:atIndexPath:) withArguments:text, indexPath, nil] floatValue];
}


- (CGFloat)calculateHeightForText:(NSString *)text atIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *post = self.postsArray[(NSUInteger)indexPath.row];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineBreakMode = NSLineBreakByWordWrapping;
    UIFont *font = [UIFont systemFontOfSize:12];
    CGSize maximumLabelSize = CGSizeMake(220, 1000);
    NSDictionary *attributes = @{NSFontAttributeName : font};
    CGRect boundingRect = [post[root_text_key] boundingRectWithSize:maximumLabelSize
                                                            options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                         attributes:attributes
                                                            context:NSStringDrawingContext.new];

    return ceilf(CGRectGetHeight(boundingRect) + 75);
}

- (void)getTimeLineAndReloadTableView {
    NSURL *URL = [NSURL URLWithString:ADNStreamURL];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];

    __weak TJLViewController *weakSelf = self;
    [[[NSURLSession sharedSession] dataTaskWithURL:URL completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        __strong TJLViewController *strongSelf = weakSelf;
        NSMutableArray *posts = [NSMutableArray new];
        if(data && !error) {
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];


            NSArray *dataArray = json[@"data"];
            for(NSDictionary *dict in dataArray) {
                [posts addObject:dict];
            }
            strongSelf.postsArray = [posts arrayByAddingObjectsFromArray:strongSelf.postsArray];
            dispatch_async(dispatch_get_main_queue(), ^{
                [strongSelf.tableView reloadData];
            });
        }
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }] resume];
}

@end
