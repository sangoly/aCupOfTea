//
//  LXPersonalDetailController.m
//  aCupOfTea
//
//  Created by mwsn on 14-12-26.
//  Copyright (c) 2014年 Sangoly. All rights reserved.
//

#import "LXPersonalDetailController.h"
#import "LXUserInfo.h"

@interface LXPersonalDetailController ()

@end

@implementation LXPersonalDetailController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.title = @"个人资料";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Regist the cell reuse identifier
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [_personalDetailKeys count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier];
    cell.textLabel.text = [_personalDetailKeys objectAtIndex:indexPath.row];
    if (indexPath.row == 1) {
        NSInteger time = [[_personalDetailValues objectAtIndex:indexPath.row] integerValue];
        NSString *timeStr = [[NSString alloc] initWithFormat:@"%i小时%i分", time/60, time%60];
        cell.detailTextLabel.text = timeStr;
    } else {
        cell.detailTextLabel.text = [_personalDetailValues objectAtIndex:indexPath.row];
    }
    // Configure the cell...
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
@end
