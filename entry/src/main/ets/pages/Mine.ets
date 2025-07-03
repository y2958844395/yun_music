// pages/Mine.ets
import { UserService } from '../utils/UserService';
import { ApiResponse, User, UploadResult } from '../models/User';
import { promptAction } from '@kit.ArkUI';
import { picker } from '@kit.CoreFileKit';
import { BASE_URL, HttpUtil } from '../utils/HttpUtil';
import { common } from '@kit.AbilityKit';
import { rcp } from '@kit.RemoteCommunicationKit';
import fs from '@ohos.file.fs';

interface GeneratedTypeLiteralInterface_1 {
  success: boolean;
  message: string;
}

interface GeneratedTypeLiteralInterface_2 {
  copyPath: string;
  sandboxPath: string;
  fileName: string;
}
interface MineProps {
  onNavigateToLogin?: () => void;
}
@Component
export struct Mine {
  onNavigateToLogin?: () => void;
  @State currentUser: User | null = null;
  @State isLoading: boolean = false;
  @State showEditProfile: boolean = false;
  @State showChangePassword: boolean = false;
  @State isUploadingAvatar: boolean = false;

  // 编辑资料相关状态
  @State editNickname: string = '';
  @State editBio: string = '';
  @State isUpdatingProfile: boolean = false;
  @State profileErrorMessage: string = '';

  // 修改密码相关状态
  @State oldPassword: string = '';
  @State newPassword: string = '';
  @State confirmNewPassword: string = '';
  @State isChangingPassword: boolean = false;
  @State passwordErrorMessage: string = '';

  async aboutToAppear() {
    await this.loadUserInfo();
  }

  // 加载用户信息
  private async loadUserInfo() {
    this.isLoading = true;
    try {
      const result = await UserService.getProfile();
      if (result.success && result.user) {
        this.currentUser = result.user;
        this.editNickname = result.user.nickname || '';
        this.editBio = result.user.bio || '';
      } else {
        // 如果获取失败，尝试从本地存储获取
        this.currentUser = await UserService.getCurrentUser();
        if (this.currentUser) {
          this.editNickname = this.currentUser.nickname || '';
          this.editBio = this.currentUser.bio || '';
        }
      }
    } catch (error) {
      console.error('加载用户信息失败:', error);
    } finally {
      this.isLoading = false;
    }
  }

  // 选择并上传头像
  private async handleAvatarUpload(): Promise<void> {
    try {
      this.isUploadingAvatar = true;

      // 获取context
      const context = getContext(this) as common.UIAbilityContext;

      // 创建文件选择器实例
      const documentViewPicker = new picker.DocumentViewPicker(context);
      const documentSelectOptions = new picker.DocumentSelectOptions();
      documentSelectOptions.maxSelectNumber = 1;
      documentSelectOptions.fileSuffixFilters = ['.png', '.jpg', '.jpeg'];
      documentSelectOptions.authMode = true;

      const result = await documentViewPicker.select(documentSelectOptions);

      if (result && result.length > 0) {
        const fileUri = result[0];

        // 调用上传头像接口
        const uploadResult = await this.uploadAvatar(fileUri, context);
        if (uploadResult.success) {
          promptAction.showToast({
            message: '头像上传成功',
            duration: 2000
          });
          await this.loadUserInfo();
        } else {
          promptAction.showToast({
            message: uploadResult.message || '头像上传失败',
            duration: 2000
          });
        }
      }
    } catch (error) {
      console.error('选择头像失败:', error);
      promptAction.showToast({
        message: '选择头像失败',
        duration: 2000
      });
    } finally {
      this.isUploadingAvatar = false;
    }
  }

