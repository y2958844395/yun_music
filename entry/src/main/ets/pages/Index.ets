import { AppStorageV2 } from '@kit.ArkUI'
import { SongItemType } from '../models/music';
import { StorageUtil } from '../utils/StorageUtil';

@Entry
@Component
struct Index {
  // @Provide('pathInfos') pathInfos: NavPathStack = new NavPathStack();
  pathInfos: NavPathStack = AppStorageV2.connect(NavPathStack, 'pathInfos', () => new NavPathStack())!
  musicHistoryList:SongItemType[]=[]
  isFirst:boolean=true
  async aboutToAppear() {
    StorageUtil.init(getContext(this));
    if (!(await StorageUtil.hasKey('musicHistoryList'))) {
      console.log('存储musicHistoryList的值')
      await StorageUtil.saveArray<SongItemType>('musicHistoryList', this.musicHistoryList);
    }
    if (!(await StorageUtil.hasKey('isFirst'))) {
      console.log('存储isFirst的值')
      await StorageUtil.saveObject<boolean>('isFirst', this.isFirst);
    }
    const flag= await StorageUtil.loadObject<boolean>('isFirst')
    console.log(`是否存在isFirst ${await StorageUtil.hasKey('isFirst')}`)
    console.log(`flag的值：${flag} ${flag===true}`)
    if (flag) {
      StorageUtil.saveObject<boolean>('isFirst',false)
      this.pathInfos.pushPathByName("GuidePage",null,false)
    }
    else{
      this.pathInfos.pushPathByName("Start", null, false)
    }
  }
  build() {
    Navigation(this.pathInfos) {

    }
    /*.onAppear(async () => {
      const flag= await StorageUtil.loadObject<boolean>('isFirst')
      console.log(`是否存在isFirst ${await StorageUtil.hasKey('isFirst')}`)
      console.log(`flag的值：${flag} ${flag===true}`)
      if (flag) {
        StorageUtil.saveObject<boolean>('isFirst',false)
        this.pathInfos.pushPathByName("GuidePage",null,false)
      }
      else{
        this.pathInfos.pushPathByName("Start", null, false)
      }
    })*/
    .hideNavBar(true)
  }
}
