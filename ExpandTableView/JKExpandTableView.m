//
//  JKExpandTableView.m
//  ExpandTableView
//
//  Created by Jack Kwok on 7/5/13.
//  Copyright (c) 2013 Jack Kwok. All rights reserved.
//

#import "JKExpandTableView.h"
#import "JKParentTableViewCell.h"
#import "JKMultiSelectSubTableViewCell.h"
#import "JKSingleSelectSubTableViewCell.h"

@implementation JKExpandTableView
@synthesize tableViewDelegate, expansionStates;

#define HEIGHT_FOR_CELL 44.0

- (id)initWithFrame:(CGRect)frame dataSource:dataDelegate tableViewDelegate:tableDelegate {
    self = [super initWithFrame:frame style:UITableViewStylePlain];
    //self = [super initWithFrame:frame style:UITableViewStyleGrouped];
    if (self) {
        // Initialization code
        [self initialize];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        // Initialization code
        [self initialize];
    }
    return self;
}

/* not working. override animation for insert and delete for custom animation
- (void)insertRowsAtIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation
{
    for (NSIndexPath *indexPath in indexPaths)
    {
        UITableViewCell *cell = [self tableView:self cellForRowAtIndexPath:indexPath];
        [cell setFrame:CGRectMake(320, cell.frame.origin.y, cell.frame.size.width, cell.frame.size.height)];
        
        [UIView beginAnimations:NULL context:nil];
        [UIView setAnimationDuration:1];
        [cell setFrame:CGRectMake(0, cell.frame.origin.y, cell.frame.size.width, cell.frame.size.height)];
        [UIView commitAnimations];
    }
}
*/

- (void) initialize {
    [self setDataSource:self];
    [self setDelegate:self];
    self.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);

    // Trick to hide UITableView Empty Cell Separator Lines (stuff below last nonempty cell)
    UIView *footer = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableFooterView = footer;
}

- (id) getDataSourceDelegate {
    return dataSourceDelegate;
}

- (void) setDataSourceDelegate:(id) deleg {
    dataSourceDelegate = deleg;
    [self initExpansionStates];
}

- (void) initExpansionStates
{
    // all collapsed initially
    expansionStates = [[NSMutableArray alloc] initWithCapacity:[self.dataSourceDelegate numberOfParentCells]];
    for(int i = 0; i<[self.dataSourceDelegate numberOfParentCells]; i++) {
        [expansionStates addObject:@"NO"];
    }
}

- (void) reloadData
{
    [self setDataSourceDelegate:dataSourceDelegate];
    [super reloadData];
}

- (void) setFrame:(CGRect)frame
{
    [self setDataSourceDelegate:dataSourceDelegate];
    [super setFrame:frame];
}

