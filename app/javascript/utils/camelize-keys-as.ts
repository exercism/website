import { camelizeKeys } from 'humps'

export function camelizeKeysAs<T>(object: unknown): T {
  return camelizeKeys(object, function (key, convert) {
    // Don't camelize expected inputs.
    // TODO: This should be a recursive STOP if the key is expected
    // or something with this passed in via the options.
    // Note humps is deprecated. We should fork or copy/paste it in if
    // we want to carry on using it.
    return /^[A-Z0-9_]+$/.test(key) ? key : convert(key)
  }) as unknown as T
}
