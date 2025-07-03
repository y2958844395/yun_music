@Builder
export function StartBuilder(name: string, param: string) {
  Start({ name: name, value: param })
}


@Component
export struct Start {
  pathInfos: NavPathStack = new NavPathStack();
  name: String = '';
  @State value: String = '';
  timerId:number=0;
  //过三秒自动跳转到Layout ->Start页面打开时计时 3秒后跳转
  aboutToAppear(): void { //生命周期  Start页面开始时调用
    this.timerId=setTimeout(()=>{
      this.pathInfos.replacePathByName("Layout",null,false)
    },3000)
  }
  build() {
    NavDestination() {
      Stack({alignContent:Alignment.TopEnd}) {
        Image($r('app.media.ad'))
          .width('100%')
          .height('100%')
          .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
        Button('跳过')
          .backgroundColor(Color.Gray)
          .margin(15)
          .onClick(()=>{
            clearTimeout(this.timerId);
            this.pathInfos.replacePathByName("Layout",null,false)
          })
      }
    }
    .onReady((ctx: NavDestinationContext) => {
      //NavDestinationContext获取当前所在的页面栈
      this.pathInfos = ctx.pathStack;
    })

  }
}

