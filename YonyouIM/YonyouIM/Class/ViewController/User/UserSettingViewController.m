//
//  UserSettingViewController.m
//  YonyouIM
//
//  Created by litfb on 15/3/31.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "UserSettingViewController.h"
#import "YYImageCropperViewController.h"
#import "YYIMUtility.h"
#import "SingleLineCell2.h"
#import "YYIMUtility.h"
#import "YYIMColorHelper.h"
#import "UIViewController+HUDCategory.h"
#import "YYIMUIDefs.h"

@interface UserSettingViewController ()<UIActionSheetDelegate, UIAlertViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate, YYImageCropperDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (retain, nonatomic) UIPickerView *pickerView;

@property (retain, nonatomic) YYUser *user;

@property (retain, nonatomic) NSArray *userSetting;

@end

@implementation UserSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"个人信息";
    
    // 注册Cell nib
    [self.tableView registerNib:[UINib nibWithNibName:@"SingleLineCell2" bundle:nil] forCellReuseIdentifier:@"SingleLineCell2"];
    
    [YYIMUtility setExtraCellLineHidden:self.tableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadData];
}
- (void)backAction {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark table delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 2;
        case 1:
            return [self.userSetting count];
        default:
            return 0;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 16;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView * sectionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 16)];
    [sectionView setBackgroundColor:UIColorFromRGB(0xf6f6f6)];
    if (section > 0) {
        UIView *sepView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 0.5)];
        [sepView setBackgroundColor:UIColorFromRGB(0xe6e6e6)];
        [sectionView addSubview:sepView];
    }
    UIView *sepView2 = [[UIView alloc] initWithFrame:CGRectMake(0, 16, tableView.bounds.size.width, 0.5)];
    [sepView2 setBackgroundColor:UIColorFromRGB(0xe6e6e6)];
    [sectionView addSubview:sepView2];
    return sectionView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // 取cell
    static NSString *CellIndentifier = @"SingleLineCell2";
    SingleLineCell2 *cell = [tableView dequeueReusableCellWithIdentifier:CellIndentifier];
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    [cell.detailLabel setTextAlignment:NSTextAlignmentRight];
    [cell reuse];
    
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0:
                    [cell setName:@"头像"];
                    [cell setImageWithUrl:[self.user getUserPhoto] placeholderName:[self.user userName]];
                    [cell setImageRadius:25];
                    break;
                case 1:
                    [cell setAccessoryType:UITableViewCellAccessoryNone];
                    [cell setName:@"姓名"];
                    [cell setDetail:[self.user userName]];
                    break;
            }
            break;
        case 1: {
            NSString *showCol = [self.userSetting objectAtIndex:indexPath.row];
            if ([showCol isEqualToString:@"email"]) {
                [cell setName:@"邮箱"];
                [cell setDetail:[self.user userEmail]];
            } else if ([showCol isEqualToString:@"organization"]) {
                [cell setAccessoryType:UITableViewCellAccessoryNone];
                [cell setName:@"部门"];
                [cell setDetail:[self.user userOrg]];
            } else if ([showCol isEqualToString:@"mobile"]) {
                [cell setName:@"手机号"];
                [cell setDetail:[self.user userMobile]];
            } else if ([showCol isEqualToString:@"position"]) {
                [cell setName:@"职位"];
                [cell setDetail:[self.user userTitle]];
            } else if ([showCol isEqualToString:@"gender"]) {
                [cell setName:@"性别"];
                [cell setDetail:[self.user userGender]];
            } else if ([showCol isEqualToString:@"number"]) {
                [cell setName:@"工号"];
                [cell setDetail:[self.user userNumber]];
            } else if ([showCol isEqualToString:@"telephone"]) {
                [cell setName:@"分机号"];
                [cell setDetail:[self.user userTelephone]];
            } else if ([showCol isEqualToString:@"location"]) {
                [cell setName:@"办公地点"];
                [cell setDetail:[self.user userLocation]];
            } else if ([showCol isEqualToString:@"remarks"]) {
                [cell setName:@"备注"];
                [cell setDetail:[self.user userDesc]];
            }
            break;
        }
        default:
            break;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0:
                    return 68;
                default:
                    return 48;
            }
        case 1:
            return 48;
        default:
            return 0;
    }
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0:
            if (indexPath.row == 1) {
                return nil;
            }
            break;
        case 1: {
            NSString *showCol = [self.userSetting objectAtIndex:indexPath.row];
            if ([showCol isEqualToString:@"organization"]) {
                return nil;
            }
            break;
        }
        default:
            break;
    }
    return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0: {
                    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照", @"从相册选择", nil];
                    actionSheet.actionSheetStyle = UIActionSheetStyleAutomatic;
                    [actionSheet showInView:self.view];
                    break;
                }
                default:
                    break;
            }
            break;
        case 1: {
            NSString *showCol = [self.userSetting objectAtIndex:indexPath.row];
            if ([showCol isEqualToString:@"email"]) {
                [self showEditAlertView:[self tagForIndex:indexPath.row] textValue:[self.user userEmail]];
            } else if ([showCol isEqualToString:@"mobile"]) {
                [self showEditAlertView:[self tagForIndex:indexPath.row] textValue:[self.user userMobile]];
            } else if ([showCol isEqualToString:@"position"]) {
                [self showEditAlertView:[self tagForIndex:indexPath.row] textValue:[self.user userTitle]];
            } else if ([showCol isEqualToString:@"gender"]) {
                [self showGenderPickerView:[self tagForIndex:indexPath.row] defaultValue:[self.user userGender]];
            } else if ([showCol isEqualToString:@"number"]) {
                [self showEditAlertView:[self tagForIndex:indexPath.row] textValue:[self.user userNumber]];
            } else if ([showCol isEqualToString:@"telephone"]) {
                [self showEditAlertView:[self tagForIndex:indexPath.row] textValue:[self.user userTelephone]];
            } else if ([showCol isEqualToString:@"location"]) {
                [self showEditAlertView:[self tagForIndex:indexPath.row] textValue:[self.user userLocation]];
            } else if ([showCol isEqualToString:@"remarks"]) {
                [self showEditAlertView:[self tagForIndex:indexPath.row] textValue:[self.user userDesc]];
            }
            break;
        }
        default:
            break;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark chatdelegate

