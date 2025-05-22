import { useState, useEffect } from 'react'

export function useLazyLocalStorage<T>(
  key: string,
  initialValue: T | (() => T)
): [T, (value: T) => void] {
  const [storedValue, setStoredValue] = useState<T>(() => {
    try {
      const item = window.localStorage.getItem(key)
      if (item !== null) {
        return JSON.parse(item) as T
      }

      return typeof initialValue === 'function'
        ? (initialValue as () => T)()
        : initialValue
    } catch (error) {
      console.warn(`Failed to load localStorage key "${key}":`, error)
      return typeof initialValue === 'function'
        ? (initialValue as () => T)()
        : initialValue
    }
  })

  useEffect(() => {
    try {
      window.localStorage.setItem(key, JSON.stringify(storedValue))
    } catch (error) {
      console.warn(`Failed to save localStorage key "${key}":`, error)
    }
  }, [key, storedValue])

  return [storedValue, setStoredValue]
}