  // 上传头像到服务器
  private async uploadAvatar(fileUri: string, context: common.UIAbilityContext): Promise<UploadResult> {
    try {
      const token = await UserService.getToken();
      if (!token) {
        return { success: false, message: '未登录' };
      }

      // 文件处理：拷贝到沙箱目录
      const fileInfo = await this.prepareFileForUpload(fileUri, context);

      try {
        const response = await HttpUtil.uploadFileWithHttpRequest(
          '/upload-avatar',
          fileInfo.sandboxPath,
          fileInfo.fileName,
          'avatar',
          token
        );

        if (response.code === 200) {
          return { success: true, message: '上传成功' };
        } else {
          return { success: false, message: response.message || '上传失败' };
        }
      } finally {
        // 清理临时文件
        try {
          fs.unlinkSync(fileInfo.copyPath);
        } catch (cleanupError) {
          console.warn('清理缓存文件失败:', cleanupError);
        }
      }
    } catch (error) {
      console.error('上传头像失败:', error);
      return { success: false, message: '网络错误' };
    }
  }

  // 准备文件用于上传
  private async prepareFileForUpload(fileUri: string, context: common.UIAbilityContext): Promise<GeneratedTypeLiteralInterface_2> {
    // 获取文件扩展名
    const fileExtension = fileUri.split('.').pop() || 'jpg';
    const fileName = Date.now() + '.' + fileExtension;

    // 拷贝到缓存目录的完整路径
    const copyPath = context.cacheDir + '/' + fileName;

    // 构造沙箱路径（用于上传）
    const sandboxPath = 'internal://cache/' + fileName;

    // 打开原文件并拷贝
    const file = fs.openSync(fileUri, fs.OpenMode.READ_ONLY);
    try {
      fs.copyFileSync(file.fd, copyPath);
    } finally {
      fs.closeSync(file);
    }

    return {
      copyPath,
      sandboxPath,
      fileName
    };
  }
  // 验证资料编辑输入
  private validateProfileInput(): boolean {
    if (!this.editNickname.trim()) {
      this.profileErrorMessage = '请输入昵称';
      return false;
    }
    if (this.editNickname.length > 50) {
      this.profileErrorMessage = '昵称长度不能超过50字符';
      return false;
    }
    if (this.editBio.length > 200) {
      this.profileErrorMessage = '个人简介长度不能超过200字符';
      return false;
    }
    return true;
  }

  // 更新用户资料
  private async handleUpdateProfile() {
    if (!this.validateProfileInput()) {
      return;
    }

    this.isUpdatingProfile = true;
    this.profileErrorMessage = '';

    try {
      const result = await UserService.updateProfile({
        nickname: this.editNickname,
        bio: this.editBio
      });

      if (result.success) {
        this.currentUser = result.user || this.currentUser;
        this.showEditProfile = false;
        promptAction.showToast({
          message: '资料更新成功',
          duration: 2000
        });
      } else {
        this.profileErrorMessage = result.message;
      }
    } catch (error) {
      console.error('更新资料失败:', error);
      this.profileErrorMessage = '更新失败，请重试';
    } finally {
      this.isUpdatingProfile = false;
    }
  }

  // 验证密码修改输入
  private validatePasswordInput(): boolean {
    if (!this.oldPassword.trim()) {
      this.passwordErrorMessage = '请输入当前密码';
      return false;
    }
    if (!this.newPassword.trim()) {
      this.passwordErrorMessage = '请输入新密码';
      return false;
    }
    if (this.newPassword.length < 6) {
      this.passwordErrorMessage = '新密码长度至少6位';
      return false;
    }
    if (this.newPassword !== this.confirmNewPassword) {
      this.passwordErrorMessage = '两次输入的新密码不一致';
      return false;
    }
    if (this.oldPassword === this.newPassword) {
      this.passwordErrorMessage = '新密码不能与当前密码相同';
      return false;
    }
    return true;
  }

  // 修改密码
  private async handleChangePassword() {
    if (!this.validatePasswordInput()) {
      return;
    }

    this.isChangingPassword = true;
    this.passwordErrorMessage = '';

    try {
      const result = await UserService.changePassword({
        old_password: this.oldPassword,
        new_password: this.newPassword,
        confirm_password: this.confirmNewPassword
      });

      if (result.success) {
        this.showChangePassword = false;
        this.oldPassword = '';
        this.newPassword = '';
        this.confirmNewPassword = '';
        promptAction.showToast({
          message: '密码修改成功',
          duration: 2000
        });
      } else {
        this.passwordErrorMessage = result.message;
      }
    } catch (error) {
      console.error('修改密码失败:', error);
      this.passwordErrorMessage = '修改失败，请重试';
    } finally {
      this.isChangingPassword = false;
    }
  }

