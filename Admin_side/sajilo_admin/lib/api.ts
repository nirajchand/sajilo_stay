const API_BASE = 'http://localhost:3001/api/v1';
const UPLOADS_BASE = 'http://localhost:3001/uploads/hotels';

export function hotelImageUrl(path: string): string {
  if (!path) return '';
  if (path.startsWith('http')) return path;
  return `${UPLOADS_BASE}/${path}`;
}

function getToken(): string | null {
  if (typeof window === 'undefined') return null;
  return localStorage.getItem('sajilo_admin_token');
}

function authHeaders(): Record<string, string> {
  const token = getToken();
  return token ? { Authorization: `Bearer ${token}` } : {};
}

export async function apiFetch(path: string, options: RequestInit = {}): Promise<Response> {
  return fetch(`${API_BASE}${path}`, {
    ...options,
    headers: {
      ...authHeaders(),
      ...(options.headers || {}),
    },
  });
}

export async function apiJson<T>(path: string, options: RequestInit = {}): Promise<T> {
  const res = await apiFetch(path, {
    ...options,
    headers: {
      'Content-Type': 'application/json',
      ...(options.headers || {}),
    },
  });
  const data = await res.json();
  if (!data.success) throw new Error(data.message || 'Request failed');
  return data.data as T;
}

export { API_BASE };
