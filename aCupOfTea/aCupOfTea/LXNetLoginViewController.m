//
//  LXNetLoginViewController.m
//  aCupOfTea
//
//  Created by mwsn on 14-12-20.
//  Copyright (c) 2014年 Sangoly. All rights reserved.
//

#import "LXNetLoginViewController.h"
#import "LXUtil.h"

#define MARGIN_LEFT_RIGHT 30.0f
#define MARGIN_TOP 70.0f
#define PADDING_TOP 150.0f
#define TEXTFIELD_LABEL_HEIGHT 30.0f
#define LABEL_WIDTH 60.0f
#define SWITCH_WIDTH 70.0f

@interface LXNetLoginViewController ()
{
    NSString *username;
    NSString *passwd;
    BOOL forceLogin;
    
    // UI elements
    UILabel *usernameLable;
    UILabel *passwdLable;
    UILabel *forceLoginLabel;
    UITextField *usernameField;
    UITextField *passwdField;
    UISwitch *forceLoginSwitch;
    UIButton *forgetUser;
    
    // Bar button item
    UIBarButtonItem *doneNaviBarButton;
}
@end

@implementation LXNetLoginViewController

- (id)init {
    self = [super init];
    if (self) {
        // Init the username password and login flag
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.tabBarController.tabBar.hidden = YES;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL wzardComplete = [defaults boolForKey:@"zwardComplete"];
    if (!wzardComplete) {
        UIView *barView = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.bounds.size.width, 70.0f)];
        barView.backgroundColor = [UIColor brownColor];
        UIButton *storeButton = [[UIButton alloc] initWithFrame:CGRectMake(250.0f, 30.0f, 85.0f, 30.0f)];
        [storeButton setTitle:@"保存" forState:UIControlStateNormal];
        [storeButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [storeButton setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
        [storeButton addTarget:self action:@selector(storeButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
        [barView addSubview:storeButton];
        [self.view addSubview:barView];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.tabBarController.tabBar.hidden = NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    username = [defaults stringForKey:@"username"];
    passwd = [defaults stringForKey:@"passwd"];
    forceLogin = [defaults boolForKey:@"force_login"];
    self.title = @"设置";
    self.view.backgroundColor = [UIColor grayColor];
    [self initSubViews];
    
    // Add store UIBarButtonItem
    doneNaviBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(storeButtonClicked:)];
    self.navigationItem.rightBarButtonItem = doneNaviBarButton;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - self define methods

- (void)initSubViews {
    
    // Add username label
    usernameLable = [[UILabel alloc] initWithFrame:CGRectMake(MARGIN_LEFT_RIGHT, PADDING_TOP, LABEL_WIDTH, TEXTFIELD_LABEL_HEIGHT)];
    usernameLable.text = @"用户名:";
    usernameLable.textColor = [UIColor blueColor];
    usernameLable.backgroundColor = [UIColor clearColor];
    [self.view addSubview:usernameLable];
    
    // Add username field
    usernameField = [[UITextField alloc] initWithFrame:CGRectMake(MARGIN_LEFT_RIGHT+usernameLable.bounds.size.width, PADDING_TOP, self.view.bounds.size.width-MARGIN_LEFT_RIGHT*2-usernameLable.bounds.size.width, TEXTFIELD_LABEL_HEIGHT)];
    usernameField.borderStyle = UITextBorderStyleRoundedRect;
    if (username) {
        usernameField.text = username;
    } else {
        usernameField.placeholder = @"用户名";
    }
    usernameField.autocorrectionType = UITextAutocorrectionTypeNo;
    usernameField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    usernameField.returnKeyType = UIReturnKeyDone;
    // Make the keyboard only show numbers
    usernameField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    // Make the clear 'x' symbol
    usernameField.clearButtonMode = UITextFieldViewModeWhileEditing;
    // 1 refers to username field
    usernameField.tag = 1;
    usernameField.delegate = self;
    [self.view addSubview:usernameField];
    
    // Add password label
    passwdLable = [[UILabel alloc] initWithFrame:CGRectMake(MARGIN_LEFT_RIGHT, PADDING_TOP+MARGIN_TOP, LABEL_WIDTH, TEXTFIELD_LABEL_HEIGHT)];
    passwdLable.text = @"密    码:";
    passwdLable.textColor = [UIColor blueColor];
    passwdLable.backgroundColor = [UIColor clearColor];
    [self.view addSubview:passwdLable];
    
    // Add password field
    passwdField = [[UITextField alloc] initWithFrame:CGRectMake(MARGIN_LEFT_RIGHT+passwdLable.bounds.size.width, PADDING_TOP+MARGIN_TOP, self.view.bounds.size.width-MARGIN_LEFT_RIGHT*2-passwdLable.bounds.size.width, TEXTFIELD_LABEL_HEIGHT)];
    passwdField.borderStyle = UITextBorderStyleRoundedRect;
    if (passwd) {
        passwdField.text = passwd;
    } else {
        passwdField.placeholder = @"密码";
    }
    passwdField.secureTextEntry = YES;
    passwdField.autocorrectionType = UITextAutocorrectionTypeNo;
    passwdField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    passwdField.returnKeyType = UIReturnKeyDone;
    passwdField.clearButtonMode = UITextFieldViewModeWhileEditing;
    passwdField.tag = 2;
    passwdField.delegate = self;
    [self.view addSubview:passwdField];
    
    // Add switch label
    forceLoginLabel = [[UILabel alloc] initWithFrame:CGRectMake(MARGIN_LEFT_RIGHT, PADDING_TOP+MARGIN_TOP*2, LABEL_WIDTH, TEXTFIELD_LABEL_HEIGHT)];
    forceLoginLabel.text = @"强    制:";
    forceLoginLabel.textColor = [UIColor blueColor];
    forceLoginLabel.backgroundColor = [UIColor clearColor];
    [self.view addSubview:forceLoginLabel];
    
    // Add switch
    forceLoginSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(MARGIN_LEFT_RIGHT+forceLoginLabel.bounds.size.width, PADDING_TOP+MARGIN_TOP*2, SWITCH_WIDTH, TEXTFIELD_LABEL_HEIGHT)];
    [forceLoginSwitch setOn:forceLogin];
    [self.view addSubview:forceLoginSwitch];
    
    // Add forget button
    forgetUser = [[UIButton alloc] initWithFrame:CGRectMake(MARGIN_LEFT_RIGHT*5, PADDING_TOP+MARGIN_TOP*2, LABEL_WIDTH*2, TEXTFIELD_LABEL_HEIGHT)];
    [forgetUser setTitle:@"忘记用户" forState:UIControlStateNormal];
    [forgetUser setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [forgetUser setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
    [forgetUser addTarget:self action:@selector(doForgetUser:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:forgetUser];
}

- (void)doForgetUser:(UIButton *) sender {
    // Update local vars
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"警告" message:@"确定要遗忘当前用户信息吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alert show];
}

- (void)forceLoginStatusChange:(UISwitch *) sender {
    NSLog(@"sss");
}

- (void)storeButtonDidClicked:(UIButton *)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    username = usernameField.text;
    passwd = passwdField.text;
    forceLogin = [forceLoginSwitch isOn];
    if ([LXUtil isBlankString:username] || [LXUtil isBlankString:passwd]) {
        UIAlertView *invalidInfo = [[UIAlertView alloc] initWithTitle:@"不合法信息" message:@"用户名与密码均不能为空" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [invalidInfo show];
    } else {
        // Store in user dict
        [defaults setValue:username forKey:@"username"];
        [defaults setValue:passwd forKey:@"passwd"];
        [defaults setBool:forceLogin forKey:@"force_login"];
        [defaults setBool:YES forKey:@"zwardComplete"];
        [defaults synchronize];
        [self.navigationController popViewControllerAnimated:YES];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)storeButtonClicked:(UIBarButtonItem *) sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    username = usernameField.text;
    passwd = passwdField.text;
    forceLogin = [forceLoginSwitch isOn];
    if ([LXUtil isBlankString:username] || [LXUtil isBlankString:passwd]) {
        UIAlertView *invalidInfo = [[UIAlertView alloc] initWithTitle:@"不合法信息" message:@"用户名与密码均不能为空" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [invalidInfo show];
    } else {
        // Store in user dict
        [defaults setValue:username forKey:@"username"];
        [defaults setValue:passwd forKey:@"passwd"];
        [defaults setBool:forceLogin forKey:@"force_login"];
        [defaults synchronize];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != alertView.cancelButtonIndex) {
        username = nil;
        passwd = nil;
        forceLogin = NO;
        
        // Update user dict
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:username forKey:@"username"];
        [defaults setObject:passwd forKey:@"passwd"];
        [defaults setBool:forceLogin forKey:@"force_login"];
        [defaults synchronize];
        
        // Update ui elements
        usernameField.text = nil;
        passwdField.text = nil;
        [forceLoginSwitch setOn:NO];
    }
}

@end
