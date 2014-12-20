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
@property (nonatomic, assign) BOOL updated;
@end

@implementation CollectionViewController

static NSString * const reuseIdentifier = @"CollectionViewCell";

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.collectionView registerNib:[UINib nibWithNibName:@"CollectionViewCell" bundle:nil]
          forCellWithReuseIdentifier:reuseIdentifier];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.updated = YES;
        [self.collectionView performBatchUpdates:^{
            [self.collectionView insertSections:[NSIndexSet indexSetWithIndex:0]];
        } completion:^(BOOL finished) {
            
        }];
    });
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.updated ? 1 : 0;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.updated ? 1 : 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier
                                                                           forIndexPath:indexPath];
    
    cell.label.text = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec a diam lectus. Sed sit amet ipsum mauris. Maecenas congue ligula ac quam viverra nec consectetur ante hendrerit. Donec et mollis dolor. Praesent et diam eget libero egestas mattis sit amet vitae augue. Nam tincidunt congue enim, ut porta lorem lacinia consectetur.";
    
    return cell;
}

@end
