//
//  ICStreamLayout.m
//  Intercambio
//
//  Created by Tobias Kraentzer on 17.12.14.
//  Copyright (c) 2014 Tobias Kräntzer. All rights reserved.
//

#import "ICStreamLayoutInfo.h"
#import "ICStreamLayoutInvalidationContext.h"

#import "ICStreamLayout.h"

@interface ICStreamLayout ()
#pragma mark Layout Attributes
@property (nonatomic, readonly) NSMutableDictionary *itemLayoutAttributesByIndexPath;

#pragma mark Layout Info
@property (nonatomic, assign) BOOL layoutInfoIsValid;
@property (nonatomic, strong) ICStreamLayoutInfo *layoutInfo;
@end

@implementation ICStreamLayout

+ (Class)invalidationContextClass
{
    return [ICStreamLayoutInvalidationContext class];
}

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
}

#pragma mark Providing Layout Attributes

- (void)prepareLayout
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSLog(@".. layout is valid: %@", self.layoutInfoIsValid ? @"YES":@"NO");
    
    if (self.layoutInfoIsValid == NO) {
        NSLog(@".. bulding layout information");
        [self.itemLayoutAttributesByIndexPath removeAllObjects];
        [self buildLayoutInfo];
    }
    
    NSLog(@".. %@", NSStringFromCGSize(self.layoutInfo.size));
    
    id<UICollectionViewDataSource> dataSource = self.collectionView.dataSource;
    NSUInteger numberOfSections = [dataSource numberOfSectionsInCollectionView:self.collectionView];
    for (NSUInteger sectionIndex = 0; sectionIndex < numberOfSections; sectionIndex++) {
        
        ICStreamLayoutSectionInfo *sectionLayoutInfo = [self.layoutInfo layoutInfoForSectionAtIndex:sectionIndex];
        
        NSLog(@".. section: %lu - %@", (unsigned long)sectionIndex, NSStringFromCGRect(sectionLayoutInfo.frame));
        
        NSUInteger numberOfItems = [dataSource collectionView:self.collectionView numberOfItemsInSection:sectionIndex];
        for (NSUInteger itemIndex = 0; itemIndex < numberOfItems; itemIndex++) {
            ICStreamLayoutItemInfo *itemLayoutInfo = [sectionLayoutInfo layoutInfoForItemAtIndex:itemIndex];
        
            NSLog(@".... item: %lu - %@", (unsigned long)itemIndex, NSStringFromCGRect(itemLayoutInfo.frame));
        }
    }
    
    [super prepareLayout];
}

- (void)prepareForCollectionViewUpdates:(NSArray *)updateItems
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    [updateItems enumerateObjectsUsingBlock:^(UICollectionViewUpdateItem *updateItem, NSUInteger idx, BOOL *stop) {
        NSLog(@".. %@", updateItem);
    }];
    
    [super prepareForCollectionViewUpdates:updateItems];
}

- (void)finalizeCollectionViewUpdates
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSLog(@".. %@", NSStringFromCGRect(rect));
    
    NSMutableArray *attributes = [[NSMutableArray alloc] init];
    [self.layoutInfo enumerateLayoutInfosForSectionsInRect:rect block:^(ICStreamLayoutSectionInfo *sectionLayoutInfo, BOOL *stop) {
        
        [sectionLayoutInfo enumerateLayoutInfosForItemsInRect:rect block:^(ICStreamLayoutItemInfo *itemLayoutInfo, BOOL *stop) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:itemLayoutInfo.index inSection:sectionLayoutInfo.index];
            UICollectionViewLayoutAttributes *a = [self.itemLayoutAttributesByIndexPath objectForKey:indexPath];
            if (a == nil) {
                a = [[[self class] layoutAttributesClass] layoutAttributesForCellWithIndexPath:indexPath];
                a.frame = itemLayoutInfo.frame;
                [self.itemLayoutAttributesByIndexPath setObject:a forKey:indexPath];
            }
            [attributes addObject:a];
            NSLog(@".... section: %ld item: %ld - %@ - %p", (long)indexPath.section, (long)indexPath.item, NSStringFromCGRect(a.frame), a);
        }];
    }];
    return attributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    ICStreamLayoutItemInfo *itemLayoutInfo = [self.layoutInfo layoutInfoForItemAtIndexPath:indexPath];
    if (itemLayoutInfo) {
        UICollectionViewLayoutAttributes *attributes = [self.itemLayoutAttributesByIndexPath objectForKey:indexPath];
        if (attributes == nil) {
            attributes = [[[self class] layoutAttributesClass] layoutAttributesForCellWithIndexPath:indexPath];
            attributes.frame = itemLayoutInfo.frame;
            [self.itemLayoutAttributesByIndexPath setObject:attributes forKey:indexPath];
        }
        NSLog(@".. %@", attributes);
        return attributes;
    } else {
        return nil;
    }
}

#pragma mark Getting the Collection View Information

- (CGSize)collectionViewContentSize
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSLog(@".. %@", NSStringFromCGSize(self.layoutInfo.size));
    return self.layoutInfo.size;
}

#pragma mark Invalidating the Layout

