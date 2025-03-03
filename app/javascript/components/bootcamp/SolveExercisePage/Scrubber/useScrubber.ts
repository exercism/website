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

// Everything is scaled by 100. This allows for us to set
// frame times in microseconds (e.g. 0.01 ms) but allows the
// timeline and everything else to always be integers.
// We call this value "timeline time". The scrubber uses it as
// its scale, and the frames have a timelineTime property that
// is the time * 100, rounded (to avoid very painful floating point errors)
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
    if (!animationTimeline) {
      return
    }

    animationTimeline.onUpdate((anime) => {
      // We only want to use this callback if the animation is playing
      // Not if we're scrubbing through it. Otherwise we end up running
      // setTimelineValue multiple times in multiple places.
      if (anime.paused) return
      setTimeout(() => {
        // Always uses integers!
        setTimelineValue(
          Math.round(anime.currentTime * TIME_TO_TIMELINE_SCALE_FACTOR)
        )
        if (anime.completed) {
          setIsTimelineComplete(true)
        } else {
          setIsTimelineComplete(false)
        }
      }, 16) // Don't update more than 60 times a second (framerate)
    })
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
    const currentFrame = frameAtTimelineTime(frames, timelineValue)

    cleanUpEditor(editorView)

    // If for some reason we don't have a frame here, return
    // (although I don't see how this is possible).
    if (!currentFrame) return

    // If the animation is running, don't show annotations
    if (animationTimeline && !animationTimeline.paused) return

    setHighlightedLine(currentFrame.line)
    scrollToLine(editorView, currentFrame.line)

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
          editorView,
        })
      }
    }
  }, [timelineValue, frames])

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

  // TODO: Remove this?
  const handleScrubToCurrentTime = useCallback(
    (animationTimeline: AnimationTimeline | undefined | null) => {},
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
      const timelineTime = Number((event.target as HTMLInputElement).value)
      const newFrame = frameAtTimelineTime(frames, timelineTime)
      if (newFrame === undefined) return

      moveToNewFrame(animationTimeline, newFrame, frames, timelineTime)
    },
    [setTimelineValue, setInformationWidgetData]
  )

  const handleOnMouseUp = useCallback(
    (
      animationTimeline: AnimationTimeline | undefined | null,
      frames: Frame[]
    ) => {
      const newFrame = frameAtTimelineTime(frames, timelineValue)
      if (newFrame === undefined) return

      moveToNewFrame(animationTimeline, newFrame, frames)
    },
    [setTimelineValue, timelineValue]
  )

  const handleGoToPreviousFrame = useCallback(
    (
      animationTimeline: AnimationTimeline | undefined | null,
      frames: Frame[]
    ) => {
      let currentFrameIdx = frameIdxAtTimelineTime(frames, timelineValue)

      // If there's no frame for this, then it's the last frame
      if (currentFrameIdx === undefined) {
        currentFrameIdx = frames.length - 1
      }
      if (currentFrameIdx == 0) return

      const prevFrame = frames[currentFrameIdx - 1]
      moveToNewFrame(animationTimeline, prevFrame, frames)
    },
    [timelineValue]
  )

  const handleGoToNextFrame = useCallback(
    (
      animationTimeline: AnimationTimeline | undefined | null,
      frames: Frame[]
    ) => {
      const currentFrameIdx =
        timelineValue > 0 ? frameIdxAtTimelineTime(frames, timelineValue) : 0

      if (currentFrameIdx === undefined) return
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
    // setHeldKeys((prev) => new Set(prev).add(event.key))
    // if user is holding a key, don't invoke frame-stepping handlers
    // console.log(userHoldingKey())
    // if (userHoldingKey()) return

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
        if (animationTimeline) {
          if (animationTimeline.paused) {
            animationTimeline.play()
            setIsPlaying(true)
          } else {
            animationTimeline.pause()
            setIsPlaying(false)
          }
        }
        break
      default:
        return
    }
  }

  const frameAtTimelineTime = (
    frames: Frame[],
    timelineTime: number
  ): Frame | undefined => {
    if (!frames.length) return undefined

    // If we're past the last frame, return the last frame
    if (timelineTime > frames[frames.length - 1].timelineTime) {
      return frames[frames.length - 1]
    }
    return frames.find((frame) => frame.timelineTime >= timelineTime)
  }

  const frameIdxAtTimelineTime = (
    frames: Frame[],
    timelineTime: number
  ): number | undefined => {
    if (!frames.length) return undefined

    const id = frames.findIndex((frame) => frame.timelineTime >= timelineTime)
    return id == -1 ? undefined : id
  }

  const moveToNewFrame = (
    animationTimeline: AnimationTimeline | undefined | null,
    newFrame: Frame,
    frames: Frame[],
    newTimelineTime?: number
  ) => {
    const isLastFrame = frames.indexOf(newFrame) == frames.length - 1
    newTimelineTime = newTimelineTime || newFrame.timelineTime

    // Update to the new frame time.
    if (animationTimeline) {
      animationTimeline.pause()
      setShouldAutoplayAnimation(false)

      // If we're dealing with the last frame, seek to the end
      if (isLastFrame) {
        newTimelineTime =
          animationTimeline?.duration * TIME_TO_TIMELINE_SCALE_FACTOR
        animationTimeline.seekEndOfTimeline()
      } else {
        animationTimeline.seek(newTimelineTime / TIME_TO_TIMELINE_SCALE_FACTOR)
      }
    }
    // Finally, set the new time. Note, this potentially gets
    // changed in the aimationTimeline block above, so don't do it
    // early and guard/return.
    setTimelineValue(newTimelineTime)
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
  return animationTimeline
    ? Math.ceil(
        animationTimeline.timeline.duration * TIME_TO_TIMELINE_SCALE_FACTOR
      )
    : frames[frames.length - 1]?.timelineTime || 0
}
