import { SongItemType } from "./music"

@ObservedV2
export class GlobalMusic {
  @Trace img: string = "" // 音乐封面
  @Trace name: string = "" // 音乐名称
  @Trace author: string = "" // 作者
  @Trace url: string = "" // 当前播放链接
  @Trace time: number = 0 // 播放时间
  @Trace duration: number = 0 // 音乐的总播放时长

  //歌曲列表
  @Trace playIndex: number = -1 //当前播放索引
  @Trace playList: SongItemType[] = [] //播放列表

  //播放和暂停
  @Trace isPlay: boolean = false
  //播放模式 列表播放/随机播放/单曲循环
  @Trace playMode: 'auto' | 'random' | 'repeat' = 'auto'

  //重置数据方法
  reset() {
    this.img = "" // 音乐封面
    this.name = "" // 音乐名称
    this.author = "" // 作者
    this.url = "" // 当前播放链接
    this.time = 0 // 播放时间
    this.duration = 0 // 音乐的总播放时长
    this.playIndex = -1 //当前播放索引
    this.playList = [] //播放列表
    this.isPlay = false
    this.playMode = 'auto'
  }
}