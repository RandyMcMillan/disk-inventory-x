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

- (NSButton *)_checkboxWithTitle:(NSString *)title bindingKey:(NSString *)bindingKey
{
    NSButton *checkbox = [[[NSButton alloc] initWithFrame:NSZeroRect] autorelease];
    [checkbox setButtonType:NSSwitchButton];
    [checkbox setTitle:title];
    [checkbox bind:NSValueBinding toObject:self withKeyPath:bindingKey options:nil];
    [checkbox sizeToFit];
    [checkbox setAutoresizingMask:NSViewMaxYMargin | NSViewMinXMargin];
    return checkbox;
}

- (void)awakeFromNib
{
    [super awakeFromNib];

    NSView *controlBox = [self controlBox];
    if (controlBox == nil)
        return;

    NSArray *checkboxes = @[
        [self _checkboxWithTitle:NSLocalizedString(@"Skip .git folders", @"Preference to omit .git directories from scans") bindingKey:@"values.SkipGitFolders"],
        [self _checkboxWithTitle:NSLocalizedString(@"Skip .build folders", @"Preference to omit .build directories from scans") bindingKey:@"values.SkipDotBuildFolders"],
        [self _checkboxWithTitle:NSLocalizedString(@"Skip .swiftpm folders", @"Preference to omit .swiftpm directories from scans") bindingKey:@"values.SkipSwiftPMFolders"],
        [self _checkboxWithTitle:NSLocalizedString(@"Skip node_modules folders", @"Preference to omit node_modules directories from scans") bindingKey:@"values.SkipNodeModulesFolders"],
        [self _checkboxWithTitle:NSLocalizedString(@"Skip build folders", @"Preference to omit build directories from scans") bindingKey:@"values.SkipBuildFolders"],
        [self _checkboxWithTitle:NSLocalizedString(@"Skip DerivedData folders", @"Preference to omit DerivedData directories from scans") bindingKey:@"values.SkipDerivedDataFolders"],
        [self _checkboxWithTitle:NSLocalizedString(@"Skip SourcePackages folders", @"Preference to omit SourcePackages directories from scans") bindingKey:@"values.SkipSourcePackagesFolders"],
    ];

    NSRect controlBoxFrame = [controlBox frame];
    CGFloat checkboxHeight = 18.0;
    CGFloat spacing = 8.0;
    CGFloat margin = 12.0;
    CGFloat columnWidth = 220.0;
    CGFloat y = NSMaxY(controlBoxFrame) - margin - checkboxHeight;

    for (NSButton *checkbox in checkboxes) {
        NSRect frame = [checkbox frame];
        frame.origin.x = margin;
        frame.origin.y = y;
        frame.size.width = columnWidth;
        frame.size.height = checkboxHeight;
        [checkbox setFrame:frame];
        [controlBox addSubview:checkbox];
        y -= checkboxHeight + spacing;
    }
}

@end
