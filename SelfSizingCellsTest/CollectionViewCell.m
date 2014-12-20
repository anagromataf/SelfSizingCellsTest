//
//  CollectionViewCell.m
//  SelfSizingCellsTest
//
//  Created by Tobias Kraentzer on 20.12.14.
//  Copyright (c) 2014 Tobias Kraentzer. All rights reserved.
//

#import "CollectionViewCell.h"

@implementation CollectionViewCell

- (UICollectionViewLayoutAttributes *)preferredLayoutAttributesFittingAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes
{
    self.label.preferredMaxLayoutWidth = layoutAttributes.size.width - 16;
    return [super preferredLayoutAttributesFittingAttributes:layoutAttributes];
}

@end
