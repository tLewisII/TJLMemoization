//
//  TJLViewController.m
//  TJLMemoization
//
//  Created by Terry Lewis II on 3/6/14.
//  Copyright (c) 2014 Blue Plover Productions LLC. All rights reserved.
//


static NSString *const cellIdentifier = @"CELL";

#import "TJLViewController.h"
#import "NSObject+Memoization.h"

@interface TJLViewController () <UITableViewDataSource, UITableViewDelegate>
@property(weak, nonatomic) IBOutlet UITableView *tableView;
@property(strong, nonatomic) NSString *paragraphs;
@property(nonatomic) BOOL withMemoization;

@end

@implementation TJLViewController
- (IBAction)reloadNormal:(UIBarButtonItem *)sender {
    self.withMemoization = NO;
    NSDate *date = [NSDate date];
    [self.tableView reloadData];
    NSString *time = [@(ABS([date timeIntervalSinceNow])) stringValue];

    [[[UIAlertView alloc] initWithTitle:@"Normal"
                                message:[NSString stringWithFormat:@"Reloading took %@ seconds without memoization", time]
                               delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];

}

- (IBAction)reloadWithMemoization:(UIBarButtonItem *)sender {
    self.withMemoization = YES;
    NSDate *date = [NSDate date];
    [self.tableView reloadData];
    NSString *time = [@(ABS([date timeIntervalSinceNow])) stringValue];

    [[[UIAlertView alloc] initWithTitle:@"Normal"
                                message:[NSString stringWithFormat:@"Reloading took %@ seconds with memoization", time]
                               delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    __strong UITableView *strongTableView = self.tableView;
    strongTableView.dataSource = self;
    strongTableView.delegate = self;
    NSError *error;
    self.withMemoization = YES;
    self.paragraphs = [[NSString alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"document" ofType:@"txt"]
                                                      encoding:NSUTF8StringEncoding error:&error];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self memoizeAndInvokeSelector:@selector(paragraphsFromString:) withArguments:self.paragraphs, nil] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];

    cell.textLabel.numberOfLines = 100;
    cell.textLabel.text = [[self memoizeAndInvokeSelector:@selector(paragraphsFromString:) withArguments:self.paragraphs, nil] objectAtIndex:(NSUInteger)indexPath.row];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *text = [[self memoizeAndInvokeSelector:@selector(paragraphsFromString:) withArguments:self.paragraphs, nil] objectAtIndex:(NSUInteger)indexPath.row];
    if(self.withMemoization) return [[self memoizeAndInvokeSelector:@selector(calculateHeightForText:atIndexPath:) withArguments:text, indexPath, nil] floatValue];
    else return [self calculateHeightForText:text atIndexPath:indexPath];
}


- (CGFloat)calculateHeightForText:(NSString *)text atIndexPath:(NSIndexPath *)indexPath {
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineBreakMode = NSLineBreakByWordWrapping;
    UIFont *font = [UIFont systemFontOfSize:12];
    CGSize maximumLabelSize = CGSizeMake(220, 1000);
    NSDictionary *attributes = @{NSFontAttributeName : font};
    CGRect boundingRect = [text boundingRectWithSize:maximumLabelSize
                                             options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                          attributes:attributes
                                             context:NSStringDrawingContext.new];

    return ceilf(CGRectGetHeight(boundingRect) + 75);
}

- (id)paragraphsFromString:(NSString *)string {
    NSMutableArray *array = [NSMutableArray array];
    [string enumerateSubstringsInRange:NSMakeRange(0, string.length) options:NSStringEnumerationByParagraphs usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
        [array addObject:substring];
    }];
    return array;
}
@end
