//
//  CollectionViewLayout.m
//  SelfSizingCellsTest
//
//  Created by Tobias Kraentzer on 20.12.14.
//  Copyright (c) 2014 Tobias Kraentzer. All rights reserved.
//

#import "CollectionViewLayout.h"

@interface CollectionViewLayout ()
@property (nonatomic, readonly) NSMutableDictionary *itemSizeByIndexPath;
@property (nonatomic, readonly) NSMutableDictionary *itemLayoutAttributesByIndexPath;
@property (nonatomic, assign) BOOL layoutInfoIsValid;
@end

@implementation CollectionViewLayout

#pragma mark Life-cycle

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    _itemLayoutAttributesByIndexPath = [[NSMutableDictionary alloc] init];
    _itemSizeByIndexPath = [[NSMutableDictionary alloc] init];
}

#pragma mark Providing Layout Attributes

- (void)prepareLayout
{
    if (self.layoutInfoIsValid == NO) {
        [self.itemLayoutAttributesByIndexPath removeAllObjects];
        [self.itemSizeByIndexPath removeAllObjects];
        [self buildLayoutInfo];
    }
    
    [super prepareLayout];
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    return [self.itemLayoutAttributesByIndexPath allValues];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes *attributes = [self.itemLayoutAttributesByIndexPath objectForKey:indexPath];
    if (attributes == nil) {
        attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        attributes.frame = [[self.itemSizeByIndexPath objectForKey:indexPath] CGRectValue];
        [self.itemLayoutAttributesByIndexPath setObject:attributes forKey:indexPath];
    }
    return attributes;
}

#pragma mark Getting the Collection View Information

- (CGSize)collectionViewContentSize
{
    __block CGFloat height = 0;
    [self.itemSizeByIndexPath enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        CGRect itemFrame = [obj CGRectValue];
        height += itemFrame.size.height;
    }];
    
    return CGSizeMake(CGRectGetWidth(self.collectionView.bounds), height);
}

#pragma mark Invalidating the Layout

- (void)invalidateLayoutWithContext:(UICollectionViewLayoutInvalidationContext *)context
{
    if (context.invalidateDataSourceCounts || context.invalidateEverything) {
        self.layoutInfoIsValid = NO;
        [self.itemLayoutAttributesByIndexPath removeAllObjects];
    } else {
        [context.invalidatedItemIndexPaths enumerateObjectsUsingBlock:^(NSIndexPath *indexPath, NSUInteger idx, BOOL *stop) {
            [self.itemLayoutAttributesByIndexPath removeObjectForKey:indexPath];
        }];
    }
    
    [super invalidateLayoutWithContext:context];
}

- (BOOL)shouldInvalidateLayoutForPreferredLayoutAttributes:(UICollectionViewLayoutAttributes *)preferredAttributes withOriginalAttributes:(UICollectionViewLayoutAttributes *)originalAttributes
{
    if (preferredAttributes.size.height != originalAttributes.size.height) {
        return YES;
    } else {
        return NO;
    }
}

- (UICollectionViewLayoutInvalidationContext *)invalidationContextForPreferredLayoutAttributes:(UICollectionViewLayoutAttributes *)preferredAttributes withOriginalAttributes:(UICollectionViewLayoutAttributes *)originalAttributes
{
    UICollectionViewLayoutInvalidationContext *invalidationContext = [super invalidationContextForPreferredLayoutAttributes:preferredAttributes withOriginalAttributes:originalAttributes];
    
    [invalidationContext invalidateItemsAtIndexPaths:@[preferredAttributes.indexPath]];
    
    [self.itemSizeByIndexPath setObject:[NSValue valueWithCGRect:CGRectMake(0,
                                                                            0,
                                                                            self.collectionView.bounds.size.width,
                                                                            preferredAttributes.size.height)]
                                 forKey:preferredAttributes.indexPath];
    
    return invalidationContext;
}

#pragma mark Internal

- (void)buildLayoutInfo
{
    CGFloat width = CGRectGetWidth(self.collectionView.bounds);
    
    id<UICollectionViewDataSource> dataSource = self.collectionView.dataSource;
    
    NSUInteger numberOfSections = [dataSource numberOfSectionsInCollectionView:self.collectionView];
    for (NSUInteger sectionIndex = 0; sectionIndex < numberOfSections; sectionIndex++) {
        
        NSUInteger numberOfItems = [dataSource collectionView:self.collectionView numberOfItemsInSection:sectionIndex];
        for (NSUInteger itemIndex = 0; itemIndex < numberOfItems; itemIndex++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:itemIndex inSection:sectionIndex];
            [self.itemSizeByIndexPath setObject:[NSValue valueWithCGRect:CGRectMake(0, 0, width, 50)] forKey:indexPath];
        }
    }
    
    self.layoutInfoIsValid = YES;
}

@end
