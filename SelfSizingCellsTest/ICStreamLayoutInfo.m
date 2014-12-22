//
//  ICStreamLayoutInfo.m
//  Intercambio
//
//  Created by Tobias Kraentzer on 17.12.14.
//  Copyright (c) 2014 Tobias Kräntzer. All rights reserved.
//

#import "ICStreamLayoutInfo.h"

@interface ICStreamLayoutInfo ()
@property (nonatomic, readonly) NSMutableIndexSet *sectionIndexes;
@property (nonatomic, readonly) NSMutableDictionary *sectionLayoutInfos;
@end

@implementation ICStreamLayoutInfo

#pragma mark Life-cycle

- (instancetype)init
{
    self = [super init];
    if (self) {
        _sectionIndexes = [[NSMutableIndexSet alloc] init];
        _sectionLayoutInfos = [[NSMutableDictionary alloc] init];
    }
    return self;
}

#pragma mark Section Layout Infos

- (void)setLayoutInfo:(ICStreamLayoutSectionInfo *)layoutInfo forSectionAtIndex:(NSUInteger)sectionIndex
{
    CGFloat delta = layoutInfo.size.height;
    
    ICStreamLayoutSectionInfo *oldLayoutInfo = [self.sectionLayoutInfos objectForKey:@(sectionIndex)];
    if (oldLayoutInfo) {
        delta -= oldLayoutInfo.size.height;
    }
    
    [self.sectionIndexes addIndex:sectionIndex];
    [self.sectionLayoutInfos setObject:layoutInfo forKey:@(sectionIndex)];
    layoutInfo.layoutInfo = self;
    layoutInfo.index = sectionIndex;
    
    CGPoint origin = CGPointMake(0, 0);
    
    NSUInteger previousIndex = [self.sectionIndexes indexLessThanIndex:sectionIndex];
    if (previousIndex != NSNotFound) {
        ICStreamLayoutSectionInfo *previousLayoutInfo = [self.sectionLayoutInfos objectForKey:@(previousIndex)];
        origin.y = previousLayoutInfo.origin.y + previousLayoutInfo.size.height;
    }
    
    layoutInfo.origin = origin;
    
    if (delta != 0) {
        NSUInteger index = [self.sectionIndexes indexGreaterThanIndex:sectionIndex];
        while (index != NSNotFound) {
            ICStreamLayoutSectionInfo *itemLayoutInfo = [self.sectionLayoutInfos objectForKey:@(index)];
            CGPoint origin = itemLayoutInfo.origin;
            origin.y += delta;
            itemLayoutInfo.origin = origin;
            index = [self.sectionIndexes indexGreaterThanIndex:index];
        }
        CGSize size = self.size;
        size.height += delta;
        self.size = size;
    }
}

- (ICStreamLayoutSectionInfo *)layoutInfoForSectionAtIndex:(NSUInteger)sectionIndex
{
    return [self.sectionLayoutInfos objectForKey:@(sectionIndex)];
}

- (void)enumerateLayoutInfosForSectionsInRect:(CGRect)rect
                                       block:(void(^)(ICStreamLayoutSectionInfo *, BOOL *stop))block
{
    if (block) {
        [self.sectionIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
            ICStreamLayoutSectionInfo *layoutInfo = [self.sectionLayoutInfos objectForKey:@(idx)];
            if (CGRectIntersectsRect(layoutInfo.frame, rect)) {
                block(layoutInfo, stop);
            }
        }];
    }
}

#pragma mark Item Layout Infos

- (ICStreamLayoutItemInfo *)layoutInfoForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ICStreamLayoutSectionInfo *sectionLayoutInfo = [self layoutInfoForSectionAtIndex:indexPath.section];
    if (sectionLayoutInfo) {
        ICStreamLayoutItemInfo *itemLayoutInfo = [sectionLayoutInfo layoutInfoForItemAtIndex:indexPath.item];
        return itemLayoutInfo;
    }
    return nil;
}

#pragma mark Size Changes

- (void)sectionLayoutInfo:(ICStreamLayoutSectionInfo *)layoutInfo changedSizeFrom:(CGSize)from to:(CGSize)to
{
    CGFloat delta = to.height - from.height;
    
    NSUInteger index = [self.sectionIndexes indexGreaterThanIndex:layoutInfo.index];
    while (index != NSNotFound) {
        ICStreamLayoutSectionInfo *itemLayoutInfo = [self.sectionLayoutInfos objectForKey:@(index)];
        CGPoint origin = itemLayoutInfo.origin;
        origin.y += delta;
        itemLayoutInfo.origin = origin;
        index = [self.sectionIndexes indexGreaterThanIndex:index];
    }
    CGSize size = self.size;
    size.height += delta;
    self.size = size;
}

@end