- (void)invalidateLayoutWithContext:(ICStreamLayoutInvalidationContext *)context
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSLog(@".. size adjustment: %@", NSStringFromCGSize(context.contentSizeAdjustment));
    NSLog(@".. content size: %@", NSStringFromCGSize(self.layoutInfo.size));
    
    if (context.invalidateDataSourceCounts || context.invalidateEverything) {
        NSLog(@".. invalidating all");
        self.layoutInfoIsValid = NO;
        [self.itemLayoutAttributesByIndexPath removeAllObjects];
    } else if (context.invalidateLayoutInfoSizes) {
        [context invalidateItemsAtIndexPaths:[self.itemLayoutAttributesByIndexPath allKeys]];
        [self.itemLayoutAttributesByIndexPath removeAllObjects];
        self.layoutInfoIsValid = NO;
    } else {
        NSLog(@".. invalidating:");
        [context.invalidatedItemIndexPaths enumerateObjectsUsingBlock:^(NSIndexPath *indexPath, NSUInteger idx, BOOL *stop) {
            [self.itemLayoutAttributesByIndexPath removeObjectForKey:indexPath];
            NSLog(@".... section: %ld item: %ld", (long)indexPath.section, (long)indexPath.item);
        }];
    }
    
    [super invalidateLayoutWithContext:context];
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return CGRectGetWidth(newBounds) != self.layoutInfo.size.width;
}

- (ICStreamLayoutInvalidationContext *)invalidationContextForBoundsChange:(CGRect)newBounds
{
    ICStreamLayoutInvalidationContext *context = (ICStreamLayoutInvalidationContext *)[super invalidationContextForBoundsChange:newBounds];
    context.invalidateLayoutInfoSizes = YES;
    return context;
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
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    UICollectionViewLayoutInvalidationContext *invalidationContext = [super invalidationContextForPreferredLayoutAttributes:preferredAttributes withOriginalAttributes:originalAttributes];
    
    CGSize originalContentSize = self.layoutInfo.size;
    
    ICStreamLayoutItemInfo *itemLayoutInfo = [self.layoutInfo layoutInfoForItemAtIndexPath:originalAttributes.indexPath];
    if (itemLayoutInfo) {
        itemLayoutInfo.size = CGSizeMake(CGRectGetWidth(self.collectionView.bounds), preferredAttributes.size.height);
        NSLog(@".. updating section: %ld item: %ld - %@", originalAttributes.indexPath.section, originalAttributes.indexPath.item, NSStringFromCGSize(itemLayoutInfo.size));
        id<UICollectionViewDataSource> dataSource = self.collectionView.dataSource;
        
        NSUInteger numberOfSections = [dataSource numberOfSectionsInCollectionView:self.collectionView];
        for (NSUInteger sectionIndex = originalAttributes.indexPath.section; sectionIndex < numberOfSections; sectionIndex++) {
            
            NSUInteger numberOfItems = [dataSource collectionView:self.collectionView numberOfItemsInSection:sectionIndex];
            NSUInteger itemIndex = 0;
            if (sectionIndex == originalAttributes.indexPath.section) {
                itemIndex = originalAttributes.indexPath.item;
            }
            for (; itemIndex < numberOfItems; itemIndex++) {
                [invalidationContext invalidateItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:itemIndex inSection:sectionIndex]]];
            }
        }
    }
    
    CGSize adjustedContentSize = self.layoutInfo.size;
    
    invalidationContext.contentSizeAdjustment = CGSizeMake(adjustedContentSize.width - originalContentSize.width,
                                                           adjustedContentSize.height - originalContentSize.height);
    
    return invalidationContext;
}

#pragma mark Internal

- (void)buildLayoutInfo
{
    CGFloat width = CGRectGetWidth(self.collectionView.bounds);
    
    id<UICollectionViewDataSource> dataSource = self.collectionView.dataSource;
    
    ICStreamLayoutInfo *layoutInfo = [[ICStreamLayoutInfo alloc] init];
    layoutInfo.size = CGSizeMake(width, 0);
    
    NSUInteger numberOfSections = [dataSource numberOfSectionsInCollectionView:self.collectionView];
    for (NSUInteger sectionIndex = 0; sectionIndex < numberOfSections; sectionIndex++) {
        
        ICStreamLayoutSectionInfo *sectionLayoutInfo = [[ICStreamLayoutSectionInfo alloc] init];
        sectionLayoutInfo.size = CGSizeMake(width, 0);
        
        NSUInteger numberOfItems = [dataSource collectionView:self.collectionView numberOfItemsInSection:sectionIndex];
        for (NSUInteger itemIndex = 0; itemIndex < numberOfItems; itemIndex++) {
            ICStreamLayoutItemInfo *itemLayoutInfo = [[ICStreamLayoutItemInfo alloc] init];
            itemLayoutInfo.size = CGSizeMake(width, 50);
            [sectionLayoutInfo setLayoutInfo:itemLayoutInfo forItemAtIndex:itemIndex];
        }
        
        [layoutInfo setLayoutInfo:sectionLayoutInfo forSectionAtIndex:sectionIndex];
    }
    
    self.layoutInfo = layoutInfo;
    self.layoutInfoIsValid = YES;
}

@end
