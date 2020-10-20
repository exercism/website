export function typecheck<T>(json: any, key: string): T | never {
  if (json === null || typeof json !== 'object') {
    throw new Error(
      `Expexted non-null object, actual ${json === null ? null : typeof json}`
    )
  }

  if (!json.hasOwnProperty(key)) {
    const keys = Object.keys(json)
    throw new Error(`Expected top-level key ${key}, actual keys: ${keys}`)
  }

  return json[key] as T
}
