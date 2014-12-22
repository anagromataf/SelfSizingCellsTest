//
//  ICStreamLayoutSectionInfo.h
//  Intercambio
//
//  Created by Tobias Kraentzer on 18.12.14.
//  Copyright (c) 2014 Tobias Kräntzer. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ICStreamLayoutItemInfo.h"

@class ICStreamLayoutInfo;

@interface ICStreamLayoutSectionInfo : NSObject

@property (nonatomic, weak) ICStreamLayoutInfo *layoutInfo;
@property (nonatomic, assign) NSUInteger index;

@property (nonatomic, assign) CGPoint origin;
@property (nonatomic, assign) CGSize size;

@property (nonatomic, readonly) CGRect frame;

#pragma mark Item Layout Infos
- (void)setLayoutInfo:(ICStreamLayoutItemInfo *)layoutInfo forItemAtIndex:(NSUInteger)itemIndex;
- (ICStreamLayoutItemInfo *)layoutInfoForItemAtIndex:(NSUInteger)itemIndex;
- (void)enumerateLayoutInfosForItemsInRect:(CGRect)rect block:(void(^)(ICStreamLayoutItemInfo *itemLayoutInfo, BOOL *stop))block;

#pragma mark Size Changes
- (void)itemLayoutInfo:(ICStreamLayoutItemInfo *)layoutInfo changedSizeFrom:(CGSize)from to:(CGSize)to;

@end