  // 登出
  private async handleLogout() {
    try {
      await UserService.logout();

      this.currentUser = null;
      this.editNickname = '';
      this.editBio = '';
      this.oldPassword = '';
      this.newPassword = '';
      this.confirmNewPassword = '';
      this.profileErrorMessage = '';
      this.passwordErrorMessage = '';
      this.showEditProfile = false;
      this.showChangePassword = false;
      this.isUploadingAvatar = false;
      this.isUpdatingProfile = false;
      this.isChangingPassword = false;
      this.isLoading = false;

      promptAction.showToast({
        message: '已退出登录',
        duration: 2000
      });
    } catch (error) {
      console.error('登出失败:', error);
    }
  }

  // 构建头像显示
  @Builder
  private buildAvatar() {
    Stack() {
      if (this.currentUser?.avatar) {
        Image(`${BASE_URL}/avatar/${this.currentUser.avatar}`)
          .width(100)
          .height(100)
          .borderRadius(50)
          .alt($r('app.media.avatar'))
      } else {
        Image($r('app.media.avatar'))
          .width(100)
          .height(100)
          .borderRadius(50)
      }

      // 上传中的加载指示器
      if (this.isUploadingAvatar) {
        LoadingProgress()
          .width(100)
          .height(100)
          .backgroundColor('rgba(0,0,0,0.7)')
          .borderRadius(50)
      }

      // 点击提示文字
      Text('点击更换')
        .fontSize(10)
        .fontColor('#FFFFFF')
        .backgroundColor('rgba(0,0,0,0.8)')
        .borderRadius(10)
        .padding({ left: 8, right: 8, top: 4, bottom: 4 })
        .position({ x: 25, y: 75 })
    }
    .onClick(() => {
      if (!this.isUploadingAvatar) {
        this.handleAvatarUpload();
      }
    })
  }

  // 构建编辑资料对话框
  @Builder
  private buildEditProfileDialog() {
    if (this.showEditProfile) {
      Column() {
        Text('编辑资料')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
          .margin({ bottom: 24 })

        Column({ space: 16 }) {
          // 昵称输入
          TextInput({ placeholder: '请输入昵称', text: this.editNickname })
            .backgroundColor('#2D2B29')
            .fontColor('#FFFFFF')
            .placeholderColor('#817D83')
            .borderRadius(8)
            .onChange((value) => {
              this.editNickname = value;
              this.profileErrorMessage = '';
            })

          // 个人简介输入
          TextArea({ placeholder: '请输入个人简介（可选）', text: this.editBio })
            .height(80)
            .backgroundColor('#2D2B29')
            .fontColor('#FFFFFF')
            .placeholderColor('#817D83')
            .borderRadius(8)
            .onChange((value) => {
              this.editBio = value;
              this.profileErrorMessage = '';
            })

          // 错误信息
          if (this.profileErrorMessage) {
            Text(this.profileErrorMessage)
              .fontSize(14)
              .fontColor('#FF6B6B')
          }

          // 按钮组
          Row({ space: 12 }) {
            Button('取消')
              .layoutWeight(1)
              .backgroundColor('#3D3B37')
              .fontColor('#FFFFFF')
              .borderRadius(8)
              .onClick(() => {
                this.showEditProfile = false;
                this.profileErrorMessage = '';
              })

            Button(this.isUpdatingProfile ? '保存中...' : '保存')
              .layoutWeight(1)
              .enabled(!this.isUpdatingProfile)
              .backgroundColor('#4ECDC4')
              .fontColor('#FFFFFF')
              .borderRadius(8)
              .onClick(() => {
                this.handleUpdateProfile();
              })
          }
        }
      }
      .padding(24)
      .backgroundColor('#1C1C1E')
      .borderRadius(16)
      .margin(20)
    }
  }

