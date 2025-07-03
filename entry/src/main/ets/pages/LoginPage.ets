import { UserService } from '../utils/UserService';

@Builder
export function LoginPageBuilder(name: string, param: string) {
  LoginPage({ name: name, value: param })
}

@Component
export struct LoginPage {
  pathInfos: NavPathStack = new NavPathStack();
  name: String = '';
  @State value: String = '';

  @State username: string = '';
  @State password: string = '';
  @State isLoading: boolean = false;
  @State showPassword: boolean = false;
  @State errorMessage: string = '';

  // 输入验证
  private validateInput(): boolean {
    if (!this.username.trim()) {
      this.errorMessage = '请输入用户名';
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
    return true;
  }

  // 登录处理
  private async handleLogin() {
    if (!this.validateInput()) {
      return;
    }

    this.isLoading = true;
    this.errorMessage = '';

    try {
      const result = await UserService.login({
        username: this.username,
        password: this.password
      });

      if (result.success) {
        // 登录成功，跳转到主页
        this.pathInfos.clear();
        this.pathInfos.pushPathByName("Layout", null, false);
      } else {
        this.errorMessage = result.message;
      }
    } catch (error) {
      this.errorMessage = '登录失败，请重试';
    } finally {
      this.isLoading = false;
    }
  }

  // 注册页面跳转
  private handleRegister() {
    this.pathInfos.pushPathByName('RegisterPage', null);
  }

  build() {
    NavDestination() {
      Column() {
        // 顶部装饰
        Row() {
          Circle({ width: 100, height: 100 })
            .fill('#FF6B6B')
            .margin({ top: 60, bottom: 20 })
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)

        // 标题
        Text('欢迎回来')
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .margin({ bottom: 8 })

        Text('登录您的账户')
          .fontSize(16)
          .fontColor('#666666')
          .margin({ bottom: 40 })

        // 登录表单
        Column({ space: 20 }) {
          // 用户名输入框
          Column({ space: 8 }) {
            Row() {
              TextInput({ placeholder: '请输入用户名' })
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

          // 密码输入框
          Column({ space: 8 }) {
            Row() {
              TextInput({
                placeholder: '请输入密码',
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

          // 错误信息
          if (this.errorMessage) {
            Text(this.errorMessage)
              .fontSize(14)
              .fontColor('#FF4444')
              .textAlign(TextAlign.Center)
              .margin({ top: 8 })
          }

          // 登录按钮
          Button(this.isLoading ? '登录中...' : '登录')
            .width('100%')
            .height(50)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .borderRadius(25)
            .enabled(!this.isLoading)
            .backgroundColor(this.isLoading ? '#CCCCCC' : '#FF6B6B')
            .onClick(() => {
              this.handleLogin();
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

          // 注册链接
          Row() {
            Text('还没有账户？')
              .fontSize(14)
              .fontColor('#666666')

            Text('立即注册')
              .fontSize(14)
              .fontColor('#FF6B6B')
              .fontWeight(FontWeight.Medium)
              .onClick(() => {
                this.handleRegister();
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