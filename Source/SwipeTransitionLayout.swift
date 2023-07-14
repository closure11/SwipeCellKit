//
//  SwipeTransitionLayout.swift
//
//  Created by Jeremy Koch
//  Copyright © 2017 Jeremy Koch. All rights reserved.
//

import UIKit

// MARK: - Layout Protocol

protocol SwipeTransitionLayout {
    func container(view: UIView, didChangeVisibleWidthWithContext context: ActionsViewLayoutContext)
    func layout(view: UIView, atIndex index: Int, with context: ActionsViewLayoutContext)
    func visibleWidthsForViews(with context: ActionsViewLayoutContext) -> [CGFloat]
}

// MARK: - Layout Context 

struct ActionsViewLayoutContext {
    let numberOfActions: Int
    let orientation: SwipeActionsOrientation
    let contentSize: CGSize
    let visibleWidth: CGFloat
    let buttonWidths: [CGFloat]
    
    init(numberOfActions: Int, orientation: SwipeActionsOrientation, contentSize: CGSize = .zero, visibleWidth: CGFloat = 0, buttonWidths: [CGFloat]) {
        self.numberOfActions = numberOfActions
        self.orientation = orientation
        self.contentSize = contentSize
        self.visibleWidth = visibleWidth
        self.buttonWidths = buttonWidths
    }
    
    static func newContext(for actionsView: SwipeActionsView) -> ActionsViewLayoutContext {
        return ActionsViewLayoutContext(
            numberOfActions: actionsView.actions.count,
            orientation: actionsView.orientation,
            contentSize: actionsView.contentSize,
            visibleWidth: actionsView.visibleWidth,
            buttonWidths: actionsView.buttonWidths
        )
    }
}

// MARK: - Supported Layout Implementations 

class BorderTransitionLayout: SwipeTransitionLayout {
    func container(view: UIView, didChangeVisibleWidthWithContext context: ActionsViewLayoutContext) {
    }
    
    func layout(view: UIView, atIndex index: Int, with context: ActionsViewLayoutContext) {
        let diff = context.visibleWidth - context.contentSize.width
        let totalWidth = context.buttonWidths.reduce(0, +)
        if totalWidth > 0 {
            view.frame.origin.x = context.buttonWidths.prefix(index).reduce(0) { total, next in
                total + ((next / totalWidth) * context.contentSize.width + diff) * context.orientation.scale
            }
        }
    }
    
    func visibleWidthsForViews(with context: ActionsViewLayoutContext) -> [CGFloat] {
        let diff = context.visibleWidth - context.contentSize.width
        let totalWidth = context.buttonWidths.reduce(0, +)

        return context.buttonWidths.map {
            totalWidth > 0 ? ($0 / totalWidth) * context.contentSize.width + diff : 0
        }
    }
}

class DragTransitionLayout: SwipeTransitionLayout {
    func container(view: UIView, didChangeVisibleWidthWithContext context: ActionsViewLayoutContext) {
        view.bounds.origin.x = (context.contentSize.width - context.visibleWidth) * context.orientation.scale
    }
    
    func layout(view: UIView, atIndex index: Int, with context: ActionsViewLayoutContext) {
        view.frame.origin.x = context.buttonWidths.prefix(index).reduce(0, +) * context.orientation.scale
    }
    
    func visibleWidthsForViews(with context: ActionsViewLayoutContext) -> [CGFloat] {
        return (0..<context.numberOfActions).map {
            max(0, min(context.buttonWidths[$0], context.visibleWidth - context.buttonWidths.prefix($0).reduce(0, +)))
        }
    }
}

class RevealTransitionLayout: DragTransitionLayout {
    override func container(view: UIView, didChangeVisibleWidthWithContext context: ActionsViewLayoutContext) {
        let width = context.buttonWidths.reduce(0, +)
        view.bounds.origin.x = (width - context.visibleWidth) * context.orientation.scale
    }
    
    override func visibleWidthsForViews(with context: ActionsViewLayoutContext) -> [CGFloat] {
        return super.visibleWidthsForViews(with: context)
            .reversed()
    }
}