  // 构建修改密码对话框
  @Builder
  private buildChangePasswordDialog() {
    if (this.showChangePassword) {
      Column() {
        Text('修改密码')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
          .margin({ bottom: 24 })

        Column({ space: 16 }) {
          // 当前密码
          TextInput({ placeholder: '请输入当前密码' })
            .type(InputType.Password)
            .backgroundColor('#2D2B29')
            .fontColor('#FFFFFF')
            .placeholderColor('#817D83')
            .borderRadius(8)
            .onChange((value) => {
              this.oldPassword = value;
              this.passwordErrorMessage = '';
            })

          // 新密码
          TextInput({ placeholder: '请输入新密码（至少6位）' })
            .type(InputType.Password)
            .backgroundColor('#2D2B29')
            .fontColor('#FFFFFF')
            .placeholderColor('#817D83')
            .borderRadius(8)
            .onChange((value) => {
              this.newPassword = value;
              this.passwordErrorMessage = '';
            })

          // 确认新密码
          TextInput({ placeholder: '请再次输入新密码' })
            .type(InputType.Password)
            .backgroundColor('#2D2B29')
            .fontColor('#FFFFFF')
            .placeholderColor('#817D83')
            .borderRadius(8)
            .onChange((value) => {
              this.confirmNewPassword = value;
              this.passwordErrorMessage = '';
            })

          // 错误信息
          if (this.passwordErrorMessage) {
            Text(this.passwordErrorMessage)
              .fontSize(14)
              .fontColor('#FF6B6B')
          }

          // 按钮组
          Row({ space: 12 }) {
            Button('取消')
              .layoutWeight(1)
              .backgroundColor('#3D3B37')
              .fontColor('#FFFFFF')
              .borderRadius(8)
              .onClick(() => {
                this.showChangePassword = false;
                this.passwordErrorMessage = '';
                this.oldPassword = '';
                this.newPassword = '';
                this.confirmNewPassword = '';
              })

            Button(this.isChangingPassword ? '修改中...' : '确认修改')
              .layoutWeight(1)
              .enabled(!this.isChangingPassword)
              .backgroundColor('#FF6B6B')
              .fontColor('#FFFFFF')
              .borderRadius(8)
              .onClick(() => {
                this.handleChangePassword();
              })
          }
        }
      }
      .padding(24)
      .backgroundColor('#1C1C1E')
      .borderRadius(16)
      .margin(20)
    }
  }

  private handleGoToLogin() {
    if (this.onNavigateToLogin) {
      this.onNavigateToLogin();
    } else {
      promptAction.showToast({
        message: '请先登录',
        duration: 2000
      });
    }
  }

