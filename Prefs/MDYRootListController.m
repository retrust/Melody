#include "MDYRootListController.h"
#import <Cephei/HBRespringController.h>
#import "../Tweak/Melody.h"
#import <spawn.h>

BOOL enabled = NO;

@implementation MDYRootListController

- (instancetype)init {
    self = [super init];

    if (self) {
        MDYAppearanceSettings *appearanceSettings = [[MDYAppearanceSettings alloc] init];
        self.hb_appearanceSettings = appearanceSettings;
        self.enableSwitch = [[UISwitch alloc] init];
        self.enableSwitch.onTintColor = [UIColor colorWithRed:1.00 green:0.96 blue:0.64 alpha:1.0];
        [self.enableSwitch addTarget:self action:@selector(toggleState) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem* switchy = [[UIBarButtonItem alloc] initWithCustomView: self.enableSwitch];
        self.navigationItem.rightBarButtonItem = switchy;

        self.navigationItem.titleView = [UIView new];
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,10,10)];
        self.titleLabel.font = [UIFont boldSystemFontOfSize:17];
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.titleLabel.text = @"1.2.3";
        self.titleLabel.textColor = [UIColor whiteColor];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.navigationItem.titleView addSubview:self.titleLabel];

        self.iconView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,10,10)];
        self.iconView.contentMode = UIViewContentModeScaleAspectFit;
        self.iconView.image = [UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/MelodyPrefs.bundle/icon@2x.png"];
        self.iconView.translatesAutoresizingMaskIntoConstraints = NO;
        self.iconView.alpha = 0.0;
        [self.navigationItem.titleView addSubview:self.iconView];

        [NSLayoutConstraint activateConstraints:@[
            [self.titleLabel.topAnchor constraintEqualToAnchor:self.navigationItem.titleView.topAnchor],
            [self.titleLabel.leadingAnchor constraintEqualToAnchor:self.navigationItem.titleView.leadingAnchor],
            [self.titleLabel.trailingAnchor constraintEqualToAnchor:self.navigationItem.titleView.trailingAnchor],
            [self.titleLabel.bottomAnchor constraintEqualToAnchor:self.navigationItem.titleView.bottomAnchor],
            [self.iconView.topAnchor constraintEqualToAnchor:self.navigationItem.titleView.topAnchor],
            [self.iconView.leadingAnchor constraintEqualToAnchor:self.navigationItem.titleView.leadingAnchor],
            [self.iconView.trailingAnchor constraintEqualToAnchor:self.navigationItem.titleView.trailingAnchor],
            [self.iconView.bottomAnchor constraintEqualToAnchor:self.navigationItem.titleView.bottomAnchor],
        ]];
    }

    return self;
}

-(NSArray *)specifiers {
	if (_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"Root" target:self] retain];
	}

	return _specifiers;
}

- (void)viewDidLoad {

	[super viewDidLoad];

    self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0,0,200,200)];
    self.headerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,200,200)];
    self.headerImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.headerImageView.image = [UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/MelodyPrefs.bundle/Banner.png"];
    self.headerImageView.translatesAutoresizingMaskIntoConstraints = NO;

    [self.headerView addSubview:self.headerImageView];
    [NSLayoutConstraint activateConstraints:@[
        [self.headerImageView.topAnchor constraintEqualToAnchor:self.headerView.topAnchor],
        [self.headerImageView.leadingAnchor constraintEqualToAnchor:self.headerView.leadingAnchor],
        [self.headerImageView.trailingAnchor constraintEqualToAnchor:self.headerView.trailingAnchor],
        [self.headerImageView.bottomAnchor constraintEqualToAnchor:self.headerView.bottomAnchor],
    ]];

    _table.tableHeaderView = self.headerView;

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    tableView.tableHeaderView = self.headerView;
    return [super tableView:tableView cellForRowAtIndexPath:indexPath];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    CGRect frame = self.table.bounds;
    frame.origin.y = -frame.size.height;

    self.navigationController.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.77 green:0.69 blue:0.98 alpha:1.0];
    [self.navigationController.navigationController.navigationBar setShadowImage: [UIImage new]];
    self.navigationController.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationController.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

    [self.navigationController.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];

    [self setEnableSwitchState];

}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [self.navigationController.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor blackColor]}];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offsetY = scrollView.contentOffset.y;

    if (offsetY > 200) {
        [UIView animateWithDuration:0.2 animations:^{
            self.iconView.alpha = 1.0;
            self.titleLabel.alpha = 0.0;
        }];
    } else {
        [UIView animateWithDuration:0.2 animations:^{
            self.iconView.alpha = 0.0;
            self.titleLabel.alpha = 1.0;
        }];
    }

    if (offsetY > 0) offsetY = 0;
    self.headerImageView.frame = CGRectMake(0, offsetY, self.headerView.frame.size.width, 200 - offsetY);
}

- (void)toggleState {

    self.enableSwitch.enabled = NO;

    HBPreferences *pfs = [[HBPreferences alloc] initWithIdentifier: @"sh.litten.melodypreferences"];
    
    if ([[pfs objectForKey:@"Enabled"] isEqual: @(NO)]) {
        enabled = YES;
        [pfs setBool:enabled forKey: @"Enabled"];
        [self respringUtil];
        
    } else if ([[pfs objectForKey:@"Enabled"] isEqual: @(YES)]) {
        enabled = NO;
        [pfs setBool:enabled forKey: @"Enabled"];
        [self respringUtil];

    }

}

- (void)setEnableSwitchState {

    NSString* path = [NSString stringWithFormat:@"/var/mobile/Library/Preferences/sh.litten.melodypreferences.plist"];
    NSMutableDictionary* dictionary = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    NSSet* allKeys = [NSSet setWithArray:[dictionary allKeys]];
    
    if (!([allKeys containsObject:@"Enabled"])) {
        [self.enableSwitch setOn:NO animated: YES];

    } else if ([[dictionary objectForKey:@"Enabled"] isEqual: @(YES)]) {
        [self.enableSwitch setOn:YES animated: YES];

    } else if ([[dictionary objectForKey:@"Enabled"] isEqual: @(NO)]) {
        [self.enableSwitch setOn:NO animated: YES];
        
    }

}

- (void)resetPrompt {

    UIAlertController *resetAlert = [UIAlertController alertControllerWithTitle:@"Melody"
	message:@"Do You Really Want To Reset Your Preferences?"
	preferredStyle:UIAlertControllerStyleActionSheet];
	
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"Yep" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action) {
			
        [self resetPreferences];

	}];

	UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Nope" style:UIAlertActionStyleCancel handler:nil];

	[resetAlert addAction:confirmAction];
	[resetAlert addAction:cancelAction];

	[self presentViewController:resetAlert animated:YES completion:nil];

}

- (void)resetPreferences {

    HBPreferences *pfs = [[HBPreferences alloc] initWithIdentifier: @"sh.litten.melodypreferences"];
    for (NSString *key in [pfs dictionaryRepresentation]) {
        [pfs removeObjectForKey:key];

    }
    
    [self.enableSwitch setOn:NO animated: YES];
    [self respringUtil];

}

- (void)respringUtil {

    pid_t pid;
    const char *args[] = {"killall", "backboardd", NULL};

    [HBRespringController respringAndReturnTo:[NSURL URLWithString:@"prefs:root=Melody"]];

    posix_spawn(&pid, "/usr/bin/killall", NULL, NULL, (char *const *)args, NULL);

}

@end