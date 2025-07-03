// utils/UserService.ets
import { HttpUtil } from './HttpUtil';
import { StorageUtil } from './StorageUtil';
import {
  User,
  LoginRequest,
  RegisterRequest,
  ApiResponse,
  LoginResponse,
  UpdateProfileRequest,
  ChangePasswordRequest
} from '../models/User';

interface UserResult {
  success: boolean;
  message: string;
  user?: User;
}

interface RegisterResult {
  success: boolean;
  message: string;
}

interface GeneratedTypeLiteralInterface_User {
  user: User;
}

export class UserService {
  private static readonly TOKEN_KEY = 'user_token';
  private static readonly USER_KEY = 'user_info';

  /**
   * 用户登录
   */
  static async login(loginData: LoginRequest): Promise<UserResult> {
    try {
      const response = await HttpUtil.post<ApiResponse<LoginResponse>>('/login', loginData);

      if (response.code === 200 && response.data) {
        // 保存token和用户信息
        await StorageUtil.saveObject(UserService.TOKEN_KEY, response.data.token);
        await StorageUtil.saveObject(UserService.USER_KEY, response.data.user);

        return {
          success: true,
          message: response.message || '登录成功',
          user: response.data.user
        };
      } else {
        return {
          success: false,
          message: response.message || '登录失败'
        };
      }
    } catch (error) {
      console.error('登录失败:', error);
      return {
        success: false,
        message: '网络错误，请检查网络连接'
      };
    }
  }

  /**
   * 用户注册
   */
  static async register(registerData: RegisterRequest): Promise<RegisterResult> {
    try {
      const response = await HttpUtil.post<ApiResponse<GeneratedTypeLiteralInterface_User>>('/register', registerData);

      if (response.code === 201) {
        return {
          success: true,
          message: response.message || '注册成功'
        };
      } else {
        return {
          success: false,
          message: response.message || '注册失败'
        };
      }
    } catch (error) {
      console.error('注册失败:', error);
      return {
        success: false,
        message: '网络错误，请检查网络连接'
      };
    }
  }

  /**
   * 获取用户资料
   */
  static async getProfile(): Promise<UserResult> {
    try {
      const token = await UserService.getToken();
      if (!token) {
        return {
          success: false,
          message: '未登录'
        };
      }

      const response = await HttpUtil.get<ApiResponse<GeneratedTypeLiteralInterface_User>>('/profile', token);

      if (response.code === 200 && response.data) {
        // 更新本地用户信息
        await StorageUtil.saveObject(UserService.USER_KEY, response.data.user);

        return {
          success: true,
          message: response.message || '获取成功',
          user: response.data.user
        };
      } else {
        return {
          success: false,
          message: response.message || '获取失败'
        };
      }
    } catch (error) {
      console.error('获取用户资料失败:', error);
      return {
        success: false,
        message: '网络错误，请检查网络连接'
      };
    }
  }

  /**
   * 更新用户资料
   */
  static async updateProfile(updateData: UpdateProfileRequest): Promise<UserResult> {
    try {
      const token = await UserService.getToken();
      if (!token) {
        return {
          success: false,
          message: '未登录'
        };
      }

      const response = await HttpUtil.put<ApiResponse<GeneratedTypeLiteralInterface_User>>('/profile', updateData, token);

      if (response.code === 200 && response.data) {
        // 更新本地用户信息
        await StorageUtil.saveObject(UserService.USER_KEY, response.data.user);

        return {
          success: true,
          message: response.message || '更新成功',
          user: response.data.user
        };
      } else {
        return {
          success: false,
          message: response.message || '更新失败'
        };
      }
    } catch (error) {
      console.error('更新用户资料失败:', error);
      return {
        success: false,
        message: '网络错误，请检查网络连接'
      };
    }
  }

  /**
   * 修改密码
   */
  static async changePassword(passwordData: ChangePasswordRequest): Promise<RegisterResult> {
    try {
      const token = await UserService.getToken();
      if (!token) {
        return {
          success: false,
          message: '未登录'
        };
      }

      const response = await HttpUtil.post<ApiResponse<Record<string, Object>>>('/change-password', passwordData, token);

      if (response.code === 200) {
        return {
          success: true,
          message: response.message || '密码修改成功'
        };
      } else {
        return {
          success: false,
          message: response.message || '密码修改失败'
        };
      }
    } catch (error) {
      console.error('修改密码失败:', error);
      return {
        success: false,
        message: '网络错误，请检查网络连接'
      };
    }
  }

  /**
   * 检查是否已登录
   */
  static async isLoggedIn(): Promise<boolean> {
    const token = await StorageUtil.loadObject<string>(UserService.TOKEN_KEY);
    return !!token;
  }

  /**
   * 获取当前用户信息
   */
  static async getCurrentUser(): Promise<User | null> {
    return await StorageUtil.loadObject<User>(UserService.USER_KEY) || null;
  }

  /**
   * 获取当前token
   */
  static async getToken(): Promise<string | null> {
    return await StorageUtil.loadObject<string>(UserService.TOKEN_KEY) || null;
  }

  /**
   * 用户登出
   */
  static async logout(): Promise<void> {
    await StorageUtil.clear(UserService.TOKEN_KEY);
    await StorageUtil.clear(UserService.USER_KEY);
  }
}