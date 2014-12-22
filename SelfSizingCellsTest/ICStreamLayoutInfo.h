//
//  ICStreamLayoutInfo.h
//  Intercambio
//
//  Created by Tobias Kraentzer on 17.12.14.
//  Copyright (c) 2014 Tobias Kräntzer. All rights reserved.
//

#import <UIKit/UIKit.h>

#include "ICStreamLayoutItemInfo.h"
#include "ICStreamLayoutSectionInfo.h"

@interface ICStreamLayoutInfo : NSObject

@property (nonatomic, assign) CGSize size;

#pragma mark Section Layout Infos
- (void)setLayoutInfo:(ICStreamLayoutSectionInfo *)layoutInfo forSectionAtIndex:(NSUInteger)sectionIndex;
- (ICStreamLayoutSectionInfo *)layoutInfoForSectionAtIndex:(NSUInteger)sectionIndex;
- (void)enumerateLayoutInfosForSectionsInRect:(CGRect)rect block:(void(^)(ICStreamLayoutSectionInfo *sectionLayoutInfo, BOOL *stop))block;

#pragma mark Item Layout Infos
- (ICStreamLayoutItemInfo *)layoutInfoForItemAtIndexPath:(NSIndexPath *)indexPath;

#pragma mark Size Changes
- (void)sectionLayoutInfo:(ICStreamLayoutSectionInfo *)layoutInfo changedSizeFrom:(CGSize)from to:(CGSize)to;

@end
