import { useRef } from 'react'

export function useSetupIFrames() {
  const actualIFrameRef = useRef<HTMLIFrameElement>(null)

  return {
    actualIFrameRef,
  }
}
