//
//  ICStreamLayoutItemInfo.m
//  Intercambio
//
//  Created by Tobias Kraentzer on 18.12.14.
//  Copyright (c) 2014 Tobias Kräntzer. All rights reserved.
//

#import "ICStreamLayoutSectionInfo.h"

#import "ICStreamLayoutItemInfo.h"

@implementation ICStreamLayoutItemInfo

- (void)setSize:(CGSize)size
{
    if (!CGSizeEqualToSize(_size, size)) {
        CGSize old = _size;
        _size = size;
        [self.sectionLayoutInfo itemLayoutInfo:self changedSizeFrom:old to:size];
    }
}

- (CGPoint)origin
{
    CGPoint origin = self.sectionLayoutInfo.origin;
    origin.x += self.originInSection.x;
    origin.y += self.originInSection.y;
    return origin;
}

- (CGRect)frame
{
    CGRect frame;
    frame.size = self.size;
    frame.origin = self.origin;
    return frame;
}

@end
