import { media } from '@kit.MediaKit'
import { GlobalMusic } from '../models/globalMusic'
import { SongItemType } from '../models/music'
import { AppStorageV2 } from '@kit.ArkUI'
import { sessionManager } from './AvsessionManager'
import { StorageUtil } from './StorageUtil'

class AvPlayerManager {
  //属性+方法
  //播放器
  player: media.AVPlayer | null = null
  //共享播放数据
  currentSong: GlobalMusic = AppStorageV2.connect(GlobalMusic, 'SONG_KEY', () => new GlobalMusic())!

  //定义方法，创建播放器+监听播放器的状态
  async init() {
    if (!this.player) {
      this.player = await media.createAVPlayer()
    }

    //监听状态变化
    this.player.on('stateChange', (state) => {
      if (state === 'initialized') {
        this.player?.prepare()
      } else if (state === 'prepared') {
        this.player?.play()
        this.currentSong.isPlay = true
      } else if (state === 'completed') {
        this.nextPlay(true)
      } else if (state === 'released') {
        this.currentSong.reset()
      }
    })

    //监听歌曲总时间时间变化
    this.player.on('durationUpdate', (duration) => {
      this.currentSong.duration = duration
      sessionManager.setAVMetadata(this.currentSong.playList[this.currentSong.playIndex])
    })

    //监听歌曲播放时间变化
    this.player.on('timeUpdate', (time) => {
      this.currentSong.time = time
      //设置播放状态
      sessionManager.setAVPlaybackState()
    })


  }

  //播放歌曲 设置播放资源
  /*singPlay(song:SongItemType){
    this.player!.url=song.url
    this.currentSong.img=song.img
  }*/
  async singPlay(song: SongItemType) {

    // console.log('song的内容：',JSON.stringify(song, null, 2))
    StorageUtil.init(getContext(this));
    let musicHistoryList = await StorageUtil.loadArray<SongItemType>('musicHistoryList');
    // console.log('musicHistoryList数据类型',Array.isArray(musicHistoryList))
    if (musicHistoryList.length!==0) {
      const index = musicHistoryList.findIndex(item => item.id === song.id);
      // console.log(`musicHistoryList[index].id: ${musicHistoryList[index].id} `)
      // console.log(`song.id: ${song.id} `)
      // console.log(`index为:${index}`)
      // console.log(`musicHistoryList[0].id: ${musicHistoryList[0].id} `)
      if (index !==-1) {
        console.log('数组中存在，开始删除')
        musicHistoryList.splice(index,1)
      }
    }else {
      console.log('第一首歌')
    }
    musicHistoryList.push(song)
    // console.log('musicHistoryList数据',musicHistoryList.toString())
    // console.log('musicHistoryList数据',musicHistoryList.length)
    StorageUtil.saveArray('musicHistoryList',musicHistoryList)

    // musicHistoryList.push(song)
    // console.log(`存储数据：${song.img}`)
    //申请长时任务
    sessionManager.startBackgroundTask()
    //设置播放状态
    sessionManager.setAVPlaybackState()


    //判断是否在列表
    const inList = this.currentSong.playList.some(item => item.id === song.id)
    if (inList) {
      //在列表里面
      if (this.currentSong.url === song.url) {
        this.player?.play()
        this.currentSong.isPlay = true
      } else {
        //设置新的索引 切歌
        this.currentSong.playIndex = this.currentSong.playList.findIndex(item => item.id === song.id)
        //切歌
        this.changeSong()
      }
    } else {
      //不在列表 添加到列表 切换歌曲
      this.currentSong.playList.unshift(song)
      this.currentSong.playIndex = 0
      //切换歌曲
      this.changeSong()
    }
  }

  //切换歌曲 重置播放器
  async changeSong() {
    await this.player?.reset()
    this.currentSong.duration = 0
    this.currentSong.time = 0
    this.currentSong.img = this.currentSong.playList[this.currentSong.playIndex].img
    this.currentSong.name = this.currentSong.playList[this.currentSong.playIndex].name
    this.currentSong.author = this.currentSong.playList[this.currentSong.playIndex].author
    this.currentSong.url = this.currentSong.playList[this.currentSong.playIndex].url
    this.player!.url = this.currentSong.url
  }

  //跳转播放进度 seek
  seekPlay(value: number) {
    this.player?.seek(value)
  }

  //暂停
  paused() {
    this.player?.pause()
    this.currentSong.isPlay = false
    //设置播放状态
    sessionManager.setAVPlaybackState()
  }

  //上一首
  prevPlay() {
    if (this.currentSong.playMode === 'random') {
      //随机
      //Math.random()[0,1)随机小数  Math.floor()向下取整
      this.currentSong.playIndex = Math.floor(Math.random() * this.currentSong.playList.length)

    } else {
      this.currentSong.playIndex--
      if (this.currentSong.playIndex < 0) {
        this.currentSong.playIndex = this.currentSong.playList.length - 1
      }
    }
    this.singPlay(this.currentSong.playList[this.currentSong.playIndex])
  }

  //下一首  根据播放模式改变
  //重复播放 播放模式为repeat且  播放器自动下一首(completed状态)
  //随机播放 去一个随机播放
  nextPlay(autoNextPlay?: boolean) {

    if (this.currentSong.playMode === 'repeat' && autoNextPlay) {
      //循环  索引不变
      this.currentSong.playIndex = this.currentSong.playIndex
    } else if (this.currentSong.playMode === 'random') {
      //随机
      //Math.random()[0,1)随机小数  Math.floor()向下取整
      this.currentSong.playIndex = Math.floor(Math.random() * this.currentSong.playList.length)
    } else {
      //列表
      this.currentSong.playIndex++
      if (this.currentSong.playIndex >= this.currentSong.playList.length) {
        this.currentSong.playIndex = 0
      }
    }
    this.singPlay(this.currentSong.playList[this.currentSong.playIndex])
  }

  //移除列表中的歌曲
  removeSong(index: number) {

    if (index === this.currentSong.playIndex) {
      //删除的是正在播放的 判断歌曲列表是否为1
      if (this.currentSong.playList.length > 1) {
        //列表里有多首歌曲
        this.currentSong.playList.splice(index, 1)
        if (this.currentSong.playIndex >= (this.currentSong.playList.length)) {
          this.currentSong.playIndex = 0
        }
        this.singPlay(this.currentSong.playList[this.currentSong.playIndex])
      } else {
        //列表里只有一首歌
        this.player?.reset()
        this.currentSong.reset()
      }

    } else {
      //删除的不是正在播放的
      //如果在播放的前面
      if (index < this.currentSong.playIndex) {
        this.currentSong.playIndex -= 1
      }
      this.currentSong.playList.splice(index, 1)
    }
  }

  //释放播放器和播放数据
  async release() {
    await this.player?.release()
  }
}


export const playerManager: AvPlayerManager = new AvPlayerManager()




















