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
          Image($r('app.media.ydy1'))
            .width('100%')
            .height('100%')
            .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])

        }
        .width('100%').height('100%')
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])

        RelativeContainer() {
          Image($r('app.media.ydy2'))
            .width('100%')
            .height('100%')
            .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])

          Button(){
            Image($r("app.media.button1"))
          }
          .width(270)
          .height(100)
          .alignRules({
            bottom: { anchor: "__container__", align: VerticalAlign.Bottom },
            middle: { anchor: "__container__", align: HorizontalAlign.Center },
          })
          .margin({bottom:100})
          .onClick(()=>{
            this.pathInfos.replacePathByName("Layout",null,false)
          })
        }
        .width('100%').height('100%')
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])

      }
      .loop(false)
      .effectMode(EdgeEffect.None)
      .indicator(new DotIndicator().color('#fff').selectedItemWidth('20'))
      .backgroundColor('#2C2C2C')
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])

    }
    .onReady((ctx: NavDestinationContext) => {
      //NavDestinationContext获取当前所在的页面栈
      this.pathInfos = ctx.pathStack;
    })

  }
}

