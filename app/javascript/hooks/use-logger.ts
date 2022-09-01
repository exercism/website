import { useEffect } from 'react'

// eslint-disable-next-line @typescript-eslint/no-explicit-any, @typescript-eslint/explicit-module-boundary-types
export function useLogger(label: string, element: any): void {
  useEffect(() => {
    console.log(label, element)
  }, [element, label])
}
