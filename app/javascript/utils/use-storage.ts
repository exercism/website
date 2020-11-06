import React, { useCallback } from 'react'
import { StoredMemoryValue, useMutableMemoryValue } from 'use-memory-value'

export function useStorage(key, initialValue) {
  const memoryValue = new StoredMemoryValue(key, true, initialValue)
  const [value, setValue] = useMutableMemoryValue(memoryValue)

  return [value, setValue]
}
