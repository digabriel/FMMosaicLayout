//
//  FMLightboxMosaicLayout.m
//  FMLightboxMosaic
//
//  Created by Julian Villella on 2015-01-30.
//  Copyright (c) 2015 Fluid Media. All rights reserved.
//

#import "FMLightboxMosaicLayout.h"
#import <objc/message.h>

static const NSInteger kFMDefaultNumberOfColumnsInSection = 2;
static const FMMosaicCellSize kFMDefaultCellSize = FMMosaicCellSizeSmall;

@interface FMLightboxMosaicLayout ()

/**
 *  A 2D array holding an array of columns heights for each section
 */
@property (nonatomic, strong) NSMutableArray *columnHeightsInSection;
@property (nonatomic, strong) NSMutableDictionary *layoutAttributes;

@end

@implementation FMLightboxMosaicLayout

- (void)prepareLayout {
    for (NSInteger sectionIndex = 0; sectionIndex < [self.collectionView numberOfSections]; sectionIndex++) {
        for (NSInteger cellIndex = 0; cellIndex < [self.collectionView numberOfItemsInSection:sectionIndex]; cellIndex++) {
            NSIndexPath *cellIndexPath = [NSIndexPath indexPathForItem:cellIndex inSection:sectionIndex];
            
            NSInteger indexOfShortestColumn = [self indexOfShortestColumnInSection:sectionIndex];
            FMMosaicCellSize mosaicCellSize = [self mosaicCellSizeForItemAtIndexPath:cellIndexPath];
            
            NSInteger smallMosaicCellsBufferCount = 0;
            if (mosaicCellSize == FMMosaicCellSizeBig) {
                CGFloat cellHeight = [self cellHeightForMosaicSize:FMMosaicCellSizeBig section:sectionIndex];
                CGFloat columnHeight = [self.columnHeightsInSection[sectionIndex][indexOfShortestColumn] floatValue];
                
                UICollectionViewLayoutAttributes *layoutAttributes = [[UICollectionViewLayoutAttributes alloc] init];
                CGPoint origin = CGPointMake(indexOfShortestColumn * [self columnWidthInSection:sectionIndex], columnHeight);
                layoutAttributes.frame = CGRectMake(origin.x, origin.y, cellHeight, cellHeight);
                [self.layoutAttributes setObject:layoutAttributes forKey:cellIndexPath];
                
                self.columnHeightsInSection[sectionIndex][indexOfShortestColumn] = @(columnHeight + cellHeight);
                
            } else if(mosaicCellSize == FMMosaicCellSizeSmall) {
                smallMosaicCellsBufferCount++;
                if(smallMosaicCellsBufferCount >= 2) {
                    smallMosaicCellsBufferCount = 0;
                    
                    CGFloat cellHeight = [self cellHeightForMosaicSize:FMMosaicCellSizeBig section:sectionIndex];
                    CGFloat columnHeight = [self.columnHeightsInSection[sectionIndex][indexOfShortestColumn] floatValue];
                    
                    CGPoint origin = CGPointMake(indexOfShortestColumn * [self columnWidthInSection:sectionIndex], columnHeight);
                    UICollectionViewLayoutAttributes *layoutAttributes = [[UICollectionViewLayoutAttributes alloc] init];
                    layoutAttributes.frame = CGRectMake(origin.x, origin.y, cellHeight, cellHeight);
                    [self.layoutAttributes setObject:layoutAttributes forKey:cellIndexPath];
                    
                    self.columnHeightsInSection[sectionIndex][indexOfShortestColumn] = @(columnHeight + cellHeight);
                }
            }
        }
    }
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSMutableArray *attributesInRect = [[NSMutableArray alloc] initWithCapacity:self.layoutAttributes.count];
    
    [self.layoutAttributes enumerateKeysAndObjectsUsingBlock:^(NSIndexPath *indexPath, UICollectionViewLayoutAttributes *attributes, BOOL *stop) {
        if(CGRectIntersectsRect(rect, attributes.frame)){
            [attributesInRect addObject:attributes];
        }
    }];
    
    return attributesInRect;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self.layoutAttributes objectForKey:indexPath];
}

- (CGSize)collectionViewContentSize {
#warning Implement me
    return CGSizeMake(self.collectionView.bounds.size.width, 10000.0);
}

#pragma mark - Accessors

- (NSArray *)columnHeightsInSection {
    if (!_columnHeightsInSection) {
        NSInteger sectionCount = [self.collectionView numberOfSections];
        _columnHeightsInSection = [[NSMutableArray alloc] initWithCapacity:sectionCount];
        
        for (NSInteger sectionIndex = 0; sectionIndex < sectionCount; sectionIndex++) {
            NSInteger numberOfColumnsInSection = [self numberOfColumnsInSection:sectionIndex];
            NSMutableArray *columnHeights = [[NSMutableArray alloc] initWithCapacity:numberOfColumnsInSection];
            for (NSInteger columnIndex = 0; columnIndex < numberOfColumnsInSection; columnIndex++) {
                [columnHeights addObject:@0.0];
            }
            
            [_columnHeightsInSection addObject:columnHeights];
        }
    }
    
    return _columnHeightsInSection;
}

#pragma mark - Helpers

- (CGFloat)cellHeightForMosaicSize:(FMMosaicCellSize)mosaicCellSize section:(NSInteger)section {
    CGFloat bigCellSize = self.collectionViewContentSize.width / [self numberOfColumnsInSection:section];
    return mosaicCellSize == FMMosaicCellSizeBig ? bigCellSize : bigCellSize / 2.0;
}

- (NSInteger)indexOfShortestColumnInSection:(NSInteger)section {
    NSArray *columnHeights = [self.columnHeightsInSection objectAtIndex:section];

    NSInteger indexOfShortestColumn = 0;
    for(int i = 1; i < columnHeights.count; i++) {
        if(columnHeights[i] < columnHeights[indexOfShortestColumn])
            indexOfShortestColumn = i;
    }
    
    return indexOfShortestColumn;
}

- (NSInteger)numberOfColumnsInSection:(NSInteger)section {
    NSInteger columnCount = kFMDefaultNumberOfColumnsInSection;
    if ([self.delegate respondsToSelector:@selector(collectionView:layout:numberOfColumnsInSection:)]) {
        columnCount = [self.delegate collectionView:self.collectionView layout:self numberOfColumnsInSection:section];
    }
    return columnCount;
}

- (CGFloat)columnWidthInSection:(NSInteger)section {
    return self.collectionViewContentSize.width / [self numberOfColumnsInSection:section];
}

- (FMMosaicCellSize)mosaicCellSizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    FMMosaicCellSize cellSize = kFMDefaultCellSize;
    if ([self.delegate respondsToSelector:@selector(collectionView:layout:mosaicCellSizeForItemAtIndexPath:)]) {
        cellSize = [self.delegate collectionView:self.collectionView layout:self mosaicCellSizeForItemAtIndexPath:indexPath];
    }
    return cellSize;
}

@end
