// src/api/apiHelper.ts
import apiClient from './apiClient';
import endpoints, { type EndpointKey } from './endpoints';
import { buildUrl } from './urlBuilder';

export interface CallApiOptions {
  pathParams?: Record<string, string | number>;
  queryParams?: Record<string, any>;
  body?: any;
  headers?: Record<string, string>;
}

export async function callApi<T = any>(
  endpointKey: EndpointKey,
  method: 'get' | 'post' | 'put' | 'patch' | 'delete',
  options: CallApiOptions = {}
): Promise<T> {
  const template = endpoints[endpointKey];
  if (!template) {
    throw new Error(`Unknown endpoint key: ${endpointKey}`);
  }

  const url = buildUrl(template, options.pathParams);
  const response = await apiClient.request<T>({
    url,
    method,
    params: options.queryParams,
    data: options.body,
    headers: options.headers,
  });
  return response.data;
}

// Loại bỏ dấu tiếng Việt khỏi chuỗi
export function removeVietnameseTones(str: string): string {
  return str
    .normalize('NFD')
    .replace(/\p{Diacritic}/gu, '')
    .replace(/đ/g, 'd')
    .replace(/Đ/g, 'D');
}
