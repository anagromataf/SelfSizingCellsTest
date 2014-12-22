//
//  ICStreamLayoutInvalidationContext.h
//  SelfSizingCellsTest
//
//  Created by Tobias Kraentzer on 22.12.14.
//  Copyright (c) 2014 Tobias Kraentzer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ICStreamLayoutInvalidationContext : UICollectionViewLayoutInvalidationContext
@property (nonatomic, assign) BOOL invalidateLayoutInfoSizes;
@end
