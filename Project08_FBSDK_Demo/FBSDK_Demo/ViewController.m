//
//  ViewController.m
//  FBSDK_Demo
//
//  Created by Kuan-Wei on 2016/8/17.
//  Copyright © 2016年 TaiwanMobile. All rights reserved.
//

#import "ViewController.h"
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>

@interface ViewController () <FBSDKLoginButtonDelegate>

@property (nonatomic) FBSDKLoginManager *fbLoginManager;
@property (nonatomic) FBSDKLoginButton *loginButton;//FB的Login button

@property (nonatomic) UIButton *myFBLoginButton;//客製化的login button
@property (nonatomic) UIButton *myFBLogoutButton;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *fbUsername;
@property (weak, nonatomic) IBOutlet UILabel *fbEmail;
@property (weak, nonatomic) IBOutlet UILabel *fbUserID;
@property (weak, nonatomic) IBOutlet UILabel *gender;
@property (weak, nonatomic) IBOutlet UILabel *birthday;


@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.bounds), 1000);
    
    self.loginButton = [[FBSDKLoginButton alloc] init];
    self.loginButton.delegate = self;
    self.loginButton.center = self.view.center;
    [self.view addSubview:self.loginButton];
    
    //將會出現提醒使用者此App將會取得使用者的profile, email等資料
    self.loginButton.readPermissions = @[@"public_profile", @"email", @"user_friends"];
    
    //Like Button
    FBSDKLikeControl *likeButton = [[FBSDKLikeControl alloc] init];
    likeButton.frame = CGRectMake(CGRectGetMidX(self.view.frame) - 90, CGRectGetMidY(self.view.frame) + 130, 180, 40);
    likeButton.objectID = @"https://www.facebook.com/FacebookDevelopers";
    [self.view addSubview:likeButton];
    
    //Share Button
    FBSDKShareButton *shareButton = [[FBSDKShareButton alloc] init];
    shareButton.frame = CGRectMake(CGRectGetMidX(self.view.frame) - 90, CGRectGetMidY(self.view.frame) + 200, 180, 40);
    FBSDKShareLinkContent *shareContent = [[FBSDKShareLinkContent alloc] init];
    shareContent.contentURL = [NSURL URLWithString:@"https://developers.facebook.com"];
    //以下Custom參數只有在非使用FBSDKShareLinkContent時才能使用，否則會被FBSDK自己從網站Parse的內容蓋過去
    shareContent.contentTitle = @"Custom title";
    shareContent.contentDescription = @"Custom description";
    shareContent.imageURL = [NSURL URLWithString:@"http://www.example.com/images/xxxxxx.jpg"];
    shareContent.hashtag = [FBSDKHashtag hashtagWithString:@"#hashtaghere"];
    shareContent.quote = @"Learn quick and simple ways for people to share content from your app or website to Facebook.";
    shareButton.shareContent = shareContent;
    [self.view addSubview:shareButton];
    
    //Send Button
    FBSDKSendButton *sendButton = [[FBSDKSendButton alloc] init];
    sendButton.frame = CGRectMake(CGRectGetMidX(self.view.frame) - 90, CGRectGetMidY(self.view.frame) + 250, 180, 40);
    FBSDKShareLinkContent *sendContent = [[FBSDKShareLinkContent alloc] init];
    sendContent.contentTitle = @"Hello world!";
    sendButton.shareContent = sendContent;
    if (sendButton.isHidden) {
        NSLog(@"Is hidden");
    } else {
        [self.view addSubview:sendButton];
    }
//    [FBSDKMessageDialog showWithContent:sendContent delegate:nil];
    
    [self createMyLoginButton];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //如果曾經用FB登入過，都沒有登出，用此方法可以直接叫出登入者資訊
    if ([FBSDKAccessToken currentAccessToken])
    {
        [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:nil]
         startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
             
             if (!error)
             {
                 NSLog(@"fetched user:%@", result);
                 
                 //取得同樣授權此App的Facebook朋友名單
                 FBSDKGraphRequest *friendsRequest = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me/friends" parameters:nil HTTPMethod:@"GET"];
                 [friendsRequest startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                     
                     NSDictionary *friendSummaryDictionary = [result objectForKey:@"summary"];
                     NSNumber *totalFirendNumber = [friendSummaryDictionary objectForKey:@"total_count"];
                     NSLog(@"totalFirendNumber = %@", totalFirendNumber);//朋友總數
                     
                     NSArray *firendsArray = [result objectForKey:@"data"];//朋友名單
                     NSLog(@"firendsArray = %@", firendsArray);
                 }];
             }
             else
             {
                 NSLog(@"error = %@", error.localizedDescription);
             }
         }];
    }
}

