interface User {
  id: number;
  email: string;
  name: string;
  nickname: string;
  category: string;
  rank_medal: string;
  rank_stars: number;
  role: string;
  full_display_name: string;
  can_join_immortal_list: boolean;
}

interface AuthResponse {
  data: {
    id: string;
    type: string;
    attributes: User;
  };
  meta: {
    token: string;
    expires_in: number;
  };
}

interface LoginCredentials {
  email: string;
  password: string;
}

interface RegisterData {
  email: string;
  password: string;
  password_confirmation: string;
  name: string;
  nickname: string;
  phone: string;
  rank_medal: string;
  rank_stars: number;
  preferred_position: string;
  positions: string[];
}

class AuthService {
  private readonly API_BASE = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3000';
  private readonly TOKEN_KEY = 'dota_auth_token';

  async register(data: RegisterData): Promise<AuthResponse> {
    const response = await fetch(`${this.API_BASE}/api/v1/auth/register`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/vnd.api+json',
      },
      body: JSON.stringify({
        data: {
          type: 'users',
          attributes: data,
        },
      }),
    });

    if (!response.ok) {
      const errorData = await response.json();
      throw new Error(errorData.errors?.[0]?.detail || 'Registration failed');
    }

    const result: AuthResponse = await response.json();
    this.setToken(result.meta.token);
    return result;
  }

  async login(credentials: LoginCredentials): Promise<AuthResponse> {
    const response = await fetch(`${this.API_BASE}/api/v1/auth/login`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/vnd.api+json',
      },
      body: JSON.stringify({
        data: {
          type: 'auth',
          attributes: credentials,
        },
      }),
    });

    if (!response.ok) {
      const errorData = await response.json();
      throw new Error(errorData.errors?.[0]?.detail || 'Login failed');
    }

    const result: AuthResponse = await response.json();
    this.setToken(result.meta.token);
    return result;
  }

  async me(): Promise<User | null> {
    const token = this.getToken();
    if (!token) return null;

    try {
      const response = await fetch(`${this.API_BASE}/api/v1/auth/me`, {
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/vnd.api+json',
        },
      });

      if (!response.ok) {
        this.removeToken();
        return null;
      }

      const result = await response.json();
      return result.data.attributes;
    } catch {
      this.removeToken();
      return null;
    }
  }

  logout(): void {
    this.removeToken();
  }

  private setToken(token: string): void {
    if (typeof window !== 'undefined') {
      localStorage.setItem(this.TOKEN_KEY, token);
    }
  }

  getToken(): string | null {
    if (typeof window !== 'undefined') {
      return localStorage.getItem(this.TOKEN_KEY);
    }
    return null;
  }

  private removeToken(): void {
    if (typeof window !== 'undefined') {
      localStorage.removeItem(this.TOKEN_KEY);
    }
  }

  isAuthenticated(): boolean {
    return !!this.getToken();
  }
}

export const authService = new AuthService();
export type { User, LoginCredentials, RegisterData, AuthResponse };
