import type { AnimeInstance } from 'animejs'
import { useState, useEffect, useCallback, useRef } from 'react'
import anime from 'animejs'
import useEditorStore from '../store/editorStore'
import type { AnimationTimeline } from '../AnimationTimeline/AnimationTimeline'
import type { Frame } from '@/interpreter/frames'
import { showError } from '../utils/showError'
import type { StaticError } from '@/interpreter/error'
import { INFO_HIGHLIGHT_COLOR } from '../CodeMirror/extensions/lineHighlighter'
import { scrollToHighlightedLine } from './scrollToHighlightedLine'

const FRAME_DURATION = 50

export function useScrubber({
  setIsPlaying,
  testResult,
}: {
  setIsPlaying: React.Dispatch<React.SetStateAction<boolean>>
  testResult: NewTestResult
}) {
  const [value, setValue] = useState(0)
  const {
    setHighlightedLine,
    setHighlightedLineColor,
    setInformationWidgetData,
    informationWidgetData,
    setShouldShowInformationWidget,
    setUnderlineRange,
  } = useEditorStore()

  // this effect is responsible for updating the scrubber value based on the current time of animationTimeline
  useEffect(() => {
    if (testResult.animationTimeline) {
      testResult.animationTimeline.onUpdate((anime) => {
        setTimeout(() => {
          setValue(anime.currentTime)
        }, FRAME_DURATION)
      })
    }
  }, [testResult.view?.id, testResult.animationTimeline?.completed])

  // this effect is responsible for updating the highlighted line and information widget based on currentFrame
  useEffect(() => {
    let currentFrame: Frame | undefined = testResult.frames.find(
      (f) => f.status === 'ERROR'
    )

    if (!currentFrame) {
      if (testResult.animationTimeline) {
        currentFrame = testResult.animationTimeline.currentFrame
      } else {
        currentFrame = testResult.frames[value]
      }
    }
    if (currentFrame) {
      setHighlightedLine(currentFrame.line)
      switch (currentFrame.status) {
        case 'SUCCESS': {
          setHighlightedLineColor(INFO_HIGHLIGHT_COLOR)
          setInformationWidgetData({
            html: currentFrame.description,
            line: currentFrame.line,
            status: 'SUCCESS',
          })
          break
        }
        case 'ERROR': {
          const error = currentFrame.error
          showError({
            error: error as StaticError,
            setHighlightedLine,
            setHighlightedLineColor,
            setInformationWidgetData,
            setShouldShowInformationWidget,
            setUnderlineRange,
          })
        }
      }
    }
  }, [
    testResult.view?.id,
    value,
    testResult.animationTimeline?.currentFrameIndex,
    testResult.frames,
  ])

  const handleScrubToCurrentTime = useCallback(
    (animationTimeline: AnimationTimeline) => {
      if (!animationTimeline) return
      const value = animationTimeline.timeline.currentTime
      setValue(value)
      animationTimeline.seek(value)
    },
    [setValue]
  )

  const handleChange = useCallback(
    (
      event:
        | React.ChangeEvent<HTMLInputElement>
        | React.MouseEvent<HTMLInputElement, MouseEvent>,
      testResult: NewTestResult
    ) => {
      const newValue = Number((event.target as HTMLInputElement).value)
      setValue(newValue)

      if (testResult.animationTimeline) {
        testResult.animationTimeline.pause()
        testResult.animationTimeline.seek(newValue)
      } else {
        const validIndex = Math.max(0, newValue)
        const highlightedLine =
          newValue === -1 ? 0 : testResult.frames[validIndex].line
        setHighlightedLine(highlightedLine)
      }
      scrollToHighlightedLine()
    },
    [setValue, setInformationWidgetData]
  )

  const handleMouseDown = useCallback(
    (
      event:
        | React.ChangeEvent<HTMLInputElement>
        | React.MouseEvent<HTMLInputElement, MouseEvent>,
      testResult: NewTestResult
    ) => {
      if (informationWidgetData.line === 0) {
        handleChange(event, testResult)
      }
    },
    [handleChange, informationWidgetData.line]
  )

  const scrubberValueAnimation = useRef<AnimeInstance | null>()

  const handleOnMouseUp = useCallback(
    (testResult: NewTestResult) => {
      const { animationTimeline } = testResult

      if (!animationTimeline) return
      // find closest frame to progress
      const { progress } = animationTimeline
      const { duration } = animationTimeline.timeline
      let closestTime = duration
      let closestDifference = Math.abs(duration - progress)

      for (const frame of testResult.frames) {
        const frameTime = frame.time
        const difference = Math.abs(frameTime - progress)

        if (difference < closestDifference) {
          closestTime = frameTime
          closestDifference = difference
        }
      }
      if (scrubberValueAnimation.current) {
        anime.remove(scrubberValueAnimation.current)
      }

      scrubberValueAnimation.current = anime({
        // for smooth animation, use progress (which is current `value`) as a starting point
        targets: { value },
        // if progress is closer to duration than time, then snap to duration
        value: closestTime,
        duration: FRAME_DURATION,
        easing: 'easeOutQuad',
        update: function (anim) {
          const newTime = Number(anim.animations[0].currentValue)
          setValue(newTime)
          animationTimeline.seek(newTime)
        },
      })
    },
    [setValue, value]
  )

  const handleGoToPreviousFrame = useCallback(
    (testResult: NewTestResult) => {
      const { animationTimeline } = testResult

      if (!animationTimeline) {
        // index shouldn't be under 0 or above the last frame
        const validIndex = Math.min(
          Math.max(0, value - 1),
          testResult.frames.length - 1
        )
        setValue(validIndex)
        return
      }

      if (scrubberValueAnimation.current) {
        anime.remove(scrubberValueAnimation.current)
      }

      const currentTime = animationTimeline.progress
      const lastFrameTime = testResult.frames[testResult.frames.length - 1].time

      /*

      if we are at the very end of the animation timeline,
      targetTime should be the start time of the last frame’s animation.

      e.g.: if the last frame’s animation starts at 5 seconds and the timeline ends at 10 seconds, 
      being at 10 seconds should move us to 5 seconds.

      otherwise, move to the start time of the previous frame.

       */

      const prevFrame = animationTimeline.previousFrame
      const { duration } = animationTimeline.timeline
      const targetTime =
        // gotta ensure we are't going back to our current time, which'd result in not moving at all
        currentTime === duration && lastFrameTime !== duration
          ? lastFrameTime
          : // if there is no previous frame, go to the start of the timeline
          prevFrame
          ? prevFrame.time
          : 0

      scrubberValueAnimation.current = anime({
        targets: { value },
        value: targetTime,
        duration: FRAME_DURATION,
        easing: 'easeOutQuad',
        update: function (anim) {
          const animatedTime = Number(anim.animations[0].currentValue)
          setValue(animatedTime)
          animationTimeline.seek(animatedTime)
        },
      })
      scrollToHighlightedLine()
    },
    [value]
  )

  const handleGoToNextFrame = useCallback(
    (testResult: NewTestResult) => {
      const { animationTimeline } = testResult

      if (!animationTimeline) {
        // index shouldn't be under 0 or above the last frame
        const validIndex = Math.min(
          Math.max(0, value + 1),
          testResult.frames.length - 1
        )
        setValue(validIndex)
        return
      }

      if (scrubberValueAnimation.current) {
        anime.remove(scrubberValueAnimation.current)
      }

      // if there is no next frame, go to the end of the animation
      const targetTime = animationTimeline.nextFrame
        ? animationTimeline.nextFrame.time
        : animationTimeline.timeline.duration

      scrubberValueAnimation.current = anime({
        targets: { value },
        value: targetTime,
        duration: FRAME_DURATION,
        easing: 'easeOutQuad',
        update: function (anim) {
          const animatedTime = Number(anim.animations[0].currentValue)
          setValue(animatedTime)
          animationTimeline.seek(animatedTime)
        },
      })
      scrollToHighlightedLine()
    },
    [value]
  )

  const handleGoToFirstFrame = useCallback((testResult: NewTestResult) => {
    const { animationTimeline } = testResult
    if (animationTimeline) {
      animationTimeline.seekFirstFrame()
      scrollToHighlightedLine()
    }
  }, [])

  const handleGoToEndOfTimeline = useCallback((testResult: NewTestResult) => {
    const { animationTimeline } = testResult
    if (animationTimeline) {
      animationTimeline.seekEndOfTimeline()
      scrollToHighlightedLine()
    }
  }, [])

  /*
   when holding a key down, store it in a set and escape invoking frame-stepping handlers.
   let user browse scrubber freely
   */
  const [heldKeys, setHeldKeys] = useState(new Set<string>())
  const handleOnKeyUp = useCallback(
    (
      event: React.KeyboardEvent<HTMLInputElement>,
      testResult: NewTestResult
    ) => {
      const { animationTimeline } = testResult
      if (!animationTimeline) return
      setHeldKeys((prev) => {
        const newSet = new Set(prev)
        newSet.delete(event.key)
        return newSet
      })
    },
    [setHeldKeys]
  )

  const handleOnKeyDown = (
    event: React.KeyboardEvent<HTMLInputElement>,
    testResult: NewTestResult
  ) => {
    const { animationTimeline } = testResult
    if (!animationTimeline) return

    setHeldKeys((prev) => new Set(prev).add(event.key))
    // if user is holding a key, don't invoke frame-stepping handlers
    if (heldKeys.has(event.key)) return

    /* 
      preventing default is necessary to avoid jarring UI jumps: 
      without it, moving from 1 to 2 causes an immediate jump to 2, 
      then snaps back to the animation's current progress before completing the animation, easing from 1 to 2.
    */
    event.preventDefault()

    switch (event.key) {
      case 'ArrowLeft':
        handleGoToPreviousFrame(testResult)
        break

      case 'ArrowRight':
        handleGoToNextFrame(testResult)
        break

      case 'ArrowDown':
        handleGoToFirstFrame(testResult)
        break

      case 'ArrowUp':
        handleGoToEndOfTimeline(testResult)
        break

      case ' ':
        if (animationTimeline.paused) {
          animationTimeline.play()
          setIsPlaying(true)
        } else {
          animationTimeline.pause()
          setIsPlaying(false)
        }
        break
      default:
        return
    }
  }

  const rangeRef = useRef<HTMLInputElement>(null)
  const updateInputBackground = () => {
    const input = rangeRef.current
    if (!input) return

    const value = parseFloat(input.value)
    const min = parseFloat(input.min)
    const max = parseFloat(input.max)

    const percentage = ((value - min) / (max - min)) * 100
    // 7128F5 - jiki purple
    const backgroundStyle = `linear-gradient(to right, #7128F5 ${percentage}%, #fff ${percentage}%)`
    input.style.background = backgroundStyle
  }

  useEffect(() => {
    updateInputBackground()
  }, [value, testResult.animationTimeline])

  return {
    value,
    handleChange,
    handleMouseDown,
    handleOnMouseUp,
    handleOnKeyUp,
    handleOnKeyDown,
    handleGoToNextFrame,
    handleGoToPreviousFrame,
    handleGoToEndOfTimeline,
    handleGoToFirstFrame,
    rangeRef,
    updateInputBackground,
    handleScrubToCurrentTime,
  }
}

export function calculateMaxInputValue(testResult: NewTestResult) {
  if (testResult.animationTimeline) {
    return testResult.animationTimeline.timeline.duration
  }

  return testResult.frames.length - 1
}
