//
//  ICStreamLayoutItemInfo.h
//  Intercambio
//
//  Created by Tobias Kraentzer on 18.12.14.
//  Copyright (c) 2014 Tobias Kräntzer. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ICStreamLayoutSectionInfo;

@interface ICStreamLayoutItemInfo : NSObject

@property (nonatomic, weak) ICStreamLayoutSectionInfo *sectionLayoutInfo;
@property (nonatomic, assign) NSUInteger index;

@property (nonatomic, assign) CGPoint originInSection;
@property (nonatomic, assign) CGSize size;

@property (nonatomic, readonly) CGPoint origin;
@property (nonatomic, readonly) CGRect frame;

@end
