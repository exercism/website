/* eslint-disable react-hooks/exhaustive-deps */
/* eslint-disable @typescript-eslint/no-explicit-any */
import { useEffect, useRef } from 'react'

// eslint-disable-next-line @typescript-eslint/explicit-module-boundary-types
export function useDidMountEffect(func: (...args: any) => any, deps: any[]) {
  const didMount = useRef(false)

  useEffect(() => {
    if (!didMount.current) {
      didMount.current = true
      return
    }
    func()
  }, deps)
}