- (void) expandForParentAtRow: (NSInteger) row {
    NSUInteger parentIndex = [self parentIndexForRow:row];
    
    if ([[self.expansionStates objectAtIndex:parentIndex] boolValue]) {
        return;
    }
    // update expansionStates so backing data is ready before calling insertRowsAtIndexPaths
    [self.expansionStates replaceObjectAtIndex:parentIndex withObject:@"YES"];

    [self insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:(row + 1) inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
}

- (void) collapseForParentAtRow: (NSInteger) row {
    NSUInteger parentIndex = [self parentIndexForRow:row];
    
    if (![[self.expansionStates objectAtIndex:parentIndex] boolValue]) {
        return;
    }
    // update expansionStates so backing data is ready before calling deleteRowsAtIndexPaths
    [self.expansionStates replaceObjectAtIndex:parentIndex withObject:@"NO"];
    
    [self deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:(row + 1) inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
}

- (void) animateParentCellIconExpand: (BOOL) expand forCell: (JKParentTableViewCell *) cell {
    if ([self.dataSourceDelegate respondsToSelector:@selector(shouldRotateIconForParentOnToggle)] &&
        ([self.dataSourceDelegate shouldRotateIconForParentOnToggle] == NO)) {
    } else {
        if (expand) {
            [cell rotateIconToExpanded];
        } else {
            [cell rotateIconToCollapsed];
        }
    }
}

- (NSUInteger) rowForParentIndex:(NSUInteger) parentIndex {
    NSUInteger row = 0;
    NSUInteger currentParentIndex = 0;
    
    if (parentIndex == 0) {
        return 0;
    }
    
    while (currentParentIndex < parentIndex) {
        BOOL expanded = [[self.expansionStates objectAtIndex:currentParentIndex] boolValue];
        if (expanded) {
            row++;
        }
        currentParentIndex++;
        row++;
    }
    return row;
}

- (NSUInteger) parentIndexForRow:(NSUInteger) row {
    NSUInteger parentIndex = -1;

    NSUInteger i = 0;
    
    while (i <= row) {
        parentIndex ++;
        i++;
        if ([[self.expansionStates objectAtIndex:parentIndex] boolValue]) {
            i++;
        }
    }
    //NSLog(@"parentIndexForRow row: %d parentIndex: %d", row, parentIndex);
    return parentIndex;
}

- (BOOL) isExpansionCell:(NSUInteger) row {
    if (row < 1) {
        return NO;
    }
    NSUInteger parentIndex = [self parentIndexForRow:row];
    NSUInteger parentIndex2 = [self parentIndexForRow:(row-1)];
    return (parentIndex == parentIndex2);
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // returns sum of parent cells and expanded cells
    NSInteger parentCount = [self.dataSourceDelegate numberOfParentCells];
    NSCountedSet * countedSet = [[NSCountedSet alloc] initWithArray:self.expansionStates];
    NSUInteger expandedParentCount = [countedSet countForObject:@"YES"];
    
    return parentCount + expandedParentCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier_Parent = @"CellReuseId_Parent";
    static NSString *CellIdentifier_MultiSelect = @"CellReuseId_MultiSelectExpand";
    static NSString *CellIdentifier_SingleSelect = @"CellReuseId_SingleSelectExpand";
    
    NSInteger row = indexPath.row;
    NSUInteger parentIndex = [self parentIndexForRow:row];
    BOOL isExpansionCell = [self isExpansionCell:row];
    
    if (isExpansionCell) {
        BOOL isMultiSelect = [self.tableViewDelegate shouldSupportMultipleSelectableChildrenAtParentIndex:parentIndex];
        if (isMultiSelect) {
            JKMultiSelectSubTableViewCell *cell = (JKMultiSelectSubTableViewCell *)[self dequeueReusableCellWithIdentifier:CellIdentifier_MultiSelect];
            if (cell == nil) {
                cell = [[JKMultiSelectSubTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_MultiSelect];
            } else {
                //NSLog(@"reusing existing JKMultiSelectSubTableViewCell");
            }
            
            if ([self.tableViewDelegate respondsToSelector:@selector(backgroundColor)]) {
                UIColor * bgColor = [self.tableViewDelegate backgroundColor];
                [cell setSubTableBackgroundColor:bgColor];
            }
            
            if ([self.tableViewDelegate respondsToSelector:@selector(foregroundColor)]) {
                UIColor * fgColor = [self.tableViewDelegate foregroundColor];
                [cell setSubTableForegroundColor:fgColor];
            }
            
            if ([self.tableViewDelegate respondsToSelector:@selector(selectionIndicatorIcon)]) {
                [cell setSelectionIndicatorImg:[self.tableViewDelegate selectionIndicatorIcon]];
            }
            
            //NSLog(@"cellForRowAtIndexPath MultiSelect parentIndex: %d", parentIndex);
            [cell setParentIndex:parentIndex];
            [cell setDelegate:self];
            [cell reload];
            return cell;
        } else {
            JKSingleSelectSubTableViewCell *cell = (JKSingleSelectSubTableViewCell *)[self dequeueReusableCellWithIdentifier:CellIdentifier_SingleSelect];
            if (cell == nil) {
                cell = [[JKSingleSelectSubTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_SingleSelect];
            } else {
                //NSLog(@"reusing existing JKSingleSelectSubTableViewCell");
            }
            
            if ([self.tableViewDelegate respondsToSelector:@selector(backgroundColor)]) {
                UIColor * bgColor = [self.tableViewDelegate backgroundColor];
                [cell setSubTableBackgroundColor:bgColor];
            }
            
            if ([self.tableViewDelegate respondsToSelector:@selector(foregroundColor)]) {
                UIColor * fgColor = [self.tableViewDelegate foregroundColor];
                [cell setSubTableForegroundColor:fgColor];
            }
            
            if ([self.tableViewDelegate respondsToSelector:@selector(selectionIndicatorIcon)]) {
                [cell setSelectionIndicatorImg:[self.tableViewDelegate selectionIndicatorIcon]];
            }
            
            if ([self.tableViewDelegate respondsToSelector:@selector(fontForChildren)]) {
                UIFont *font = [self.tableViewDelegate fontForChildren];
                [cell setSubTableFont:font];
            }
            
            //NSLog(@"cellForRowAtIndexPath SingleSelect parentIndex: %d", parentIndex);
            [cell setParentIndex:parentIndex];
            [cell setDelegate:self];
            [cell reload];
            return cell;
        }
    } else {
        // regular parent cell
        JKParentTableViewCell *cell = (JKParentTableViewCell *)[self dequeueReusableCellWithIdentifier:CellIdentifier_Parent];
        if (cell == nil) {
            cell = [[JKParentTableViewCell alloc] initWithReuseIdentifier:CellIdentifier_Parent];
        } else {
            //NSLog(@"reusing existing JKParentTableViewCell");
        }
        
        if ([self.tableViewDelegate respondsToSelector:@selector(backgroundColor)]) {
            UIColor * bgColor = [self.tableViewDelegate backgroundColor];
            [cell setCellBackgroundColor:bgColor];
        }
        
        if ([self.tableViewDelegate respondsToSelector:@selector(foregroundColor)]) {
            UIColor * fgColor = [self.tableViewDelegate foregroundColor];
            [cell setCellForegroundColor:fgColor];
        }
        
        if ([self.tableViewDelegate respondsToSelector:@selector(selectionIndicatorIcon)]) {
            [cell setSelectionIndicatorImg:[self.tableViewDelegate selectionIndicatorIcon]];
        }
        
        if ([self.tableViewDelegate respondsToSelector:@selector(fontForParents)]) {
            UIFont * font = [self.tableViewDelegate fontForParents];
            [cell.label setFont:font];
        }
        
        NSString * labelStr = [self.dataSourceDelegate labelForParentCellAtIndex:parentIndex];
        [[cell label] setText:labelStr];
        
        if ([self.dataSourceDelegate respondsToSelector:@selector(auxLabelForParentCellAtIndex:)]) {
            [[cell auxLabel] setText:[self.dataSourceDelegate auxLabelForParentCellAtIndex:parentIndex]];
        }
        
        if ([self.dataSourceDelegate respondsToSelector:@selector(iconForParentCellAtIndex:)]) {
            UIImage *icon = [self.dataSourceDelegate iconForParentCellAtIndex:parentIndex];
            [[cell iconImage] setImage:icon];
        }
        if ([self.dataSourceDelegate respondsToSelector:@selector(imageStyleForParentIndex:)]) {
            JKExpandTableViewCellImageStyle imageStyle = [self.dataSourceDelegate imageStyleForParentIndex:parentIndex];
            cell.imageStyle = imageStyle;
        }
        
        if ([self.dataSourceDelegate respondsToSelector:@selector(expansionIndicatorIconForParentCellAtIndex:)]) {
            UIImage *icon = [self.dataSourceDelegate expansionIndicatorIconForParentCellAtIndex:parentIndex];
            [[cell expansionIndicatorImage] setImage:icon];
        }
        
        [cell setParentIndex:parentIndex];
        [cell selectionIndicatorState:[self hasSelectedChild:parentIndex]];
        //[cell setupDisplay];
        
        return cell;
    }
}

#pragma mark - Table view delegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = indexPath.row;
    //NSLog(@"heightForRowAtIndexPath row: %d", row);
    // if cell is expanded, the cell height would be a multiple of the number of child cells
    BOOL isExpansionCell = [self isExpansionCell:row];
    if (isExpansionCell) {
        NSInteger parentIndex = [self parentIndexForRow:row];
        NSInteger numberOfChildren = [self.dataSourceDelegate numberOfChildCellsUnderParentIndex:parentIndex];
        return HEIGHT_FOR_CELL * numberOfChildren;
    } else {
        return HEIGHT_FOR_CELL;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // if parent , expand/collpase then notify delegate (always check respond to selector)
    UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    if ([selectedCell isKindOfClass:[JKParentTableViewCell class]]) {
        
        JKParentTableViewCell * pCell = (JKParentTableViewCell *) selectedCell;
        
        if ([[self.expansionStates objectAtIndex:[pCell parentIndex]] boolValue]) {
            [self collapseForParentAtRow:indexPath.row];
            [self animateParentCellIconExpand:NO forCell:pCell];  // TODO handle the case where there is no child.
        } else {
            [self expandForParentAtRow:indexPath.row];
            [self animateParentCellIconExpand:YES forCell:pCell];
        }
        
        if ([self.tableViewDelegate respondsToSelector:@selector(tableView:didSelectParentCellAtIndex:)]) {
            [self.tableViewDelegate tableView:tableView didSelectParentCellAtIndex:[pCell parentIndex]];
        }
        
    } else {
        // ignore clicks on child because the sub table should handle it.
    }
}

#pragma mark - JKMultiSelectSubTableViewCellDelegate
- (NSInteger) numberOfChildrenUnderParentIndex:(NSInteger)parentIndex {
    return [self.dataSourceDelegate numberOfChildCellsUnderParentIndex:parentIndex];
}

- (BOOL) isSelectedForChildIndex:(NSInteger)childIndex underParentIndex:(NSInteger)parentIndex {
    return [self.dataSourceDelegate shouldDisplaySelectedStateForCellAtChildIndex:childIndex withinParentCellIndex:parentIndex];
}

- (void) didSelectRowAtChildIndex:(NSInteger)childIndex
                         selected:(BOOL)isSwitchedOn
                 underParentIndex:(NSInteger)parentIndex {
    
    // check if at least one child is selected.  if yes, set the parent checkmark to indicate at least one chlid selected
    if (isSwitchedOn &&
        [self.tableViewDelegate respondsToSelector:@selector(tableView:didSelectCellAtChildIndex:withInParentCellIndex:)]) {
        [self.tableViewDelegate tableView:self didSelectCellAtChildIndex:childIndex withInParentCellIndex:parentIndex];
    }
    
    if (!isSwitchedOn &&
        [self.tableViewDelegate respondsToSelector:@selector(tableView:didDeselectCellAtChildIndex:withInParentCellIndex:)]) {
        [self.tableViewDelegate tableView:self didDeselectCellAtChildIndex:childIndex withInParentCellIndex:parentIndex];
    }
    
    NSIndexPath * indexPath = [NSIndexPath indexPathForRow:[self rowForParentIndex:parentIndex] inSection:0];
    UITableViewCell *selectedCell = [self cellForRowAtIndexPath:indexPath];
    if ([selectedCell isKindOfClass:[JKParentTableViewCell class]]) {
        JKParentTableViewCell * pCell = (JKParentTableViewCell *) selectedCell;
        [pCell selectionIndicatorState:[self hasSelectedChild:parentIndex]];
    }
}

- (NSString *) labelForChildIndex:(NSInteger)childIndex underParentIndex:(NSInteger)parentIndex {
    return [self.dataSourceDelegate labelForCellAtChildIndex:childIndex withinParentCellIndex:parentIndex];
}

- (NSString *) auxLabelForChildIndex:(NSInteger)childIndex underParentIndex:(NSInteger)parentIndex
{
    if (![self.dataSourceDelegate respondsToSelector:@selector(auxLabelForCellAtChildIndex:withinParentCellIndex:)]) {
        return nil;
    }
    
    return [self.dataSourceDelegate auxLabelForCellAtChildIndex:childIndex withinParentCellIndex:parentIndex];
}

- (JKExpandTableViewCellImageStyle) imageStyleForParentIndex:(NSInteger) parentIndex
{
    if (![self.dataSourceDelegate respondsToSelector:@selector(imageStyleForParentIndex:)]) {
        return JKExpandTableViewCellImageStyleSquare;
    }
    
    return [self.dataSourceDelegate imageStyleForParentIndex:parentIndex];
}

- (JKExpandTableViewCellImageStyle) imageStyleForChildIndex:(NSInteger) childIndex withinParentCellIndex:(NSInteger)parentIndex
{
    if (![self.dataSourceDelegate respondsToSelector:@selector(imageStyleForChildIndex:withinParentCellIndex:)]) {
        return JKExpandTableViewCellImageStyleSquare;
    }
    
    return [self.dataSourceDelegate imageStyleForChildIndex:childIndex withinParentCellIndex:parentIndex];
}

- (UIImage *) iconForChildIndex:(NSInteger)childIndex underParentIndex:(NSInteger)parentIndex {
    if ([self.dataSourceDelegate respondsToSelector:@selector(iconForCellAtChildIndex:withinParentCellIndex:)]) {
        return [self.dataSourceDelegate iconForCellAtChildIndex:childIndex withinParentCellIndex:parentIndex];
    } else {
        return nil;
    }
}

- (BOOL) hasSelectedChild:(NSUInteger) parentIndex {
    NSInteger numberOfChildren = [self.dataSourceDelegate numberOfChildCellsUnderParentIndex:parentIndex];
    BOOL result = NO;
    for (int i = 0; i < numberOfChildren ; i++) {
        if ([self.dataSourceDelegate shouldDisplaySelectedStateForCellAtChildIndex:i withinParentCellIndex:parentIndex]) {
            result = YES;
            break;
        }
    }
    return result;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([self.tableViewDelegate respondsToSelector:@selector(scrollViewDidScroll:)]) {
        [self.tableViewDelegate scrollViewDidScroll:scrollView];
    }
}
- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    if ([self.tableViewDelegate respondsToSelector:@selector(scrollViewDidZoom:)]) {
        [self.tableViewDelegate scrollViewDidZoom:scrollView];
    }
}

// called on start of dragging (may require some time and or distance to move)
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView;
{
    if ([self.tableViewDelegate respondsToSelector:@selector(scrollViewWillBeginDragging:)]) {
        [self.tableViewDelegate scrollViewWillBeginDragging:scrollView];
    }
}
// called on finger up if the user dragged. velocity is in points/millisecond. targetContentOffset may be changed to adjust where the scroll view comes to rest
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if ([self.tableViewDelegate respondsToSelector:@selector(scrollViewWillEndDragging:withVelocity:targetContentOffset:)]) {
        [self.tableViewDelegate scrollViewWillEndDragging:scrollView withVelocity:velocity targetContentOffset:targetContentOffset];
    }
}
// called on finger up if the user dragged. decelerate is true if it will continue moving afterwards
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;
{
    if ([self.tableViewDelegate respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)]) {
        [self.tableViewDelegate scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView;   // called on finger up as we are moving
{
    if ([self.tableViewDelegate respondsToSelector:@selector(scrollViewWillBeginDecelerating:)]) {
        [self.tableViewDelegate scrollViewWillBeginDecelerating:scrollView];
    }
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView;      // called when scroll view grinds to a halt
{
    if ([self.tableViewDelegate respondsToSelector:@selector(scrollViewDidEndDecelerating:)]) {
        [self.tableViewDelegate scrollViewDidEndDecelerating:scrollView];
    }
}


- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView; // called when setContentOffset/scrollRectVisible:animated: finishes. not called if not animating
{
    if ([self.tableViewDelegate respondsToSelector:@selector(scrollViewDidEndScrollingAnimation:)]) {
        [self.tableViewDelegate scrollViewDidEndScrollingAnimation:scrollView];
    }
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView;     // return a view that will be scaled. if delegate returns nil, nothing happens
{
    if ([self.tableViewDelegate respondsToSelector:@selector(viewForZoomingInScrollView:)]) {
        return [self.tableViewDelegate viewForZoomingInScrollView:scrollView];
    }
    
    return nil;
}
- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view
{
    if ([self.tableViewDelegate respondsToSelector:@selector(scrollViewWillBeginZooming:withView:)]) {
        [self.tableViewDelegate scrollViewWillBeginZooming:scrollView withView:view];
    }
}
- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale; // scale between minimum and maximum. called after any 'bounce' animations
{
    if ([self.tableViewDelegate respondsToSelector:@selector(scrollViewDidEndZooming:withView:atScale:)]) {
        [self.tableViewDelegate scrollViewDidEndZooming:scrollView withView:view atScale:scale];
    }
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView;   // return a yes if you want to scroll to the top. if not defined, assumes YES
{
    if ([self.tableViewDelegate respondsToSelector:@selector(scrollViewShouldScrollToTop:)]) {
        return [self.tableViewDelegate scrollViewShouldScrollToTop:scrollView];
    }
    
    return NO;
}
- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView;      // called when scrolling animation finished. may be called immediately if already at top
{
    if ([self.tableViewDelegate respondsToSelector:@selector(scrollViewDidScrollToTop:)]) {
        [self.tableViewDelegate scrollViewDidScrollToTop:scrollView];
    }
}



@end
