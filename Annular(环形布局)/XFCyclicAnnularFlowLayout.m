//
//  XFCyclicAnnularFlowLayout.m
//  Annular(环形布局)
//
//  Created by YanYi on 2018/4/19.
//  Copyright © 2018年 YanYi. All rights reserved.
//

#import "XFCyclicAnnularFlowLayout.h"

#define SCREEN_WIDTH  ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT  ([UIScreen mainScreen].bounds.size.height)


@interface XFCyclicAnnularFlowLayout ()

@property (nonatomic, strong) NSMutableArray        *myAttrs;

@end

@implementation XFCyclicAnnularFlowLayout




- (void)prepareLayout {
    [super prepareLayout];
    NSInteger sectionCount = [self.delegate numberOfSectionsInFlowLayout:self];
    for (NSInteger section = 0; section < sectionCount; section ++ ) {
        NSInteger rowCount = [self.delegate flowLayout:self numberOfItemsInSection:section];
        for (NSInteger row = 0; row < rowCount; row ++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
            [self.myAttrs addObject:[self layoutAttributesForItemAtIndexPath:indexPath]];
        }
    }
}


- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewLayoutAttributes *attr = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    NSInteger rowsNum = [self.delegate flowLayout:self numberOfItemsInSection:indexPath.section];
    CGFloat radius = [self.delegate flowLayout:self cyclicAnnularRadiusInSection:indexPath.section];
//    CGFloat radian = [self.delegate cyclicAnnularRadianInFlowLayout:self];
    CGFloat radian = [self.delegate flowLayout:self cyclicAnnularRadianInSection:indexPath.section];
    // 当前item 所处的弧度
    BOOL isClockwise = [self.delegate flowLayout:self cyclicIsClockwiseInSection:indexPath.section];
    CGFloat item_radian =  indexPath.row * radian / (rowsNum - 1);

    // 是否是顺时针 默认是顺时针
    if (isClockwise) {
        CGFloat startRadian = (M_PI - radian)/2;
        item_radian = item_radian + M_PI + startRadian;
    } else {
        item_radian = -item_radian;
        CGFloat startRadian = ( radian - M_PI)/2;
        item_radian = item_radian + startRadian;
    }
    CGFloat item_x = cosf(item_radian) * radius + SCREEN_WIDTH / 2;
    CGFloat item_y = sinf(item_radian) * radius + SCREEN_HEIGHT / 2;

    CGSize item_size = [self.delegate flowLayout:self cyclicAnnularItemSizeAtindexPath:indexPath];
    attr.frame = CGRectMake(0, 0, item_size.width, item_size.height);
    attr.center = CGPointMake(item_x, item_y);
    [self setAttr:attr itemRadian:item_radian];
    
    return attr;
}


- (UICollectionViewLayoutAttributes *)setAttr:(UICollectionViewLayoutAttributes *)attr
                                   itemRadian:(CGFloat)itemRadian {
    
    XFCyclicAnnularItemOrientation orientation = [self.delegate cyclicAnnularItemOrientationInFlowLayout:self];
    switch (orientation) {
        case XFCyclicAnnularItemOrientationUp:
            break;
        case XFCyclicAnnularItemOrientationDown:
            attr.transform3D = CATransform3DMakeRotation(M_PI , 0, 0, 1);
            break;
        case XFCyclicAnnularItemOrientationInside:
            attr.transform3D = CATransform3DMakeRotation(itemRadian - M_PI/2 , 0, 0, 1);
            break;
        case XFCyclicAnnularItemOrientationOutside:
            attr.transform3D = CATransform3DMakeRotation(itemRadian + M_PI/2, 0, 0, 1);
            break;
        default:
            break;
    }
    return attr;
}



- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    return self.myAttrs;
}

- (NSMutableArray *)myAttrs {
    if (_myAttrs == nil) {
        _myAttrs = [NSMutableArray new];
    }
    return _myAttrs;
}

@end
