// models/User.ets
export interface User {
  id: number;
  username: string;
  email: string;
  nickname: string;
  bio?: string;
  avatar: string;
  created_at: string;
}

export interface LoginRequest extends Record<string, Object> {
  username: string;
  password: string;
}

export interface RegisterRequest extends Record<string, Object> {
  username: string;
  email: string;
  password: string;
  confirm_password: string;
}

export interface ApiResponse<T = Record<string, Object>> {
  code: number;
  message: string;
  data?: T;
}

export interface UploadResult {
  success: boolean;
  message: string;
}

export interface LoginResponse {
  token: string;
  user: User;
}

export interface UpdateProfileRequest extends Record<string, Object> {
  nickname: string;
  bio: string;
}

export interface ChangePasswordRequest extends Record<string, Object> {
  old_password: string;
  new_password: string;
  confirm_password: string;
}