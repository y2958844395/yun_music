// utils/HttpUtil.ets
import { http } from '@kit.NetworkKit';
import { BusinessError } from '@kit.BasicServicesKit';
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

export class HttpUtil {
  static uploadFileWithHttpRequest(arg0: string, copyFilePath: string, fileName: string, arg3: string,
    token: string): ApiResponse<Record<string, Object>> | PromiseLike<ApiResponse<Record<string, Object>>> {
    throw new Error('Method not implemented.');
  }
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
   * 上传文件
   */
  static async uploadFile<T>(
    endpoint: string,
    mediaUrl: string,  // 文件URI
    fieldName: string,
    context: Context,  // 添加context参数
    token?: string
  ): Promise<T> {
    return new Promise((resolve, reject) => {
      try {
        // 获取缓存目录
        const cacheDir = (context as common.UIAbilityContext).cacheDir;

        // 打开文件
        const resFile = fs.openSync(mediaUrl, fs.OpenMode.READ_ONLY);

        // 复制到沙箱路径
        const newPath = cacheDir + "/" + resFile.name;
        fs.copyFileSync(resFile.fd, newPath);

        // 构造内部URI
        const realUri = "internal://cache/" + resFile.name;

        // 关闭文件句柄
        fs.closeSync(resFile);

        const httpRequest = http.createHttp();

        const headers: Record<string, string> = {
          'Content-Type': 'multipart/form-data'
        };

        if (token) {
          headers['Authorization'] = `Bearer ${token}`;
        }

        const requestOptions: http.HttpRequestOptions = {
          method: http.RequestMethod.POST,
          header: headers,
          multiFormDataList: [
            {
              name: fieldName,
              contentType: 'image/*',
              filePath: realUri,  // 使用沙箱路径
              remoteFileName: resFile.name
            }
          ]
        };

        httpRequest.request(`${BASE_URL}${endpoint}`, requestOptions)
          .then((response) => {
            // 清理缓存文件
            try {
              fs.unlinkSync(newPath);
            } catch (cleanupError) {
              console.warn('清理缓存文件失败:', cleanupError);
            }

            if (response.responseCode === 200) {
              resolve(JSON.parse(response.result as string));
            } else {
              reject(new Error(`HTTP ${response.responseCode}`));
            }
          })
          .catch((error: BusinessError) => {
            // 清理缓存文件
            try {
              fs.unlinkSync(newPath);
            } catch (cleanupError) {
              console.warn('清理缓存文件失败:', cleanupError);
            }

            console.error('上传文件失败:', error.message);
            reject(error);
          })
          .finally(() => {
            httpRequest.destroy();
          });

      } catch (fileError) {
        console.error('文件处理失败:', fileError);
        reject(fileError);
      }
    });
  }

  // 使用httpRequest上传文件
  private async uploadFileWithHttpRequest(
    endpoint: string,
    filePath: string,
    fileName: string,
    fieldName: string,
    token: string
  ): Promise<ApiResponse> {
    return new Promise((resolve, reject) => {
      const httpRequest = http.createHttp();

      try {
        const requestOptions: http.HttpRequestOptions = {
          method: http.RequestMethod.POST,
          header: {
            'Authorization': `Bearer ${token}`
            // 不要手动设置Content-Type，让系统自动处理multipart
          },
          multiFormDataList: [
            {
              name: fieldName,           // 服务器接收的字段名
              contentType: 'image/*',    // 文件类型
              filePath: filePath,        // 使用沙箱路径
              remoteFileName: fileName   // 远程文件名
            }
          ]
        };

        console.info('开始上传文件:', {
          endpoint: `${BASE_URL}${endpoint}`,
          filePath,
          fileName,
          fieldName
        });

        httpRequest.request(`${BASE_URL}${endpoint}`, requestOptions)
          .then((response: http.HttpResponse) => {
            console.info('上传响应:', {
              responseCode: response.responseCode,
              result: response.result
            });

            if (response.responseCode === 200) {
              try {
                const result = JSON.parse(response.result as string) as ApiResponse;
                resolve(result);
              } catch (parseError) {
                console.error('解析响应失败:', parseError);
                reject(new Error('响应解析失败'));
              }
            } else {
              reject(new Error(`HTTP ${response.responseCode}: ${response.result}`));
            }
          })
          .catch((error: BusinessError) => {
            console.error('HTTP请求失败:', {
              code: error.code,
              message: error.message,
              name: error.name
            });
            reject(error);
          })
          .finally(() => {
            httpRequest.destroy();
          });

      } catch (error) {
        console.error('构造请求失败:', error);
        httpRequest.destroy();
        reject(error);
      }
    });
  }
}