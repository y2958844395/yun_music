import { SongItemType } from "../models/music"
import { AppStorageV2 } from "@kit.ArkUI";
import { playerManager } from "../utils/AvPlayerManager";
import { GlobalMusic } from "../models/globalMusic";
import { StorageUtil } from "../utils/StorageUtil";


@ComponentV2
export struct Moment {

  @Local songs: SongItemType[]=[]
  pathInfos:NavPathStack=AppStorageV2.connect(NavPathStack,'pathInfos',()=>new NavPathStack())!
  // 当前播放的歌曲
  @Local
  playState: GlobalMusic = AppStorageV2.connect(GlobalMusic, 'SONG_KEY', () => new GlobalMusic())!

  async aboutToAppear() {
    let songData = await StorageUtil.loadArray<SongItemType>('musicHistoryList');
    console.log('读取数据songData：', songData);
    if (songData) {
      /*let song: SongItemType = songData;
      this.songs.push(songData)
      console.log('读取数据：', song.name);
      console.log( JSON.stringify(this.songs));
      console.log(this.songs[0].img);
      console.log(this.songs[0].name);
      console.log(this.songs[0].author);
      console.log(this.songs[0].url);
      console.log(this.songs[0].id);*/
      this.songs=songData.reverse()
      // ✅ 安全使用
    } else {
      // 👇 处理 undefined 情况，例如赋默认值或报错
      console.warn('未找到 song_key 对应的对象');
    }

  }
  build() {
    Column() {
      Text('历史记录')
        .fontColor('#fff')
        .width('100%')
        .margin({ bottom: 10 })
      List() {
       /* ListItem(){
          Text(`数组长度：${this.songs.length}`).fontColor('#fff')
        }*/
        ForEach(this.songs, (item: SongItemType, index: number) => {
          ListItem() {
            Row() {
              // 图
              Stack() {
                Image(item.img)
                  .width(80)
                  .border({ radius: 8 })
                  .margin({ right: 10 })
                if (item.url===this.playState.url && this.playState.isPlay===true) {
                  Image($r('app.media.wave'))
                    .width(24)
                }else if(item.url===this.playState.url && this.playState.isPlay===false){
                  Image($r('app.media.ic_play'))
                    .width(35)
                }
              }
              .onClick(()=>{
                if (item.url === this.playState.url && this.playState.isPlay === true) {
                  playerManager.paused()
                }
                else if(item.url===this.playState.url && this.playState.isPlay===false){
                  playerManager.singPlay(this.playState.playList[this.playState.playIndex])
                }
              })

              // 字
              Column() {
                Text(item.name)
                  .fontColor('#F3F3F3')
                  .width('100%')
                  .fontWeight(700)
                  .margin({ bottom: 15 })
                Row() {
                  Text('VIP')
                    .fontColor('#9A8E28')
                    .border({ width: 1, color: '#9A8E28', radius: 12 })
                    .padding({
                      left: 5,
                      right: 5,
                      top: 3,
                      bottom: 3
                    })
                    .margin({ right: 10 })
                  Text(item.author)
                    .fontColor('#696969')
                }
                .width('100%')
              }
              .layoutWeight(1)

              // 更多
              Image($r('app.media.ic_more'))
                .width(24)
                .fillColor('#FEFEFE')
            }
            .width('100%')
            .height(80)
            // .backgroundColor(Color.Pink)
            .margin({ bottom: 10 })
          }.onClick(()=>{

            this.pathInfos.pushPathByName('Play',null,false)
            playerManager.singPlay(item)
          })
        })
      }
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#131313')
    .padding({ left: 10, right: 10 })
    // 扩充组件安全区域
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }
}