- (void)createMyLoginButton
{
    // Add a custom login button to your app
    self.myFBLoginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.myFBLoginButton.backgroundColor=[UIColor darkGrayColor];
    self.myFBLoginButton.frame = CGRectMake(CGRectGetMidX(self.view.frame) - 90, CGRectGetMidY(self.view.frame) + 60,180,40);
    self.myFBLoginButton.layer.cornerRadius = 5;
    [self.myFBLoginButton setTitle: @"My Login Button" forState: UIControlStateNormal];
    
    // Handle clicks on the button
    [self.myFBLoginButton
     addTarget:self
     action:@selector(myLoginButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    
    // Add the button to the view
    [self.view addSubview:self.myFBLoginButton];
}

// Once the button is clicked, show the login dialog
-(void)myLoginButtonClicked
{
    self.fbLoginManager = [[FBSDKLoginManager alloc] init];
    
    [self.fbLoginManager logInWithReadPermissions: @[@"public_profile", @"user_friends"]
                               fromViewController:self
                                          handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
         if (error)
         {
             NSLog(@"Process error");
         }
         else if (result.isCancelled)
         {
             NSLog(@"Cancelled");
         }
         else
         {
             NSLog(@"Logged in");
             
             
             //birthday需要通過fb審查，因此先不使用
             FBSDKGraphRequest *request =
             [[FBSDKGraphRequest alloc] initWithGraphPath:@"me"
                                               parameters:@{@"fields" : @"name, gender, email, birthday"}
                                               HTTPMethod:@"GET"];
             
             [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                
                 NSString *fbID = [result objectForKey:@"id"];
                 NSString *name = [[result objectForKey:@"name"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                 NSString *gender = [result objectForKey:@"gender"];
                 NSString *email = [result objectForKey:@"email"];
                 NSString *birthday = [result objectForKey:@"birthday"];
                 
                 NSLog(@"fbID = %@ \n name = %@ \n gender = %@ \n email = %@ \n birthday = %@", fbID, name, gender, email, birthday);
                 
                 self.fbUserID.text = fbID;
                 self.fbUsername.text = name;
                 self.gender.text = gender;
                 self.fbEmail.text = email;
                 self.birthday.text = birthday;
             }];
             
             
             [self.myFBLoginButton removeFromSuperview];
             
             self.myFBLogoutButton = [UIButton buttonWithType:UIButtonTypeCustom];
             self.myFBLogoutButton.backgroundColor=[UIColor redColor];
             self.myFBLogoutButton.frame = CGRectMake(CGRectGetMidX(self.view.frame) - 90, CGRectGetMidY(self.view.frame) + 60,180,40);
             [self.myFBLogoutButton setTitle: @"My Logout Button" forState: UIControlStateNormal];
             
             // Handle clicks on the button
             [self.myFBLogoutButton
              addTarget:self
              action:@selector(logoutButtonClicked) forControlEvents:UIControlEventTouchUpInside];
             
             // Add the button to the view
             [self.view addSubview:self.myFBLogoutButton];
         }
     }];
    
}

- (void)logoutButtonClicked{
    NSLog(@"Logged out");

    [self.fbLoginManager logOut];
    [self.myFBLogoutButton removeFromSuperview];
    
    [self createMyLoginButton];
}

- (void)fbOfficialToGetUserInfo{
}

#pragma mark - FBSDKLoginButtonDelegate
- (void)loginButton:(FBSDKLoginButton *)loginButton didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result error:(NSError *)error
{
    NSLog(@"didCompleteWithResult");
    
    __block NSString *username;
    __block NSString *email;
    __block NSString *userID;
    
    if (!error) {
        NSLog(@"result = %@", result);
        
        NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
        [parameters setValue:@"name,email" forKey:@"fields"];
        
        [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{@"fields":@"id,name,birthday,about,age_range,bio,email,gender,hometown"} tokenString:result.token.tokenString version:nil HTTPMethod:@"GET"]startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
            
            NSLog(@"result = %@", result);
            NSDictionary *resultDicts = (NSDictionary *)result;
            username = [resultDicts objectForKey:@"name"];
            self.fbUsername.text = username;
            email = [resultDicts objectForKey:@"email"];
            self.fbEmail.text = email;
            userID = [resultDicts objectForKey:@"id"];
            self.fbUserID.text = userID;
            
            //Get FB user profile image
            FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:[NSString stringWithFormat:@"me/picture?type=large&redirect=false"] parameters:nil HTTPMethod:@"GET"];
            
            [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection,
                                                  id result,
                                                  NSError *error) {
                if (!error){
                    NSLog(@"result: %@",result);}
                else {
                    NSLog(@"result: %@",[error description]);
                }}];
            
            //Another way to get fb user profile image, userID = the facebook user id
            NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", userID]];
            NSLog(@"pictureURL = %@", pictureURL);
            NSData *imageData = [NSData dataWithContentsOfURL:pictureURL];
            UIImage *fbImage = [UIImage imageWithData:imageData];
            
            self.imageView.image = fbImage;
            
        }];
    }
}

