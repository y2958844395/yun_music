import { UserService } from '../utils/UserService';
import { promptAction } from '@kit.ArkUI';

@Builder
export function RegisterPageBuilder(name: string, param: string) {
  RegisterPage({ name: name, value: param })
}

@Component
export struct RegisterPage {
  pathInfos: NavPathStack = new NavPathStack();
  name: String = '';
  @State value: String = '';

  @State username: string = '';
  @State email: string = '';
  @State password: string = '';
  @State confirmPassword: string = '';
  @State isLoading: boolean = false;
  @State showPassword: boolean = false;
  @State showConfirmPassword: boolean = false;
  @State errorMessage: string = '';

  // 输入验证
  private validateInput(): boolean {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

    if (!this.username.trim()) {
      this.errorMessage = '请输入用户名';
      return false;
    }
    if (this.username.length < 3) {
      this.errorMessage = '用户名长度至少3位';
      return false;
    }
    if (!this.email.trim()) {
      this.errorMessage = '请输入邮箱';
      return false;
    }
    if (!emailRegex.test(this.email)) {
      this.errorMessage = '请输入正确的邮箱格式';
      return false;
    }
    if (!this.password.trim()) {
      this.errorMessage = '请输入密码';
      return false;
    }
    if (this.password.length < 6) {
      this.errorMessage = '密码长度至少6位';
      return false;
    }
    if (this.password !== this.confirmPassword) {
      this.errorMessage = '两次输入的密码不一致';
      return false;
    }
    return true;
  }

  // 注册处理
  private async handleRegister() {
    if (!this.validateInput()) {
      return;
    }

    this.isLoading = true;
    this.errorMessage = '';

    try {
      const result = await UserService.register({
        username: this.username,
        email: this.email,
        password: this.password,
        confirm_password: this.confirmPassword
      });

      if (result.success) {
        // 注册成功，显示提示并跳转到登录页
        promptAction.showToast({
          message: '注册成功！请登录',
          duration: 2000
        });

        // 延迟跳转，让用户看到成功提示
        setTimeout(() => {
          this.pathInfos.pop();
        }, 1500);
      } else {
        this.errorMessage = result.message;
      }
    } catch (error) {
      console.error('注册异常:', error);
      this.errorMessage = '注册失败，请重试';
    } finally {
      this.isLoading = false;
    }
  }

  // 返回登录页
  private handleBackToLogin() {
    this.pathInfos.pop();
  }

  build() {
    NavDestination() {
      Column() {
        // 顶部装饰
        Row() {
          Circle({ width: 100, height: 100 })
            .fill('#4ECDC4')
            .margin({ top: 60, bottom: 20 })
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)

        // 标题
        Text('创建新账户')
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .margin({ bottom: 8 })

        Text('填写信息完成注册')
          .fontSize(16)
          .fontColor('#666666')
          .margin({ bottom: 40 })

        // 注册表单
        Column({ space: 20 }) {
          // 用户名输入框
          Column({ space: 8 }) {
            Row() {
              TextInput({ placeholder: '请输入用户名（至少3位）' })
                .layoutWeight(1)
                .backgroundColor(Color.Transparent)
                .border({ width: 0 })
                .placeholderColor('#CCCCCC')
                .fontSize(16)
                .onChange((value) => {
                  this.username = value;
                  this.errorMessage = '';
                })
            }
            .width('100%')
            .height(50)
            .backgroundColor('#F8F9FA')
            .borderRadius(12)
            .padding({ left: 16, right: 16 })
            .alignItems(VerticalAlign.Center)
          }

          // 邮箱输入框
          Column({ space: 8 }) {
            Row() {
              TextInput({
                placeholder: '请输入邮箱地址',
                text: this.email
              })
                .layoutWeight(1)
                .backgroundColor(Color.Transparent)
                .border({ width: 0 })
                .placeholderColor('#CCCCCC')
                .fontSize(16)
                .onChange((value) => {
                  this.email = value;
                  this.errorMessage = '';
                })
                .type(InputType.Email)
            }
            .width('100%')
            .height(50)
            .backgroundColor('#F8F9FA')
            .borderRadius(12)
            .padding({ left: 16, right: 16 })
            .alignItems(VerticalAlign.Center)
          }

          // 密码输入框
          Column({ space: 8 }) {
            Row() {
              TextInput({
                placeholder: '请输入密码（至少6位）',
                text: this.password
              })
                .layoutWeight(1)
                .backgroundColor(Color.Transparent)
                .border({ width: 0 })
                .placeholderColor('#CCCCCC')
                .fontSize(16)
                .onChange((value) => {
                  this.password = value;
                  this.errorMessage = '';
                })
                .type(InputType.Password)
            }
            .width('100%')
            .height(50)
            .backgroundColor('#F8F9FA')
            .borderRadius(12)
            .padding({ left: 16, right: 16 })
            .alignItems(VerticalAlign.Center)
          }

          // 确认密码输入框
          Column({ space: 8 }) {
            Row() {
              TextInput({
                placeholder: '请再次输入密码',
                text: this.confirmPassword
              })
                .layoutWeight(1)
                .backgroundColor(Color.Transparent)
                .border({ width: 0 })
                .placeholderColor('#CCCCCC')
                .fontSize(16)
                .onChange((value) => {
                  this.confirmPassword = value;
                  this.errorMessage = '';
                })
                .type(InputType.Password)
            }
            .width('100%')
            .height(50)
            .backgroundColor('#F8F9FA')
            .borderRadius(12)
            .padding({ left: 16, right: 16 })
            .alignItems(VerticalAlign.Center)
          }

          // 错误信息
          if (this.errorMessage) {
            Text(this.errorMessage)
              .fontSize(14)
              .fontColor('#FF4444')
              .textAlign(TextAlign.Center)
              .margin({ top: 8 })
          }

          // 注册按钮
          Button(this.isLoading ? '注册中...' : '立即注册')
            .width('100%')
            .height(50)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .borderRadius(25)
            .enabled(!this.isLoading)
            .backgroundColor(this.isLoading ? '#CCCCCC' : '#4ECDC4')
            .onClick(() => {
              this.handleRegister();
            })

          // 分割线
          Row() {
            Divider()
              .strokeWidth(1)
              .color('#EEEEEE')
              .layoutWeight(1)

            Text('或')
              .fontSize(14)
              .fontColor('#999999')
              .margin({ left: 16, right: 16 })

            Divider()
              .strokeWidth(1)
              .color('#EEEEEE')
              .layoutWeight(1)
          }
          .width('100%')
          .alignItems(VerticalAlign.Center)
          .margin({ top: 20, bottom: 20 })

          // 登录链接
          Row() {
            Text('已有账户？')
              .fontSize(14)
              .fontColor('#666666')

            Text('直接登录')
              .fontSize(14)
              .fontColor('#4ECDC4')
              .fontWeight(FontWeight.Medium)
              .onClick(() => {
                this.handleBackToLogin();
              })
          }
          .justifyContent(FlexAlign.Center)
        }
        .width('100%')
        .padding({ left: 24, right: 24 })

        Blank()
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#FFFFFF')
      .padding({ top: 0, bottom: 20 })
    }
    .onReady((ctx: NavDestinationContext) => {
      // NavDestinationContext获取当前所在的页面栈
      this.pathInfos = ctx.pathStack;
    })
  }
}