- (void)didUserInfoUpdate:(YYUser *)user {
    if ([[user userId] isEqualToString:[[YYIMConfig sharedInstance] getUser]]) {
        [self reloadData];
    }
}

- (void)reloadData {
    NSMutableArray *userSetting = [NSMutableArray arrayWithArray:[[YYIMConfig sharedInstance] getUserSetting]];
    [userSetting removeObject:@"photo"];
    [userSetting removeObject:@"nickname"];
    self.userSetting = userSetting;
    // 加载数据
    self.user = [[YYIMChat sharedInstance].chatManager getUserWithId:[[YYIMConfig sharedInstance] getUser]];
    [self.tableView reloadData];
}

#pragma mark action sheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag >= 100) {
        switch (buttonIndex) {
            case 0:
                [self confirmGender:actionSheet];
                break;
            default:
                break;
        }
    } else {
        switch (buttonIndex) {
            case 0: {
                if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                    [self openImagePicker:UIImagePickerControllerSourceTypeCamera];
                }
                break;
            }
            case 1:
                if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
                    [self openImagePicker:UIImagePickerControllerSourceTypePhotoLibrary];
                }
                break;
        }
    }
}

#pragma mark image picker delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [self dismissViewControllerAnimated:YES completion:^{
        // 得到图片
        UIImage *originalImage = [info objectForKey:UIImagePickerControllerOriginalImage];
        originalImage = [YYIMResourceUtility thumbImage:originalImage maxSide:640.0f];
        // 裁剪
        YYImageCropperViewController *cropperViewController = [[YYImageCropperViewController alloc] initWithImage:originalImage];
        cropperViewController.delegate = self;
        [self presentViewController:cropperViewController animated:YES completion:nil];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark image cropper delegate

- (void)imageCropper:(YYImageCropperViewController *)cropperViewController didFinished:(UIImage *)croppedImage {
    [self dismissViewControllerAnimated:NO completion:nil];
    
    NSString *imagePath = [YYIMResourceUtility saveImage:croppedImage];
    
    [[YYIMChat sharedInstance].chatManager uploadAttach:imagePath fileName:nil receiver:nil mediaType:kYYIMUploadMediaTypeImage isOriginal:NO complete:^(BOOL result, YYAttach *attach, YYIMError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (result && [attach attachId]) {
                [self.user setUserPhoto:[attach attachId]];
                [[YYIMChat sharedInstance].chatManager updateUser:self.user];
            } else {
                [self showHint:@"头像上传失败，请重试"];
            }
        });
    }];
}

- (void)imageCropperDidCancel:(YYImageCropperViewController *)cropperViewController {
    [self dismissViewControllerAnimated:NO completion:nil];
}

#pragma mark alert delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        UITextField *textField=[alertView textFieldAtIndex:0];
        NSString *newVal = textField.text;
        
        NSString *showCol = [self.userSetting objectAtIndex:[self indexForTag:alertView.tag]];
        if ([showCol isEqualToString:@"email"]) {
            [self.user setUserEmail:newVal];
        } else if ([showCol isEqualToString:@"mobile"]) {
            [self.user setUserMobile:newVal];
        } else if ([showCol isEqualToString:@"position"]) {
            [self.user setUserTitle:newVal];
        } else if ([showCol isEqualToString:@"number"]) {
            [self.user setUserNumber:newVal];
        } else if ([showCol isEqualToString:@"telephone"]) {
            [self.user setUserTelephone:newVal];
        } else if ([showCol isEqualToString:@"location"]) {
            [self.user setUserLocation:newVal];
        } else if ([showCol isEqualToString:@"remarks"]) {
            [self.user setUserDesc:newVal];
        }
        [[YYIMChat sharedInstance].chatManager updateUser:self.user];
    }
}

