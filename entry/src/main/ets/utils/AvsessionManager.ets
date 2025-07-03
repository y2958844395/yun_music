import { avSession } from '@kit.AVSessionKit'
import backgroundTaskManager from '@ohos.resourceschedule.backgroundTaskManager'
import { wantAgent } from '@kit.AbilityKit';
import { SongItemType } from '../models/music';
import { GlobalMusic } from '../models/globalMusic';
import { AppStorageV2 } from '@kit.ArkUI';
import { playerManager } from './AvPlayerManager';

class AvsessionManager{
  session:avSession.AVSession | null =null
  playState:GlobalMusic=AppStorageV2.connect(GlobalMusic,'SONG_KEY',()=>new GlobalMusic())!

  async init(content:Context){

    this.session=await avSession.createAVSession(content,'bgPlay','audio')//上下文 自定义标签 类型
    this.registerEvent()
  }
  //申请长时任务
  async startBackgroundTask(){
    let wantAgentInfo: wantAgent.WantAgentInfo = {
      wants: [
        {
          bundleName: "com.example.a_hm_music",
          abilityName: "EntryAbility"
        }
      ],
      actionType: wantAgent.OperationType.START_ABILITY,
      requestCode: 0,
      actionFlags: [wantAgent.WantAgentFlags.UPDATE_PRESENT_FLAG],
    };
    const want = await wantAgent.getWantAgent(wantAgentInfo)
    backgroundTaskManager.startBackgroundRunning(getContext(),backgroundTaskManager.BackgroundMode.AUDIO_PLAYBACK,want)
  }

  //设置元数据
  setAVMetadata(song:SongItemType){
    this.session?.setAVMetadata({
      assetId: song.id, // 由应用指定，用于标识应用媒体库里的媒体。
      title: song.name,
      mediaImage: song.img,
      artist: song.author,
      duration:this.playState.duration
    })
  }

  //设置播放状态
  setAVPlaybackState(){

    this.session?.setAVPlaybackState({
      state:this.playState.isPlay?avSession.PlaybackState.PLAYBACK_STATE_PLAY:avSession.PlaybackState.PLAYBACK_STATE_PAUSE,
      speed:1,
      position:{
        elapsedTime:this.playState.time, //歌曲播放时间
        updateTime:new Date().getTime()  //系统时间
      },
      duration:this.playState.duration
    })
  }

  //注册事件
  registerEvent(){
    this.session?.on('play',()=>{
      playerManager.singPlay(this.playState.playList[this.playState.playIndex])
    })
    this.session?.on('pause',()=>{
      playerManager.paused()
    })
    this.session?.on('playPrevious',()=>{
      playerManager.prevPlay()
    })
    this.session?.on('playNext',()=>{
      playerManager.nextPlay()
    })
    this.session?.on('seek',(value:number)=>{
      playerManager.seekPlay(value)
    })

    this.session?.activate()
  }

  //注销会话
  async destroy(){
    await this.session?.destroy()
  }
}

export const sessionManager:AvsessionManager=new AvsessionManager()