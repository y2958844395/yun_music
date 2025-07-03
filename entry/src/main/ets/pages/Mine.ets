@Component
export struct Mine {
  build() {
    RelativeContainer() {
      RelativeContainer() {
        Image($r('app.media.avatar'))
          .width(100)
          .borderRadius(100)
          .border({width:1})
          .alignRules({
            left: { anchor: "__container__", align: HorizontalAlign.Start },
            top: { anchor: "__container__", align: VerticalAlign.Top }
          })
          .id("avatar")
        Text('用户名')
          .fontSize(30)
          .fontColor('#fff')
          .alignRules({
            left:{anchor:"avatar",align:HorizontalAlign.End},
          })
          .margin({left:5,top:10})
        Image($r('app.media.ewm'))
          .width(40)
          .alignRules({
            right:{anchor:"__container__",align:HorizontalAlign.End},
          })
        Row({space:10}){
          Text('关注数：100')
            .fontSize(20)
            .fontWeight(500)
            .fontColor('#fff')
          Text('粉丝数：100')
            .fontSize(20)
            .fontWeight(500)
            .fontColor('#fff')
        }
        .alignRules({
          bottom:{anchor:"__container__",align:VerticalAlign.Bottom},
          middle:{anchor:"__container__",align:HorizontalAlign.Center}
        })
      }
      .width('100%')
      .height(150)
      .backgroundColor('#ff414141')
      .padding({left:5,right:5,top:5,bottom:15})
      .border({radius:8})
      .id('rc1')

      RelativeContainer(){
        List(){
          ListItem(){
            Row(){
              Text('设置')
                .fontSize(30)
                .fontColor('#fff')
              Blank()
                .layoutWeight(1)
              Image($r("app.media.arrow_right_s_line"))
                .width(45)
            }
          }
          .height(50)

          ListItem(){
            Row(){
              Text('设置')
                .fontSize(30)
                .fontColor('#fff')
              Blank()
                .layoutWeight(1)
              Image($r("app.media.arrow_right_s_line"))
                .width(45)
            }
          }
          .height(50)

          ListItem(){
            Row(){
              Text('设置')
                .fontSize(30)
                .fontColor('#fff')
              Blank()
                .layoutWeight(1)
              Image($r("app.media.arrow_right_s_line"))
                .width(45)
            }
          }
          .height(50)

          ListItem(){
            Row(){
              Text('设置')
                .fontSize(30)
                .fontColor('#fff')
              Blank()
                .layoutWeight(1)
              Image($r("app.media.arrow_right_s_line"))
                .width(45)
            }
          }
          .height(50)

          ListItem(){
            Row(){
              Text('关于')
                .fontSize(30)
                .fontColor('#fff')
              Blank()
                .layoutWeight(1)
              Image($r("app.media.arrow_right_s_line"))
                .width(45)
            }
          }
          .height(50)

        }
        .divider({
          strokeWidth:2,
          color:'#80000000',
          startMargin:30,
          endMargin:30
        })
      }
      .width('100%')
      .layoutWeight(1)
      .backgroundColor('#ff414141')
      .padding({left:10,right:5,top:10,bottom:15})
      .border({radius:8})
      .margin({top:20})
      .alignRules({
        top:{anchor:"rc1",align:VerticalAlign.Bottom}
      })
      .id('rc2')
    }
    .width('95%')
    .height('100%')

    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])

  }
}