#pragma mark UIPickerViewDataSource, UIPickerViewDelegate

// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return 2;
}

// returns width of column and height of row for each component.
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    return 200.0f;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 35.0f;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    switch (row) {
        case 0:
            return @"男";
        default:
            return @"女";
    }
}

#pragma mark private func

- (void)openImagePicker:(UIImagePickerControllerSourceType)sourceType {
    // 跳转相册或相机页面
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    [YYIMUtility genThemeNavController:imagePicker];
    [imagePicker setDelegate:self];
    [imagePicker setSourceType:sourceType];
    if (sourceType == UIImagePickerControllerSourceTypeCamera) {
        if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]) {
            imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
        }
    }
    NSMutableArray *mediaTypes = [NSMutableArray array];
    [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
    imagePicker.mediaTypes = mediaTypes;
    
    [imagePicker setAllowsEditing:NO];
    [self presentViewController:imagePicker animated:YES completion:nil];
}

- (void)showEditAlertView:(NSInteger)tag textValue:(NSString *)text {
    NSString *title = @"";
    UIKeyboardType keyboardType = UIKeyboardTypeDefault;
    NSString *showCol = [self.userSetting objectAtIndex:[self indexForTag:tag]];
    if ([showCol isEqualToString:@"email"]) {
        title = @"修改邮箱";
        keyboardType = UIKeyboardTypeEmailAddress;
    } else if ([showCol isEqualToString:@"mobile"]) {
        title = @"修改手机";
        keyboardType = UIKeyboardTypePhonePad;
    } else if ([showCol isEqualToString:@"position"]) {
        title = @"修改职位";
        keyboardType = UIKeyboardTypeDefault;
    } else if ([showCol isEqualToString:@"number"]) {
        title = @"修改工号";
        keyboardType = UIKeyboardTypeDefault;
    } else if ([showCol isEqualToString:@"telephone"]) {
        title = @"修改分机号";
        keyboardType = UIKeyboardTypePhonePad;
    } else if ([showCol isEqualToString:@"location"]) {
        title = @"修改办公地点";
        keyboardType = UIKeyboardTypeDefault;
    } else if ([showCol isEqualToString:@"remarks"]) {
        title = @"修改备注";
        keyboardType = UIKeyboardTypeDefault;
    }
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField *textField = [alertView textFieldAtIndex:0];
    [textField setText:text];
    [textField setClearButtonMode:UITextFieldViewModeWhileEditing];
    [textField setKeyboardType:keyboardType];
    
    alertView.tag = tag;
    [alertView show];
}

- (void)showGenderPickerView:(NSInteger)tag defaultValue:(NSString *)defaultValue {
    NSInteger defaultIndex = -1;
    if ([defaultValue isEqualToString:@"男"]) {
        defaultIndex = 0;
    } else if ([defaultValue isEqualToString:@"女"]) {
        defaultIndex = 1;
    }
    
    NSString *title = @"修改性别\n\n\n\n\n\n\n\n";
    if (YYIM_iOS8) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            
        }];
        
        UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self confirmGender:action];
        }];
        
        [alertController.view addSubview:[self pickerView]];
        [alertController addAction:cancelAction];
        [alertController addAction:confirmAction];
        [self presentViewController:alertController animated:YES completion:nil];
    } else {
        UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"确定", nil];
        [actionSheet setTag:tag];
        [actionSheet addSubview:[self pickerView]];
        [actionSheet showInView:self.view];
    }
}

- (NSInteger)indexForTag:(NSInteger)tag {
    return tag - 100;
}

- (NSInteger)tagForIndex:(NSInteger)index {
    return index + 100;
}

- (UIPickerView *)pickerView {
    if (!_pickerView) {
        CGRect frame;
        if (YYIM_iOS8) {
            frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame) - 16, 162);
        } else {
            frame = CGRectMake(20, 0, CGRectGetWidth(self.view.frame) - 40, 162);
        }
        UIPickerView *pickerView = [[UIPickerView alloc] initWithFrame:frame];
        pickerView.dataSource = self;
        pickerView.delegate = self;
        pickerView.showsSelectionIndicator = YES;
        _pickerView = pickerView;
    }
    return _pickerView;
}

- (void)confirmGender:(id)sender {
    NSInteger selectIndex = [self.pickerView selectedRowInComponent:0];
    NSString *gender = @"未设置";
    if (selectIndex == 0) {
        gender = @"男";
    } else {
        gender = @"女";
    }
    [self.user setUserGender:gender];
    [[YYIMChat sharedInstance].chatManager updateUser:self.user];
}

@end
