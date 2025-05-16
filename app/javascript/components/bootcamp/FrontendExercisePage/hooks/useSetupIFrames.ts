import { useEffect, useRef } from 'react'
import { updateIFrame } from '../utils/updateIFrame'

// set up expected output and reference output
export function useSetupIFrames(
  config: FrontendExercisePageConfig,
  code: FrontendExercisePageCode
) {
  const actualIFrameRef = useRef<HTMLIFrameElement>(null)
  const expectedIFrameRef = useRef<HTMLIFrameElement>(null)
  const expectedReferenceIFrameRef = useRef<HTMLIFrameElement>(null)

  useEffect(() => {
    updateIFrame(expectedIFrameRef, config.expected, code)
    updateIFrame(expectedReferenceIFrameRef, config.expected, code)
  }, [])

  return {
    actualIFrameRef,
    expectedIFrameRef,
    expectedReferenceIFrameRef,
  }
}
