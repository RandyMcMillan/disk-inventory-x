//
//  GeneralPrefPage.m
//  Disk Inventory X
//
//  Created by Tjark Derlien on 27.11.04.
//
//  Copyright (C) 2004 Tjark Derlien.
//  
//  This program is free software; you can redistribute it and/or
//  modify it under the terms of the GNU General Public License
//  as published by the Free Software Foundation; either version 3
//  of the License, or any later version.

//

#import "GeneralPrefPage.h"

@implementation GeneralPrefPage

- (void)awakeFromNib
{
    [super awakeFromNib];

    NSView *controlBox = [self controlBox];
    if (controlBox == nil)
        return;

    NSButton *skipGitCheckbox = [[[NSButton alloc] initWithFrame:NSZeroRect] autorelease];
    [skipGitCheckbox setButtonType:NSSwitchButton];
    [skipGitCheckbox setTitle:NSLocalizedString(@"Skip .git folders", @"Preference to omit .git directories from scans")];
    [skipGitCheckbox bind:NSValueBinding toObject:self withKeyPath:@"values.SkipGitFolders" options:nil];
    [skipGitCheckbox sizeToFit];
    [skipGitCheckbox setFrameOrigin:NSMakePoint(12.0, 12.0)];
    [skipGitCheckbox setAutoresizingMask:NSViewMinYMargin | NSViewMaxXMargin];

    NSRect controlBoxFrame = [controlBox frame];
    CGFloat requiredHeight = NSMaxY([skipGitCheckbox frame]) + 12.0;
    if (controlBoxFrame.size.height < requiredHeight) {
        controlBoxFrame.size.height = requiredHeight;
        [controlBox setFrame:controlBoxFrame];
    }

    [controlBox addSubview:skipGitCheckbox];
}

@end
