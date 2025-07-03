@Builder
export function GuidePageBuilder(name: string, param: string) {
  GuidePage({ name: name, value: param })
}


@Component
export struct GuidePage {
  pathInfos: NavPathStack = new NavPathStack();
  name: String = '';
  @State value: String = '';
  timerId: number = 0;



  build() {
    NavDestination() {
      Swiper() {
        RelativeContainer() {
          Text('欢迎使用云音乐')
            .width('auto')
            .height(50)
              // .border({width:1})
            .fontSize(30)
              // .fontFamily("yrt.ttf")
            .fontColor('#FFD700')
            .textAlign(TextAlign.Center)
            .margin({ top: -50 })
            .alignRules({
              center: { anchor: "__container__", align: VerticalAlign.Center },
              middle: { anchor: "__container__", align: HorizontalAlign.Center },
            })

        }
        .width('100%').height('100%')
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])

        RelativeContainer() {
          Text('更多惊喜功能等你发现')
            .width('auto')
            .height(50)
            .fontSize(30)
            .fontColor('#FFD700')
            .textAlign(TextAlign.Center)
            .margin({ top: -50 })
            .alignRules({
              top: { anchor: "__container__", align: VerticalAlign.Center },
              middle: { anchor: "__container__", align: HorizontalAlign.Center }
            })
            .id("text")

          Button('进入软件')
            .width('auto')
            .height(50)
            .fontSize(30)
            .fontColor('#fff')
            .backgroundColor("#FFA500")
            .margin({ bottom: 100 })
            .alignRules({
              bottom: { anchor: "__container__", align: VerticalAlign.Bottom },
              middle: { anchor: "__container__", align: HorizontalAlign.Center },
            })
            .onClick(()=>{
              this.pathInfos.replacePathByName("Layout",null,false)
            })
        }
        .width('100%').height('100%')
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])

      }
      .backgroundColor('#2C2C2C')
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])

    }
    .onReady((ctx: NavDestinationContext) => {
      //NavDestinationContext获取当前所在的页面栈
      this.pathInfos = ctx.pathStack;
    })

  }
}

