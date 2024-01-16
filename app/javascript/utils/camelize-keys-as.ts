import { camelizeKeys } from 'humps'

export function camelizeKeysAs<T>(object: unknown): T {
  return camelizeKeys(object) as unknown as T
}
