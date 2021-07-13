import { useState } from 'react'
import { StoredMemoryValue, useMutableMemoryValue } from 'use-memory-value'

export function useStorage<T>(key: string, initialValue: T) {
  const memoryValue = new StoredMemoryValue<T>(key, true, initialValue)

  return useMutableMemoryValue(memoryValue)
}

export function useLocalStorage<T>(
  key: string,
  initialValue: T
): [T, (value: T) => void] {
  const [storedValue, setStoredValue] = useState<T>(() => {
    try {
      const item = JSON.parse(localStorage.getItem(key) || '') as T

      return item
    } catch (error) {
      return initialValue
    }
  })

  const setValue = (value: T) => {
    try {
      setStoredValue(value)

      localStorage.setItem(key, JSON.stringify(value))
    } catch (error) {
      console.log(error)
    }
  }

  return [storedValue, setValue]
}
