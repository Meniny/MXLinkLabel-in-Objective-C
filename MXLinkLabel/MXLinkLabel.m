//
//  MXLinkLabel.m
//  MXLineLabel
//
//  Created by Meniny on 16/7/8.
//  Copyright © 2016年 Meniny. All rights reserved.
//

#import "MXLinkLabel.h"

static CGFloat HIGHLIGHT_LINK_CORNER_RADIUS = 3.000000000000;

@interface MXLinkLabel () {
    UIColor *_HIGHLIGHT_LINK_FILL_COLOR;
}
@property (strong, nonatomic, readonly) UIColor * _Nonnull HIGHLIGHT_LINK_FILL_COLOR;
@property (strong, nonatomic) NSLayoutManager * _Nonnull layoutManager;
@property (strong, nonatomic) NSTextContainer * _Nonnull textContainer;
@property (strong, nonatomic) NSTextStorage * _Nullable textStorage;
@property (strong, nonatomic) CAShapeLayer * _Nonnull linkHighlightLayer;
@property (strong, nonatomic) NSURL * _Nullable highlightedLink;
@end

@implementation MXLinkLabel

#pragma mark - Lazy

- (UIColor * _Nonnull)HIGHLIGHT_LINK_FILL_COLOR {
    if (_HIGHLIGHT_LINK_FILL_COLOR == nil) {
        _HIGHLIGHT_LINK_FILL_COLOR = [UIColor colorWithWhite:0 alpha:0.7];
    }
    return _HIGHLIGHT_LINK_FILL_COLOR;
}

- (NSLayoutManager *)layoutManager {
    if (_layoutManager == nil) {
        _layoutManager = [NSLayoutManager new];
    }
    return _layoutManager;
}

- (NSTextContainer *)textContainer {
    if (_textContainer == nil) {
        _textContainer = [NSTextContainer new];
    }
    return _textContainer;
}

- (NSTextStorage *)textStorage {
    if (_textStorage == nil) {
        _textStorage = [NSTextStorage new];
    }
    return _textStorage;
}

- (CAShapeLayer *)linkHighlightLayer {
    if (_linkHighlightLayer == nil) {
        _linkHighlightLayer = [CAShapeLayer new];
    }
    return _linkHighlightLayer;
}

#pragma mark - Initializers

- (void)setup {
//    [[self textStorage] setWidthTracksTextView:YES];
    [[self layoutManager] addTextContainer:[self textContainer]];
    [[self linkHighlightLayer] setFillColor:[[self HIGHLIGHT_LINK_FILL_COLOR] CGColor]];
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    if (self) {
        [self setup];
    }
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

#pragma mark - IBInspectable Properties

- (void)setMarkupText:(NSString *)markupText {
    if (markupText != nil) {
        _markupText = [markupText copy];
        NSData *data = [_markupText dataUsingEncoding:NSUnicodeStringEncoding];
        NSTextStorage *textStorage = [[NSTextStorage alloc] initWithData:data options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType} documentAttributes:nil error:nil];
        [self setAttributedText:textStorage];
    } else {
        _markupText = nil;
    }
}

- (void)setAttributedText:(NSAttributedString *)attributedText {
    _attributedText = attributedText;
    if (_attributedText != nil) {
        [self setTextStorage:[[NSTextStorage alloc] initWithAttributedString:_attributedText]];
    } else {
        [self setTextStorage:nil];
    }
    [[self layoutManager] setTextStorage:[self textStorage]];
}

- (CGFloat)lineFragmentPadding {
    return [[self textContainer] lineFragmentPadding];
}

- (void)setLineFragmentPadding:(CGFloat)lineFragmentPadding {
    [[self textContainer] setLineFragmentPadding:lineFragmentPadding];
}

- (NSInteger)maximumNumberOfLines {
    return [[self textContainer] maximumNumberOfLines];
}

- (void)setMaximumNumberOfLines:(NSInteger)maximumNumberOfLines {
    [[self textContainer] setMaximumNumberOfLines:maximumNumberOfLines];
    [[self layoutManager] textContainerChangedGeometry:[self textContainer]];
}

#pragma mark - Override

- (void)layoutSubviews {
    [super layoutSubviews];
    if ([[self textContainer] size].width != [self bounds].size.width) {
        [self textContainer].size = CGSizeMake([self bounds].size.width, CGFLOAT_MAX);
        [[self layoutManager] textContainerChangedGeometry:[self textContainer]];
        [self invalidateIntrinsicContentSize];
    }
}

