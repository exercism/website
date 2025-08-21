import { useEffect } from 'react'

export function useLogger(label: string, value: any) {
  useEffect(() => {
    console.log(label, value)
  }, [value])
}