- (void)loginButtonDidLogOut:(FBSDKLoginButton *)loginButton
{
    NSLog(@"loginButtonDidLogOut");
    
    self.imageView.image = nil;
    self.fbUsername.text = @"";
    self.fbEmail.text = @"";
    self.fbUserID.text = @"";
    self.gender.text = @"";
    self.birthday.text = @"";
}

- (BOOL)loginButtonWillLogin:(FBSDKLoginButton *)loginButton
{
    NSLog(@"loginButtonWillLogin");
    return YES;
}

#pragma mark - IBAction
- (IBAction)fbShareButtonPressed:(UIButton *)sender
{
    FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
    content.contentURL = [NSURL URLWithString:@"https://developers.facebook.com"];
    
    //以下Custom參數只有在非使用FBSDKShareLinkContent時才能使用，否則會被FBSDK自己從網站Parse的內容蓋過去
    content.contentTitle = @"Custom title";
    content.contentDescription = @"Custom description";
    content.imageURL = [NSURL URLWithString:@"http://www.example.com/images/xxxxxx.jpg"];
    
    [FBSDKShareDialog showFromViewController:self
                                 withContent:content
                                    delegate:nil];
}

- (IBAction)fbWebViewStyleShareButtonPressed:(UIButton *)sender
{
    FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
    content.contentURL = [NSURL URLWithString:@"http://www.example.com/"];
    content.contentTitle = @"title_here";
    content.contentDescription = @"description_here";
    content.imageURL = [NSURL URLWithString:@"http://www.example.com/images/xxxxxx.jpg"];

    FBSDKShareDialog* dialog = [[FBSDKShareDialog alloc] init];
    
    //可以顯示客製化內容的Mode
    dialog.mode = FBSDKShareDialogModeFeedWeb;//打開WebView可以顯示客製化內容
    
    //dialog.mode = FBSDKShareDialogModeAutomatic;//預設，不可顯示客製化內縙
    //dialog.mode = FBSDKShareDialogModeShareSheet;//同上
    //dialog.mode = FBSDKShareDialogModeNative; //可以顯示客製化內容
    //dialog.mode = FBSDKShareDialogModeBrowser; //打開safari
    //dialog.mode = FBSDKShareDialogModeWeb;//打開WebView
    //dialog.mode = FBSDKShareDialogModeFeedBrowser;//打開safari 可以顯示客製化內容
    
    //無法顯示客製化內容的Mode
//    if (![dialog canShow]) {
//        // fallback presentation when there is no FB app
//        dialog.mode = FBSDKShareDialogModeFeedBrowser;
//    }
    
    dialog.shareContent = content;
    dialog.fromViewController = self;
    [dialog show];
}

- (IBAction)fbPhotoShareButtonPressed:(UIButton *)sender
{
    UIImage *image = [UIImage imageNamed:@"Suits"];
    
    FBSDKSharePhoto *photo = [[FBSDKSharePhoto alloc] init];
    photo.image = image;
    photo.userGenerated = YES;
    FBSDKSharePhotoContent *content = [[FBSDKSharePhotoContent alloc] init];
    content.photos = @[photo];
    
    [FBSDKShareDialog showFromViewController:self
                                 withContent:content
                                    delegate:nil];
    
}

- (IBAction)fbVideoShareButtonPressed:(UIButton *)sender
{
    //NSURL *videoURL = [info objectForKey:UIImagePickerControllerReferenceURL];
    NSString *path = [[NSBundle mainBundle]pathForResource:@"emoji zone" ofType:@"mp4"];
    NSURL *videoURL = [NSURL URLWithString:path];
    //NSURL *videoURL = [NSURL URLWithString:@"http://down.treney.com/mov/test.mp4"];
    
    FBSDKShareVideo *video = [[FBSDKShareVideo alloc] init];
    video.videoURL = videoURL;
    FBSDKShareVideoContent *content = [[FBSDKShareVideoContent alloc] init];
    content.video = video;
    
    [FBSDKShareDialog showFromViewController:self
                                 withContent:content
                                    delegate:nil];
}


@end
