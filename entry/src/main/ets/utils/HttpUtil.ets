// utils/HttpUtil.ets
import { http } from '@kit.NetworkKit';
import { BusinessError, request } from '@kit.BasicServicesKit';
import fs from '@ohos.file.fs';
import { common } from '@kit.AbilityKit';
import { rcp } from '@kit.RemoteCommunicationKit';
import { picker } from '@kit.CoreFileKit';
import { promptAction } from '@kit.ArkUI';
import { ApiResponse } from '../models/User';

export const BASE_URL = 'http://45.207.208.214:5000/api';

interface HttpHeaders {
  'Content-Type': string;
  Authorization?: string;
}

interface FileInfoForUpload {
  sandboxPath: string; // internal:// uri
  fileName: string;
}

/**
 * @interface PreparedFileInfo
 * [导出] 定义了为上传而准备的文件的完整结构。
 * 这是该数据结构的唯一真实来源 (Single Source of Truth)。
 */
export interface PreparedFileInfo {
  copyPath: string;    // 在缓存中的完整物理路径（用于后续清理）
  sandboxPath: string; // internal:// 协议的沙箱URI（用于上传）
  fileName: string;    // 生成的唯一文件名
}

interface UploadHeader {
  body: string;
  // Allows for other potential properties on the header object without causing errors.

}

export class HttpUtil {
  /**
   * 发送POST请求
   */
  static async post<T>(url: string, data: Record<string, Object> | Object, token?: string): Promise<T> {
    return new Promise((resolve, reject) => {
      const httpRequest = http.createHttp();

      // 构建请求头
      const headers: HttpHeaders = {
        'Content-Type': 'application/json'
      };

      if (token) {
        headers.Authorization = `Bearer ${token}`;
      }

      const options: http.HttpRequestOptions = {
        method: http.RequestMethod.POST,
        header: headers,
        extraData: JSON.stringify(data)
      };

      httpRequest.request(`${BASE_URL}${url}`, options)
        .then((response) => {
          if (response.responseCode === 200 || response.responseCode === 201) {
            try {
              const result = JSON.parse(response.result as string) as T;
              resolve(result);
            } catch (parseError) {
              reject(new Error('响应解析失败'));
            }
          } else {
            reject(new Error(`HTTP ${response.responseCode}`));
          }
        })
        .catch((error: Error) => {
          reject(error);
        })
        .finally(() => {
          httpRequest.destroy();
        });
    });
  }

  /**
   * 发送GET请求
   */
  static async get<T>(url: string, token?: string): Promise<T> {
    return new Promise((resolve, reject) => {
      const httpRequest = http.createHttp();

      // 构建请求头
      const headers: HttpHeaders = {
        'Content-Type': 'application/json'
      };

      if (token) {
        headers.Authorization = `Bearer ${token}`;
      }

      const options: http.HttpRequestOptions = {
        method: http.RequestMethod.GET,
        header: headers
      };

      httpRequest.request(`${BASE_URL}${url}`, options)
        .then((response) => {
          if (response.responseCode === 200) {
            try {
              const result = JSON.parse(response.result as string) as T;
              resolve(result);
            } catch (parseError) {
              reject(new Error('响应解析失败'));
            }
          } else {
            reject(new Error(`HTTP ${response.responseCode}`));
          }
        })
        .catch((error: Error) => {
          reject(error);
        })
        .finally(() => {
          httpRequest.destroy();
        });
    });
  }

