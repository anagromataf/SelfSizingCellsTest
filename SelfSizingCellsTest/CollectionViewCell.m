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
    // Set the preferred max layout with such that auto layout can compute the
    // height of the multiline label correctly.
    self.label.preferredMaxLayoutWidth = layoutAttributes.size.width - 16;
    
    // The preferred layout attributes must be copied, because the collection view
    // does not recognize a change, if the size of the preferred layout attributes
    // is smaller than the size of the original layout attributes.
    UICollectionViewLayoutAttributes *preferredLayoutAttributes = [[super preferredLayoutAttributesFittingAttributes:layoutAttributes] copy];
    
    // The default implementation of the collection view cell does not update the size
    // of the preferred layout attributes, it is smaller than the original size.
    preferredLayoutAttributes.size = [self systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    
    return preferredLayoutAttributes;
}

- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSLog(@".. %@", layoutAttributes);
    [super applyLayoutAttributes:layoutAttributes];
}

@end
