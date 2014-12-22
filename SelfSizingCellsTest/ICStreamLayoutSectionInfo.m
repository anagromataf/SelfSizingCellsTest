//
//  ICStreamLayoutSectionInfo.m
//  Intercambio
//
//  Created by Tobias Kraentzer on 18.12.14.
//  Copyright (c) 2014 Tobias Kräntzer. All rights reserved.
//

#import "ICStreamLayoutInfo.h"

#import "ICStreamLayoutSectionInfo.h"

@interface ICStreamLayoutSectionInfo ()
@property (nonatomic, readonly) NSMutableIndexSet *itemIndexes;
@property (nonatomic, readonly) NSMutableDictionary *itemLayoutInfos;
@end

@implementation ICStreamLayoutSectionInfo

#pragma mark Life-cycle

- (instancetype)init
{
    self = [super init];
    if (self) {
        _itemIndexes = [[NSMutableIndexSet alloc] init];
        _itemLayoutInfos = [[NSMutableDictionary alloc] init];
    }
    return self;
}

#pragma mark Item Layout Infos

- (void)setLayoutInfo:(ICStreamLayoutItemInfo *)layoutInfo forItemAtIndex:(NSUInteger)itemIndex
{
    CGFloat delta = layoutInfo.size.height;
    
    ICStreamLayoutItemInfo *oldItemLayoutInfo = [self.itemLayoutInfos objectForKey:@(itemIndex)];
    if (oldItemLayoutInfo) {
        delta -= oldItemLayoutInfo.size.height;
    }
    
    [self.itemIndexes addIndex:itemIndex];
    [self.itemLayoutInfos setObject:layoutInfo forKey:@(itemIndex)];
    layoutInfo.sectionLayoutInfo = self;
    layoutInfo.index = itemIndex;
    
    CGPoint originInSection = CGPointMake(0, 0);
    
    NSUInteger previousIndex = [self.itemIndexes indexLessThanIndex:itemIndex];
    if (previousIndex != NSNotFound) {
        ICStreamLayoutItemInfo *previousLayoutInfo = [self.itemLayoutInfos objectForKey:@(previousIndex)];
        originInSection.y = previousLayoutInfo.originInSection.y + previousLayoutInfo.size.height;
    }
    
    layoutInfo.originInSection = originInSection;
    
    if (delta != 0) {
        NSUInteger index = [self.itemIndexes indexGreaterThanIndex:itemIndex];
        while (index != NSNotFound) {
            ICStreamLayoutItemInfo *itemLayoutInfo = [self.itemLayoutInfos objectForKey:@(index)];
            CGPoint origin = itemLayoutInfo.originInSection;
            origin.y += delta;
            itemLayoutInfo.originInSection = origin;
            index = [self.itemIndexes indexGreaterThanIndex:index];
        }
        CGSize size = self.size;
        size.height += delta;
        self.size = size;
    }
}

- (ICStreamLayoutItemInfo *)layoutInfoForItemAtIndex:(NSUInteger)itemIndex
{
    return [self.itemLayoutInfos objectForKey:@(itemIndex)];
}

- (void)enumerateLayoutInfosForItemsInRect:(CGRect)rect block:(void(^)(ICStreamLayoutItemInfo *itemLayoutInfo, BOOL *stop))block
{
    if (block) {
        [self.itemIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
            ICStreamLayoutItemInfo *layoutInfo = [self.itemLayoutInfos objectForKey:@(idx)];
            if (CGRectIntersectsRect(layoutInfo.frame, rect)) {
                block(layoutInfo, stop);
            }
        }];
    }
}

#pragma mark Frame

- (CGRect)frame
{
    CGRect frame;
    frame.size = self.size;
    frame.origin = self.origin;
    return frame;
}

#pragma mark Size Changes

- (void)setSize:(CGSize)size
{
    if (!CGSizeEqualToSize(_size, size)) {
        CGSize old = _size;
        _size = size;
        [self.layoutInfo sectionLayoutInfo:self changedSizeFrom:old to:size];
    }
}

- (void)itemLayoutInfo:(ICStreamLayoutItemInfo *)layoutInfo changedSizeFrom:(CGSize)from to:(CGSize)to
{
    CGFloat delta = to.height - from.height;
    
    NSUInteger index = [self.itemIndexes indexGreaterThanIndex:layoutInfo.index];
    while (index != NSNotFound) {
        ICStreamLayoutItemInfo *itemLayoutInfo = [self.itemLayoutInfos objectForKey:@(index)];
        CGPoint origin = itemLayoutInfo.originInSection;
        origin.y += delta;
        itemLayoutInfo.originInSection = origin;
        index = [self.itemIndexes indexGreaterThanIndex:index];
    }
    CGSize size = self.size;
    size.height += delta;
    self.size = size;
}

@end