  // 修改 build 方法中的登出按钮部分
  build() {
    Stack() {
      if (this.isLoading) {
        // 加载状态
        Column() {
          LoadingProgress()
            .width(60)
            .height(60)
            .color('#FFFFFF')
          Text('加载中...')
            .fontSize(16)
            .fontColor('#817D83')
            .margin({ top: 16 })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
      } else if (!this.currentUser) {
        // 未登录状态 - 显示登录提示
        Column() {
          Image($r('app.media.avatar'))
            .width(100)
            .height(100)
            .borderRadius(50)
            .margin({ bottom: 20 })

          Text('未登录')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
            .margin({ bottom: 8 })

          Text('登录后查看更多功能')
            .fontSize(16)
            .fontColor('#817D83')
            .margin({ bottom: 40 })

          Button('点击登录')
            .width('calc(100% - 32vp)')
            .height(52)
            .fontSize(16)
            .fontColor('#FFFFFF')
            .backgroundColor('#4ECDC4')
            .borderRadius(26)
            .onClick(() => {
              this.handleGoToLogin();
            })

          Blank()
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .padding(16)
      } else {
        // 已登录状态 - 显示完整的用户信息界面
        Column() {
          // 用户信息卡片
          Column() {
            // 头像和基本信息
            Column({ space: 16 }) {
              this.buildAvatar()

              Text(this.currentUser?.nickname || this.currentUser?.username || '未知用户')
                .fontSize(24)
                .fontWeight(FontWeight.Bold)
                .fontColor('#FFFFFF')

              Text(`@${this.currentUser?.username || ''}`)
                .fontSize(16)
                .fontColor('#817D83')

              if (this.currentUser?.bio) {
                Text(this.currentUser.bio)
                  .fontSize(15)
                  .fontColor('#B3B3B3')
                  .textAlign(TextAlign.Center)
                  .maxLines(3)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .margin({ top: 8 })
                  .padding({ left: 16, right: 16 })
              }
            }
            .padding({ top: 32, bottom: 24, left: 24, right: 24 })
          }
          .width('100%')
          .backgroundColor('#2D2B29')
          .borderRadius(16)
          .margin({ top: 20, left: 16, right: 16 })

          // 功能菜单
          Column({ space: 16 }) {
            // 编辑资料
            Row() {
              Text('🎵 编辑资料')
                .fontSize(16)
                .fontColor('#FFFFFF')
                .fontWeight(FontWeight.Medium)
            }
            .width('100%')
            .height(52)
            .padding({ left: 20, right: 20 })
            .backgroundImageSize(ImageSize.Cover)
            .borderRadius(12)
            .justifyContent(FlexAlign.Start)
            .onClick(() => {
              this.showEditProfile = true;
            })

            // 修改密码
            Row() {
              Text('🔐 修改密码')
                .fontSize(16)
                .fontColor('#FFFFFF')
                .fontWeight(FontWeight.Medium)
            }
            .width('100%')
            .height(52)
            .padding({ left: 20, right: 20 })
            .backgroundColor('#660000')
            .borderRadius(12)
            .justifyContent(FlexAlign.Start)
            .onClick(() => {
              this.showChangePassword = true;
            })

            // 账户信息
            Column({ space: 12 }) {
              Text('📱 账户信息')
                .fontSize(16)
                .fontColor('#FFFFFF')
                .fontWeight(FontWeight.Bold)
                .alignSelf(ItemAlign.Start)

              Column({ space: 8 }) {
                Text(`邮箱: ${this.currentUser?.email || ''}`)
                  .fontSize(14)
                  .fontColor('#B3B3B3')
                  .alignSelf(ItemAlign.Start)

                Text(`注册时间: ${this.currentUser?.created_at ? new Date(this.currentUser.created_at).toLocaleDateString() : ''}`)
                  .fontSize(14)
                  .fontColor('#B3B3B3')
                  .alignSelf(ItemAlign.Start)
              }
            }
            .width('100%')
            .padding(20)
            .backgroundColor('#382e2f')
            .borderRadius(12)
            .alignItems(HorizontalAlign.Start)
          }
          .padding(16)

          // 登出按钮
          Button('退出登录')
            .width('calc(100% - 32vp)')
            .height(52)
            .fontSize(16)
            .fontColor('#FF6B6B')
            .backgroundColor('rgba(255, 107, 107, 0.1)')
            .border({ width: 1, color: '#FF6B6B' })
            .borderRadius(26)
            .margin({ top: 16, left: 16, right: 16 })
            .onClick(() => {
              this.handleLogout();
            })

          Blank()
        }
        .width('100%')
        .height('100%')
      }

      // 对话框覆盖层
      if (this.showEditProfile || this.showChangePassword) {
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('rgba(0,0,0,0.8)')
          .onClick(() => {
            this.showEditProfile = false;
            this.showChangePassword = false;
          })
      }

      // 编辑资料对话框
      this.buildEditProfileDialog()

      // 修改密码对话框
      this.buildChangePasswordDialog()
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#000000') // 深色背景与Recommend保持一致
  }
}

// 保持Recommend组件不变
interface recommendDailyType {
  img: string // 图片
  title: string // 简介文字
  type: string // 标题文字
  top: string // 标题背景色
  bottom: string // 简介背景色
}

interface recommendListType {
  img: string
  title: string
  count: string
}

@Component
export struct Recommend {
  // ... 保持原有代码不变
  // 轮播图数据
  swiperList: string[] = [
    "http://yjy-teach-oss.oss-cn-beijing.aliyuncs.com/HeimaCloudMusic/banner1.png",
    "http://yjy-teach-oss.oss-cn-beijing.aliyuncs.com/HeimaCloudMusic/banner2.png",
    "http://yjy-teach-oss.oss-cn-beijing.aliyuncs.com/HeimaCloudMusic/banner3.png",
    "http://yjy-teach-oss.oss-cn-beijing.aliyuncs.com/HeimaCloudMusic/banner4.png",
    "http://yjy-teach-oss.oss-cn-beijing.aliyuncs.com/HeimaCloudMusic/banner5.png"
  ]
  // 每日推荐数据
  dailyRecommend: recommendDailyType[] = [
    {
      img: 'http://yjy-teach-oss.oss-cn-beijing.aliyuncs.com/HeimaCloudMusic/recommend1.png',
      title: '每日推荐 | 今天从《不得不爱》听起 | 私人雷达',
      type: '每日推荐',
      top: '#660000',
      bottom: '#382e2f'
    },
    {
      img: 'http://yjy-teach-oss.oss-cn-beijing.aliyuncs.com/HeimaCloudMusic/recommend2.png',
      title: '从 [Nothing on Me] 开启无限漫游',
      type: '私人漫游',
      top: '#382e2f',
      bottom: '#a37862'
    },
    {
      img: 'http://yjy-teach-oss.oss-cn-beijing.aliyuncs.com/HeimaCloudMusic/recommend3.png',
      title: '每日推荐 | 今天从《不得不爱》听起 | 私人雷达',
      type: '华语流行',
      top: '#a37862',
      bottom: '#174847'
    },
    {
      img: 'http://yjy-teach-oss.oss-cn-beijing.aliyuncs.com/HeimaCloudMusic/recommend4.png',
      title: '每日推荐 | 今天从《不得不爱》听起 | 私人雷达',
      type: '私人雷达',
      top: '#174847',
      bottom: '#174847'
    }
  ]
  // 推荐歌单数据
  recommendList: recommendListType[] = [
    {
      img: 'http://yjy-teach-oss.oss-cn-beijing.aliyuncs.com/HeimaCloudMusic/list1.jpg',
      title: '每日推荐 | 今天从《不得不爱》听起 | 私人雷达',
      count: '270.9万'
    },
    {
      img: 'http://yjy-teach-oss.oss-cn-beijing.aliyuncs.com/HeimaCloudMusic/list2.jpg',
      title: 'Yasuo和更多好听的 | 华语私人雷达 | 回忆8090',
      count: '476.1万'
    },
    {
      img: 'http://yjy-teach-oss.oss-cn-beijing.aliyuncs.com/HeimaCloudMusic/list3.jpg',
      title: 'Trap Remix丨当欧美热单遇上毒性低音',
      count: '186.3万'
    },
    {
      img: 'http://yjy-teach-oss.oss-cn-beijing.aliyuncs.com/HeimaCloudMusic/list4.jpg',
      title: '满级人类进化之路必备BGM | 根本停不下来',
      count: '186.3万'
    },
    {
      img: 'http://yjy-teach-oss.oss-cn-beijing.aliyuncs.com/HeimaCloudMusic/list5.jpg',
      title: '认真去聆听这个世界的每一分每一秒 (强烈推荐)',
      count: '362.8万'
    },
    {
      img: 'http://yjy-teach-oss.oss-cn-beijing.aliyuncs.com/HeimaCloudMusic/list5.jpg',
      title: '认真去聆听这个世界的每一分每一秒 (强烈推荐)',
      count: '362.8万'
    }
  ]
  @State refreshing: boolean = false

  @Builder
  titleBuilder(title: string) {
    Row() {
      Text(title)
        .fontColor('#fff')
        .fontWeight(700)
        .layoutWeight(1)
      Image($r('app.media.ic_more'))
        .width(22)
        .fillColor('#fff')
    }
    .width('100%')
    .height(40)
  }

  build() {
    Column({ space: 10 }) {

      //搜索区域
      Row() {
        Image($r('app.media.ic_search'))
          .width(22)
          .fillColor('#817D83')
        TextInput({ placeholder: '只因你太美🔥' })
          .placeholderColor('#817D83')
          .padding({ left: 5 })
          .fontColor('#999')
          .layoutWeight(1)
        Image($r('app.media.ic_code'))
          .width(20)
          .fillColor('#817D83')
      }
      .width('100%')
      .backgroundColor('#2D2B29')
      .border({ radius: 20 })
      .padding({ left: 8, right: 8 })

      Refresh({ refreshing: this.refreshing }) {
        Scroll(){
          Column() {
            //轮播图
            Swiper() {
              ForEach(this.swiperList, (item: string) => {
                Image(item)
                  .width('100%')
                  .border({ radius: 10 })
              })
            }
            .height(170)
            .autoPlay(true)

            //每日推荐
            this.titleBuilder("每日推荐")
            List() {
              ForEach(this.dailyRecommend, (item: recommendDailyType, index: number) => {
                ListItem() {
                  Column() {
                    Text(item.type)
                      .width('100%')
                      .height(40)
                      .backgroundColor(item.top)
                      .padding({ left: 5 })
                      .fontSize(14)
                      .fontColor('#fff')
                    Image(item.img)
                      .width('100%')
                    Text(item.title)
                      .width('100%')
                      .backgroundColor(item.bottom)
                      .padding(5)
                      .fontSize(14)
                      .fontColor('#fff')
                      .maxLines(2)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                  }
                  .width('40%')
                  .border({ radius: 10 })
                  .margin({ right: 10 })
                  .clip(true)
                }
              })
            }
            .height(230)
            .scrollBar(BarState.Off)
            .listDirection(Axis.Horizontal)

            //推荐歌单
            this.titleBuilder('推荐歌单')
            List() {
              ForEach(this.chunk(this.recommendList, 3), (group: recommendListType[], rowIndex: number) => {
                ListItem() {
                  Row({ space: 10 }) {
                    ForEach(group, (item: recommendListType, index: number) => {
                      Column() {
                        Stack() {
                          Image(item.img)
                            .width('100%')
                            .height(100)
                            .border({ radius: 8 })

                          Text(item.count)
                            .fontColor('#fff')
                            .fontSize(12)
                            .fontWeight(700)
                            .margin({ left: 5, top: 5 })
                        }
                        .alignContent(Alignment.TopStart)

                        Text(item.title)
                          .fontColor('#fff')
                          .fontSize(14)
                          .width('100%')
                          .padding(5)
                          .maxLines(2)
                          .textOverflow({ overflow: TextOverflow.Ellipsis })
                      }
                      .width('30%') // 每行三个
                    }, (item: recommendListType) => item.title) // 使用唯一 key
                  }
                  .width('100%')
                  .justifyContent(FlexAlign.SpaceBetween)
                  .padding(10)
                }
              }, (rowIndex: number) => rowIndex.toString())
            }
            .scrollBar(BarState.Off)
          }
        }
        .scrollBar(BarState.Off)
      }
      .onRefreshing(() => {
        this.refreshing = true
        setTimeout(() => {
          this.refreshing = false
        }, 3000)
      })
    }
    .width('100%').height('100%')
    .padding({
      left: 10,
      right: 10,
      top: 5,
      bottom: 5
    })
  }

  chunk<T>(arr: T[], size: number): T[][] {
    const result: T[][] = []
    for (let i = 0; i < arr.length; i += size) {
      result.push(arr.slice(i, i + size))
    }
    return result
  }
}