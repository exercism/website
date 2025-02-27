import { useState, useEffect, useCallback, useRef, useContext } from 'react'

import useEditorStore from '../store/editorStore'
import type { AnimationTimeline } from '../AnimationTimeline/AnimationTimeline'
import type { Frame } from '@/interpreter/frames'
import { showError } from '../utils/showError'
import type { StaticError } from '@/interpreter/error'
import { INFO_HIGHLIGHT_COLOR } from '../CodeMirror/extensions/lineHighlighter'
import useAnimationTimelineStore from '../store/animationTimelineStore'
import useTestStore from '../store/testStore'
import { SolveExercisePageContext } from '../SolveExercisePageContextWrapper'
import { scrollToLine } from '../CodeMirror/scrollToLine'
import { cleanUpEditor } from '../CodeMirror/extensions/clean-up-editor'

const FRAME_DURATION = 0.1

// We have two different metrics we use:
// 1. The time of the frame. This can be as little as 0.01ms
// 2. The scrubber - which is integer-based.
// We use this constant to convert between the two.
export const TIME_TO_TIMELINE_SCALE_FACTOR = 100

export function useScrubber({
  setIsPlaying,
  animationTimeline,
  frames,
  hasCodeBeenEdited,
}: {
  setIsPlaying: React.Dispatch<React.SetStateAction<boolean>>
  animationTimeline: AnimationTimeline | undefined | null
  frames: Frame[]
  hasCodeBeenEdited: boolean
}) {
  // if there is an animation timeline, we use time as value
  // if there is no animation timeline, we use frame index as value
  const [timelineValue, setTimelineValue] = useState(0)
  const {
    setHighlightedLine,
    setHighlightedLineColor,
    setInformationWidgetData,
    informationWidgetData,
    setShouldShowInformationWidget,
    setUnderlineRange,
  } = useEditorStore()

  const { editorView } = useContext(SolveExercisePageContext)

  const { setIsTimelineComplete, setShouldAutoplayAnimation } =
    useAnimationTimelineStore()

  const { inspectedTestResult } = useTestStore()

  // this effect is responsible for updating the scrubber value based on the current time of animationTimeline
  useEffect(() => {
    if (animationTimeline) {
      animationTimeline.onUpdate((anime) => {
        setTimeout(() => {
          setTimelineValue(anime.currentTime * TIME_TO_TIMELINE_SCALE_FACTOR)
          if (anime.completed) {
            setIsTimelineComplete(true)
          } else {
            setIsTimelineComplete(false)
          }
        }, FRAME_DURATION)
      })
    } else {
      setTimelineValue(0)
    }
  }, [animationTimeline])

  // only check for error frame once when frames change, let users navigate freely
  useEffect(() => {
    if (frames.some((frame) => frame.status === 'ERROR')) {
      const errorFrame = frames.find((frame) => frame.status === 'ERROR')!
      moveToNewFrame(animationTimeline, errorFrame, frames)
    }
  }, [frames])

  // this effect is responsible for updating the highlighted line and information widget based on currentFrame
  useEffect(() => {
    const currentFrame = frameAtTime(
      timelineValue / TIME_TO_TIMELINE_SCALE_FACTOR
    )

    cleanUpEditor(editorView)
    if (!currentFrame) return

    setHighlightedLine(currentFrame.line)
    scrollToLine(editorView, currentFrame.line)

    switch (currentFrame.status) {
      case 'SUCCESS': {
        setHighlightedLineColor(INFO_HIGHLIGHT_COLOR)
        setInformationWidgetData({
          html: currentFrame.description() || '',
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
          editorView,
        })
      }
    }
  }, [timelineValue])

  // when user switches between test results, scrub to animation timeline's persisted currentTime
  useEffect(() => {
    if (inspectedTestResult && inspectedTestResult.animationTimeline) {
      handleScrubToCurrentTime(inspectedTestResult.animationTimeline)
    }
  }, [inspectedTestResult])

  useEffect(() => {
    if (hasCodeBeenEdited) {
      if (animationTimeline) {
        setShouldAutoplayAnimation(false)
        animationTimeline?.pause()
      }
    }
  }, [hasCodeBeenEdited, animationTimeline])

  const handleScrubToCurrentTime = useCallback(
    (animationTimeline: AnimationTimeline | undefined | null) => {
      if (!animationTimeline) return

      const frame = frameAtTime(animationTimeline.timeline.currentTime)
      if (!frame) return

      moveToNewFrame(animationTimeline, frame, frames)
      const time = animationTimeline.timeline.currentTime
      setTimelineValue(time * TIME_TO_TIMELINE_SCALE_FACTOR)
      animationTimeline.seek(time)
    },
    [setTimelineValue]
  )

  const handleChange = useCallback(
    (
      event:
        | React.ChangeEvent<HTMLInputElement>
        | React.MouseEvent<HTMLInputElement, MouseEvent>,
      animationTimeline: AnimationTimeline | undefined | null,
      frames: Frame[]
    ) => {
      const newTime =
        Number((event.target as HTMLInputElement).value) /
        TIME_TO_TIMELINE_SCALE_FACTOR
      const newFrame = frameAtTime(newTime)
      if (newFrame === undefined) return

      moveToNewFrame(animationTimeline, newFrame, frames)
    },
    [setTimelineValue, setInformationWidgetData]
  )

  const handleMouseDown = useCallback(
    (
      event:
        | React.ChangeEvent<HTMLInputElement>
        | React.MouseEvent<HTMLInputElement, MouseEvent>,
      animationTimeline: AnimationTimeline | undefined | null,
      frames: Frame[]
    ) => {
      // TODO: What does this do??
      if (informationWidgetData.line !== 0) return

      handleChange(event, animationTimeline, frames)
    },
    [handleChange, informationWidgetData.line]
  )

  // TODO: Delete this?
  const handleOnMouseUp = useCallback(
    (
      animationTimeline: AnimationTimeline | undefined | null,
      frames: Frame[]
    ) => {},
    [setTimelineValue, timelineValue]
  )

  const handleGoToPreviousFrame = useCallback(
    (
      animationTimeline: AnimationTimeline | undefined | null,
      frames: Frame[]
    ) => {
      const timeValue = timelineValue / TIME_TO_TIMELINE_SCALE_FACTOR
      const currentFrameIdx = frames.findIndex(
        (frame) => frame.time >= timeValue
      )
      if (currentFrameIdx == 0) return

      const nextFrame = frames[currentFrameIdx - 1]
      moveToNewFrame(animationTimeline, nextFrame, frames)
    },
    [timelineValue]
  )

  const handleGoToNextFrame = useCallback(
    (
      animationTimeline: AnimationTimeline | undefined | null,
      frames: Frame[]
    ) => {
      const timeValue = timelineValue / TIME_TO_TIMELINE_SCALE_FACTOR
      const currentFrameIdx = frames.findIndex(
        (frame) => frame.time >= timeValue
      )
      if (currentFrameIdx >= frames.length - 1) return

      moveToNewFrame(animationTimeline, frames[currentFrameIdx + 1], frames)
    },
    [timelineValue]
  )

  const handleGoToFirstFrame = useCallback(
    (
      animationTimeline: AnimationTimeline | undefined | null,
      frames: Frame[]
    ) => {
      moveToNewFrame(animationTimeline, frames[0], frames)
    },
    []
  )

  const handleGoToEndOfTimeline = useCallback(
    (
      animationTimeline: AnimationTimeline | undefined | null,
      frames: Frame[]
    ) => {
      moveToNewFrame(animationTimeline, frames[frames.length - 1], frames)
    },
    []
  )

  /*
   when holding a key down, store it in a Set and escape invoking frame-stepping handlers.
   let user browse the scrubber freely
   */
  const [heldKeys, setHeldKeys] = useState(new Set<string>())
  const handleOnKeyUp = useCallback(
    (
      event: React.KeyboardEvent<HTMLInputElement>,
      animationTimeline: AnimationTimeline | undefined | null
    ) => {
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
    animationTimeline: AnimationTimeline | undefined | null,
    frames: Frame[]
  ) => {
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
        handleGoToPreviousFrame(animationTimeline, frames)
        break

      case 'ArrowRight':
        handleGoToNextFrame(animationTimeline, frames)
        break

      case 'ArrowDown':
        handleGoToFirstFrame(animationTimeline, frames)
        break

      case 'ArrowUp':
        handleGoToEndOfTimeline(animationTimeline, frames)
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

  const frameAtTime = (time: number): Frame | undefined => {
    return frames.find((frame) => frame.time >= time)
  }

  const moveToNewFrame = (
    animationTimeline: AnimationTimeline | undefined | null,
    newFrame: Frame,
    frames: Frame[]
  ) => {
    const newTime = newFrame.time

    // Update to the new frame time.
    setTimelineValue(newTime * TIME_TO_TIMELINE_SCALE_FACTOR)

    if (animationTimeline) {
      animationTimeline.pause()
      setShouldAutoplayAnimation(false)

      if (newTime == frames[frames.length - 1].time) {
        animationTimeline.seekEndOfTimeline()
      } else {
        animationTimeline.seek(newTime)
      }
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
  }, [timelineValue, inspectedTestResult])

  return {
    timelineValue,
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

export function calculateMaxInputValue(
  animationTimeline: AnimationTimeline | undefined | null,
  frames: Frame[]
) {
  return (
    (animationTimeline
      ? animationTimeline.timeline.duration
      : frames[frames.length - 1].time) * TIME_TO_TIMELINE_SCALE_FACTOR
  )
}
