/* eslint-disable @typescript-eslint/explicit-module-boundary-types */
import { useEffect } from 'react'

// eslint-disable-next-line @typescript-eslint/no-explicit-any
export function useLogger(label: string, data: any): void {
  useEffect(() => {
    console.log(label, data)
  }, [label, data])
}
