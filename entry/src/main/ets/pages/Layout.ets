import { Find } from "./Find";
import { Mine } from "./Mine";
import { Moment } from "./Moment";
import { Recommend } from "./Recommend";

@Builder
export function LayoutBuilder(name: string, param: string) {
  Layout({ name: name, value: param })
}

interface TabClass {
  text: string
  icon: ResourceStr
}

@Component
export struct Layout {
  pathInfos: NavPathStack = new NavPathStack();
  name: String = '';
  @State value: String = '';
  @State CurrentIndex:number=0;
  tabData: TabClass[] = [
    {text: '推荐', icon: $r('app.media.ic_recommend')},
    {text: '发现', icon: $r('app.media.ic_find')},
    {text: '动态', icon: $r('app.media.ic_moment')},
    {text: '我的', icon: $r('app.media.ic_mine')}
  ]

  @Builder tabBuilder(item:TabClass,index:number){
   Column({space:5}){
     Image(item.icon)
       .width(24)
       .fillColor(this.CurrentIndex === index?'#E85A88':'#63AAAA')
     Text(item.text)
       .fontSize(14)
       .fontColor(this.CurrentIndex === index?'#E85A88':'#63AAAA')
   }
   .justifyContent(FlexAlign.Center)
  }

  build() {
    NavDestination() {
      Tabs({barPosition:BarPosition.End}){
       ForEach(this.tabData,(item:TabClass,index:number)=>{
         TabContent(){
           if (this.CurrentIndex===0) {
             Recommend()
           }else if (this.CurrentIndex===1) {
             Find()
           }else if (this.CurrentIndex===2) {
             Moment()
           }else if (this.CurrentIndex===3) {
             Mine()
           }
         }.tabBar(this.tabBuilder(item,index))
         .backgroundColor('#131215')
         .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
       })
      }
      .backgroundColor('#3B3F42')
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
      .onChange((index:number)=>{
        this.CurrentIndex=index
      })
      .scrollable(false)
    }
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    .onReady((ctx: NavDestinationContext) => {
      //NavDestinationContext获取当前所在的页面栈
      this.pathInfos = ctx.pathStack;
    })


  }
}

