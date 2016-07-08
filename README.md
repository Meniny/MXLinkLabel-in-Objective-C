# MXLinkLabel-in-Objective-C

`MXLinkLabel` is an easy-to-use view to display markup text.

## Installation with CocoaPods

```
pod 'MXLinkLabel'
```

## Usage

```
[[self linkLabel] setMarkupText:@"<h1>MXLinkLabel</h1>This is a <a href=\"http://www.meniny.cn/\">sample link</a>."];
[[self linkLabel] setLinkTapHandler:^(NSURL * _Nullable url) {
    if (url != nil) {
        [[UIApplication sharedApplication] openURL:url];
    }
}];
```