- (CGSize)intrinsicContentSize {
    [[self layoutManager] ensureLayoutForTextContainer:[self textContainer]];
    NSRange glyphRange = [[self layoutManager] glyphRangeForTextContainer:[self textContainer]];
    CGRect boundingRect = [[self layoutManager] boundingRectForGlyphRange:glyphRange inTextContainer:[self textContainer]];
    return CGSizeMake(boundingRect.size.width, floor(boundingRect.size.height));
}

- (void)drawRect:(CGRect)rect {
    NSRange glyphRange = [[self layoutManager] glyphRangeForTextContainer:[self textContainer]];
    [[self layoutManager] drawGlyphsForGlyphRange:glyphRange atPoint:CGPointZero];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if ([self textContainer] == nil) {
        return;
    }
    
    NSUInteger glyphIndex = [[self layoutManager] glyphIndexForPoint:[[touches anyObject] locationInView:self] inTextContainer:[self textContainer]];
    NSRange effectiveRange = NSMakeRange(NSNotFound, 0);
    NSDictionary<NSString *, id> *attributes = [[self textStorage] attributesAtIndex:glyphIndex effectiveRange:&effectiveRange];
    
    if (attributes != nil) {
        id linkAttribute = attributes[NSLinkAttributeName];
        
        if (linkAttribute != nil) {
            
            if ([linkAttribute isKindOfClass:[NSURL class]]) {
                [self setHighlightedLink:linkAttribute];
                
            } else if ([linkAttribute isKindOfClass:[NSString class]]) {
                [self setHighlightedLink:[NSURL URLWithString:linkAttribute]];
                
            } else {
                return;
            }
            
            NSRange linkGlyphRange = [[self layoutManager] glyphRangeForCharacterRange:effectiveRange actualCharacterRange:nil];
            UIBezierPath *path = [UIBezierPath bezierPath];

            [[self layoutManager] enumerateEnclosingRectsForGlyphRange:linkGlyphRange
                                              withinSelectedGlyphRange:NSMakeRange(NSNotFound, 0)
                                                       inTextContainer:[self textContainer]
                                                            usingBlock:^(CGRect rect, BOOL * _Nonnull stop) {
                                                                
                                                                CGRect newRect = rect;
                                                                rect.size.height += HIGHLIGHT_LINK_CORNER_RADIUS;
                                                                [path appendPath:[UIBezierPath bezierPathWithRoundedRect:newRect cornerRadius:HIGHLIGHT_LINK_CORNER_RADIUS]];
            }];
            CGRect bounds = [path bounds];
            [path applyTransform:CGAffineTransformMakeTranslation(-bounds.origin.x, -bounds.origin.y)];
            [[self linkHighlightLayer] setPath:[path CGPath]];
//            showLinkHighlight(bounds);
        }
    }
    
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if ([touches anyObject] == nil) {
        return;
    }
    if ([self highlightedLink] != nil) {
        CGPoint pt = [[self linkHighlightLayer] convertPoint:[[touches anyObject] locationInView:self] fromLayer:[self layer]];
        if (CGPathContainsPoint([[self linkHighlightLayer] path], nil, pt, NO)) {
            if ([[self linkHighlightLayer] isHidden]) {
                [CATransaction begin];
                [CATransaction setDisableActions:YES];
                [[self linkHighlightLayer] setHidden:NO];
                [CATransaction commit];
            }
        } else {
            if (![[self linkHighlightLayer] isHidden]) {
                [CATransaction begin];
                [CATransaction setDisableActions:YES];
                [[self linkHighlightLayer] setHidden:YES];
                [CATransaction commit];
            }
        }
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if ([self highlightedLink] != nil) {
        if (![[self linkHighlightLayer] isHidden]) {
            if (self.linkTapHandler != nil) {
                self.linkTapHandler([[self highlightedLink] copy]);
            }
        }
        [self resetLinkHighlight];
    }
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self resetLinkHighlight];
}

#pragma mark - Utilities

- (void)showLinkHighlight:(CGRect)boundingRect {
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    [[self linkHighlightLayer] setFrame:boundingRect];
    [[self linkHighlightLayer] setHidden:NO];
    [[self layer] addSublayer:[self linkHighlightLayer]];
    [CATransaction commit];
}

- (void)resetLinkHighlight {
    [[self linkHighlightLayer] removeFromSuperlayer];
    [self setHighlightedLink:nil];
}

@end