  /**
   * 发送PUT请求
   */
  static async put<T>(url: string, data: Record<string, Object> | Object, token?: string): Promise<T> {
    return new Promise((resolve, reject) => {
      const httpRequest = http.createHttp();

      // 构建请求头
      const headers: HttpHeaders = {
        'Content-Type': 'application/json'
      };

      if (token) {
        headers.Authorization = `Bearer ${token}`;
      }

      const options: http.HttpRequestOptions = {
        method: http.RequestMethod.PUT,
        header: headers,
        extraData: JSON.stringify(data)
      };

      httpRequest.request(`${BASE_URL}${url}`, options)
        .then((response) => {
          if (response.responseCode === 200) {
            try {
              const result = JSON.parse(response.result as string) as T;
              resolve(result);
            } catch (parseError) {
              reject(new Error('响应解析失败'));
            }
          } else {
            reject(new Error(`HTTP ${response.responseCode}`));
          }
        })
        .catch((error: Error) => {
          reject(error);
        })
        .finally(() => {
          httpRequest.destroy();
        });
    });
  }

  /**
   * 发送DELETE请求
   */
  static async delete<T>(url: string, token?: string): Promise<T> {
    return new Promise((resolve, reject) => {
      const httpRequest = http.createHttp();

      // 构建请求头
      const headers: HttpHeaders = {
        'Content-Type': 'application/json'
      };

      if (token) {
        headers.Authorization = `Bearer ${token}`;
      }

      const options: http.HttpRequestOptions = {
        method: http.RequestMethod.DELETE,
        header: headers
      };

      httpRequest.request(`${BASE_URL}${url}`, options)
        .then((response) => {
          if (response.responseCode === 200) {
            try {
              const result = JSON.parse(response.result as string) as T;
              resolve(result);
            } catch (parseError) {
              reject(new Error('响应解析失败'));
            }
          } else {
            reject(new Error(`HTTP ${response.responseCode}`));
          }
        })
        .catch((error: Error) => {
          reject(error);
        })
        .finally(() => {
          httpRequest.destroy();
        });
    });
  }


  /**
   * [修正] 上传文件，现在使用统一的 PreparedFileInfo 类型。
   * @param endpoint API的路径，例如 '/upload-avatar'
   * @param fileInfo 经过处理后的文件信息对象
   * @param fieldName 后端接收文件时在表单中使用的字段名
   * @param context 应用上下文
   * @param token 可选的认证令牌
   * @returns Promise<T>
   */
  static async uploadFile<T>(
    endpoint: string,
    fileInfo: PreparedFileInfo, // <-- 使用统一的、导出的接口
    fieldName: string,
    context: common.Context,
    token?: string
  ): Promise<T> {
    return new Promise((resolve, reject) => {
      // 函数的其余逻辑保持不变。
      // 它实际上只需要 fileInfo.sandboxPath 和 fileInfo.fileName，
      // 但接受完整的对象没有问题，并且通过使用一致的类型简化了代码。
      const fileExtension = fileInfo.fileName.slice(fileInfo.fileName.lastIndexOf('.') + 1).toLowerCase();
      const files: Array<request.File> = [{
        uri: fileInfo.sandboxPath,
        filename: fileInfo.fileName,
        name: fieldName,
        type: `image/${fileExtension}`
      }];

      const header: Record<string, string> = {};
      if (token) {
        header['Authorization'] = `Bearer ${token}`;
      }

      const uploadConfig: request.UploadConfig = {
        url: `${BASE_URL}${endpoint}`,
        header: header,
        method: http.RequestMethod.POST,
        files: files,
        data: []
      };

      request.uploadFile(context, uploadConfig)
        .then(uploadTask => {
          uploadTask.on('headerReceive', (header) => {
            try {
              const responseBody = (header as UploadHeader).body;
              if (responseBody) {
                resolve(JSON.parse(responseBody) as T);
              } else {
                reject(new Error('服务器响应体为空。'));
              }
            } catch (e) {
              console.error("解析上传响应失败:", e);
              reject(new Error("无法解析服务器响应。"));
            }
          });

          uploadTask.on('fail', (err) => {
            console.error("文件上传任务失败:", err);
            reject(new Error('文件上传失败。'));
          });
        })
        .catch((err: BusinessError) => {
          console.error(`发起上传请求失败: ${err.code}, ${err.message}`);
          reject(err);
        });
    });
  }
}