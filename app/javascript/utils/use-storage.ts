import React, { useCallback, useState } from 'react'
import { StoredMemoryValue, useMutableMemoryValue } from 'use-memory-value'

export function useStorage<T>(key: string, initialValue: T) {
  const memoryValue = new StoredMemoryValue<T>(key, true, initialValue)

  return useMutableMemoryValue(memoryValue)
}

export function useLocalStorage(key: string, initialValue: string) {
  const [storedValue, setStoredValue] = useState(() => {
    try {
      const item = localStorage.getItem(key)

      return item || initialValue
    } catch (error) {
      console.log(error)

      return initialValue
    }
  })

  const setValue = (value: string) => {
    try {
      setStoredValue(value)

      localStorage.setItem(key, value)
    } catch (error) {
      console.log(error)
    }
  }

  return [storedValue, setValue]
}
