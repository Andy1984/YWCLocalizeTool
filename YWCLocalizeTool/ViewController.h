//
//  ViewController.h
//  YWCLocalizeTool
//
//  Created by YangWeicheng on 8/29/16.
//  Copyright © 2016 YangWeicheng. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ViewController : NSViewController
@property (unsafe_unretained) IBOutlet NSTextView *inputTextView;
@property (unsafe_unretained) IBOutlet NSTextView *outputTextView;
@property (weak) IBOutlet NSButton *translateButton;
@property (weak) IBOutlet NSTextField *infoLabel;
@property (weak) IBOutlet NSTextFieldCell *infoTextLabel;

@end

