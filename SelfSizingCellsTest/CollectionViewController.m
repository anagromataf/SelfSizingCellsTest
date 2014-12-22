//
//  CollectionViewController.m
//  SelfSizingCellsTest
//
//  Created by Tobias Kraentzer on 20.12.14.
//  Copyright (c) 2014 Tobias Kraentzer. All rights reserved.
//

#import "CollectionViewCell.h"

#import "CollectionViewController.h"

@interface CollectionViewController ()
@property (nonatomic, strong) NSMutableArray *items;
@end

@implementation CollectionViewController

static NSString * const reuseIdentifier = @"CollectionViewCell";

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.items = [[NSMutableArray alloc] init];
    
    // If not set to YES, the collection view can not be scrolled after an reload (even if the content size is big enough).
    self.collectionView.alwaysBounceVertical = YES;
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"CollectionViewCell" bundle:nil]
          forCellWithReuseIdentifier:reuseIdentifier];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

#pragma mark Actions

- (IBAction)removeAll:(id)sender
{
    if ([self.items count] > 0) {
        [self.items removeAllObjects];
        [self.collectionView performBatchUpdates:^{
            [self.collectionView deleteSections:[NSIndexSet indexSetWithIndex:0]];
        } completion:^(BOOL finished) {
            
        }];
    }
}

- (IBAction)add:(id)sender
{
    NSString *text = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec a diam lectus. Sed sit amet ipsum mauris. Maecenas congue ligula ac quam viverra nec consectetur ante hendrerit. Donec et mollis dolor.";
    
    [self.items addObject:[NSString stringWithFormat:@"%lu - %@", (unsigned long)self.items.count, text]];
    [self.collectionView performBatchUpdates:^{
        if ([self.items count] == 1) {
            [self.collectionView insertSections:[NSIndexSet indexSetWithIndex:0]];
        } else {
            [self.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:[self.items count] - 1 inSection:0]]];
        }
    } completion:^(BOOL finished) {
        
    }];
}

- (IBAction)reload:(id)sender
{
    [self.collectionView reloadData];
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return [self.items count] > 0 ? 1 : 0;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return section == 0 ? [self.items count] : 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier
                                                                           forIndexPath:indexPath];
    cell.label.text = [self.items objectAtIndex:indexPath.item];
    
    return cell;
}

@end
