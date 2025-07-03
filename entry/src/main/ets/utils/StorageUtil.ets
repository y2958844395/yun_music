import preferences from '@ohos.data.preferences';  // ✅ 默认导入

const STORAGE_NAME = 'my_app_storage';

export class StorageUtil {
  private static prefPromise: Promise<preferences.Preferences> | null = null;
  private static context: Context;

  /** 必须先调用此方法初始化 context */
  public static init(ctx: Context): void {
    StorageUtil.context = ctx;
  }

  private static async getPreferences(): Promise<preferences.Preferences> {
    if (!StorageUtil.context) {
      throw new Error('[StorageUtil] 未调用 init(context)');
    }

    if (!StorageUtil.prefPromise) {
      StorageUtil.prefPromise = preferences.getPreferences(StorageUtil.context, STORAGE_NAME).catch((err:object) => {
        if (err instanceof Error) {
          console.error('[StorageUtil] 初始化失败:', err.message);
          throw err;
        } else {
          console.error('[StorageUtil] 初始化失败:', String(err));
          throw new Error(String(err));
        }
      });
    }

    return StorageUtil.prefPromise;
  }

  /** 存储任意对象 */
  public static async saveObject<T>(key: string, obj: T): Promise<void> {
    console.log('开始存储数据')
    if (obj === undefined) {
      console.log('0')
      console.warn(`[StorageUtil] 忽略保存，key=${key}，值为 undefined`);
      return;
    }
    try {
      const pref = await StorageUtil.getPreferences();
      const jsonStr = JSON.stringify(obj);
      await pref.put(key, jsonStr);
      await pref.flush();
    } catch (err) {
      console.error(`[StorageUtil] 存储对象失败，key=${key}:`, err);
    }
  }

  /** 读取对象（不存在则返回 undefined） */
  public static async loadObject<T>(key: string): Promise<T | undefined> {
    try {
      const pref = await StorageUtil.getPreferences();
      // const jsonStr = await pref.get(key, null);
      // const jsonStr: string | null = await pref.get(key, '');

      const jsonStr = (await pref.get(key, '')) as string;

      if (typeof jsonStr !== 'string' || !jsonStr.trim()) {
        return undefined;
      }

      return JSON.parse(jsonStr) as T;
    } catch (err) {
      console.error(`[StorageUtil] 加载对象失败，key=${key}:`, err);
      return undefined;
    }
  }

  /** 存储数组 */
  public static async saveArray<T>(key: string, arr: T[]): Promise<void> {
    try {
      const pref = await StorageUtil.getPreferences();
      const jsonStr = JSON.stringify(arr ?? []);
      await pref.put(key, jsonStr);
      await pref.flush();
    } catch (err) {
      console.error(`[StorageUtil] 存储数组失败，key=${key}:`, err);
    }
  }

  /** 加载数组（失败时返回空数组） */
  public static async loadArray<T>(key: string): Promise<T[]> {
    try {
      const pref = await StorageUtil.getPreferences();
      const jsonStr = await pref.get(key, '[]');

      if (typeof jsonStr !== 'string') {
        console.warn(`[StorageUtil] 加载数组失败，key=${key} 返回非字符串类型`);
        return [];
      }

      return JSON.parse(jsonStr) as T[];
    } catch (err) {
      if (err instanceof Error) {
        console.error(`[StorageUtil] 加载数组失败，key=${key}:`, err.message);
      } else {
        console.error(`[StorageUtil] 加载数组失败，key=${key}:`, String(err));
      }
      return [];
    }
  }


  /** 判断某个 key 是否存在 */
  public static async hasKey(key: string): Promise<boolean> {
    try {
      const pref = await StorageUtil.getPreferences();
      const value = await pref.get(key, null);
      return value !== null && value !== undefined;
    } catch (err) {
      if (err instanceof Error) {
        console.error(`[StorageUtil] 查询 key 存在性失败，key=${key}:`, err.message);
      } else {
        console.error(`[StorageUtil] 查询 key 存在性失败，key=${key}:`, String(err));
      }
      return false;
    }
  }


  /** 删除指定 key */
  public static async clear(key: string): Promise<void> {
    try {
      const pref = await StorageUtil.getPreferences();
      await pref.delete(key);
      await pref.flush();
    } catch (err) {
      console.error(`[StorageUtil] 删除失败，key=${key}:`, err);
    }
  }

  /** 清空所有数据 */
  public static async clearAll(): Promise<void> {
    try {
      const pref = await StorageUtil.getPreferences();
      await pref.clear();
      await pref.flush();
    } catch (err) {
      console.error('[StorageUtil] 清空失败:', err);
    }
  }
}
