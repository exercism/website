import { useState, useEffect, useCallback, useRef, useContext } from 'react'

import useEditorStore from '../store/editorStore'
import type { AnimationTimeline } from '../AnimationTimeline/AnimationTimeline'
import type { Frame } from '@/interpreter/frames'
import { showError } from '../utils/showError'
import type { StaticError } from '@/interpreter/error'
import { INFO_HIGHLIGHT_COLOR } from '../CodeMirror/extensions/lineHighlighter'
import useAnimationTimelineStore from '../store/animationTimelineStore'
import { SolveExercisePageContext } from '../SolveExercisePageContextWrapper'
import { scrollToLine } from '../CodeMirror/scrollToLine'
import { cleanUpEditor } from '../CodeMirror/extensions/clean-up-editor'
import { getBreakpointLines } from '../CodeMirror/getBreakpointLines'

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
  context,
}: {
  setIsPlaying: React.Dispatch<React.SetStateAction<boolean>>
  animationTimeline: AnimationTimeline
  frames: Frame[]
  hasCodeBeenEdited: boolean
  context?: string
}) {
  // We start this at -1. That guarantees that something always
  // happens, even if the timeline is one frame long as so has
  // a duration of 0, because there is a transform from -1 to 0.
  const [timelineValue, setTimelineValue] = useState(-1)
  const {
    setHighlightedLine,
    setHighlightedLineColor,
    setInformationWidgetData,
    setShouldShowInformationWidget,
    setUnderlineRange,
  } = useEditorStore()

  const { editorView } = useContext(SolveExercisePageContext)

  const { setIsTimelineComplete, setShouldAutoplayAnimation } =
    useAnimationTimelineStore()

  // This steps through each breakpoint and finds each frame that
  // is in the range. It then compares it to whatever it's found
  // so far (nextBreakpointFrame) and if its earlier, it uses it.
  const getBreakpointFrameInTimelineTimeRange = useCallback(
    (startTimelineTime: number, endTimelineTime: number) => {
      const breakpoints = getBreakpointLines(editorView)
      let nextBreakpointFrame: Frame | undefined
      breakpoints.forEach((line) => {
        // Frames are always ordered by time, so the first one
        // we come across is the earliest. So we can use `find` here.
        const frame = frames.find(
          (frame) =>
            frame.timelineTime > startTimelineTime &&
            frame.timelineTime <= endTimelineTime &&
            frame.line === line
        )

        if (!frame) return
        if (
          !nextBreakpointFrame ||
          frame.timelineTime < nextBreakpointFrame.timelineTime
        ) {
          nextBreakpointFrame = frame
        }
      })
      return nextBreakpointFrame
    },
    [editorView]
  )

  // This effect is responsible for handling what happens when an animation
  // is playing. It updates the underlying state to match the progress of the animation.
  // It also guards against hitting breakpoints and pauses the animation if so.
  useEffect(() => {
    animationTimeline.onUpdate((anime) => {
      // Firstly, let's record that we've done *something* here.
      // This helps us not reset to the initial state accidently later.
      // onUpdate calls when the animation starts before anything has
      // happened, so we guard against progres being 0.
      if (anime.progress > 0) {
        animationTimeline.hasPlayedOrScrubbed = true
      }

      // We only want to use this callback if the animation is playing
      // Not if we're scrubbing through it. Otherwise we end up running
      // setTimelineValue multiple times in multiple places.
      if (anime.paused) return

      setTimeout(() => {
        // Always uses integers!
        let newTimelineValue = Math.round(
          anime.currentTime * TIME_TO_TIMELINE_SCALE_FACTOR
        )

        // Check if we have a breakpoint.
        // If we do, we want to stop the animation here.
        // Firstly we want to see if we've got a breakpoint in between where we
        // were and where we are. A lot of frames might execute between two moments
        // on the animation timeline (esp as this runs only a few times per second)
        // so we need to check all of the in between frames.
        const nextBreakpointFrame = getBreakpointFrameInTimelineTimeRange(
          timelineValue,
          newTimelineValue
        )

        if (nextBreakpointFrame) {
          // Because we might be not quite aligned, we set the newTimelineValue
          // to be the breakpoints time, not the animation time. This is our
          // point of true.
          newTimelineValue = nextBreakpointFrame.timelineTime

          // We stop the animation here and show the information widget.
          // We presume someone always wants to see that if they've set a breakpoint.
          anime.pause()
          setShouldShowInformationWidget(true)
        }

        // Now we either have the animation time, or the breakpoint time.
        // Regardless, we start our daisy chain of actions by setting the timeline value.
        setTimelineValue(newTimelineValue)

        // And finally we set whether we've got to the end or not,
        // which again sets of a daisy chain of effects when we reach the end!
        if (anime.completed) {
          setIsTimelineComplete(true)
        } else {
          setIsTimelineComplete(false)
        }
      }, 16) // Don't update more than 60 times a second (framerate)
    })
  }, [animationTimeline, getBreakpointFrameInTimelineTimeRange])

  // The frames change when the code is run. So this is our big reset moment
  // effectively.
  //
  // If there's an error frame, we don't want to play everything out
  // and immediately want to give the user the information they need.
  // - If we have a breakpoint, we want to jump there
  // - Otherwise we want to jump to the error frame
  //
  useEffect(() => {
    // We only want to run this if the user is at the beginning of the timeline
    // and hasn't yet scrubbed somewhere. If they've moved away from the first
    // frame then we want to just get out of here.
    if (animationTimeline.hasPlayedOrScrubbed) {
      return
    }
    // In this effect, we only care about error frames. Find the first
    // or get out of here.
    const errorFrame = frames.find((frame) => frame.status === 'ERROR')!
    if (!errorFrame) {
      return
    }

    // If we have a breakpoint frame, we want to jump there.
    const breakpointFrame = getBreakpointFrameInTimelineTimeRange(
      0,
      errorFrame.timelineTime
    )
    if (breakpointFrame) {
      moveToFrame(animationTimeline, breakpointFrame, frames)
      return
    }

    // Otherwise we proceed straight to our error frame.
    moveToFrame(animationTimeline, errorFrame, frames)
  }, [frames])

  // This effect is responsible for updating the highlighted line and
  // information widget based on currentFrame. It runs every time the timelineValue
  // changes, which happens on any type of navigation or animation.
  useEffect(() => {
    const currentFrame = frameNearestTimelineTime(frames, timelineValue)

    cleanUpEditor(editorView)

    // If for some reason we don't have a frame here, return
    // (although I don't see how this is possible).
    if (!currentFrame) return

    // Don't show lines while the animation is playing.
    if (!animationTimeline.paused) return

    setHighlightedLine(currentFrame.line)
    scrollToLine(editorView, currentFrame.line)

    switch (currentFrame.status) {
      case 'SUCCESS': {
        setHighlightedLineColor(INFO_HIGHLIGHT_COLOR)
        setInformationWidgetData({
          html: currentFrame.description(),
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
          context,
        })
      }
    }
  }, [timelineValue, frames])

  // When user switches between test results, scrub to the last viewed
  // time of that test's animation timeline.
  useEffect(() => {
    const timelineTime =
      animationTimeline.timeline.currentTime * TIME_TO_TIMELINE_SCALE_FACTOR
    const frame = frameNearestTimelineTime(frames, timelineTime)
    if (frame === undefined) return

    moveToFrame(animationTimeline, frame, frames, timelineTime, false)
  }, [animationTimeline])

  // When the code is edited, pause the animation and stop autoplaying
  // for other tests.
  useEffect(() => {
    if (hasCodeBeenEdited) {
      setShouldAutoplayAnimation(false)
      animationTimeline.pause()
    }
  }, [hasCodeBeenEdited, animationTimeline])

  // When the scrubber is dragged, we want to stop the animation timeline from
  // playing and take manual control of it. So we get the time from the scrubber,
  // get the nearest fraem to it, and then manually move to that
  const handleChange = useCallback(
    (
      event:
        | React.ChangeEvent<HTMLInputElement>
        | React.MouseEvent<HTMLInputElement, MouseEvent>,
      animationTimeline: AnimationTimeline,
      frames: Frame[]
    ) => {
      const timelineTime = Number((event.target as HTMLInputElement).value)
      const newFrame = frameNearestTimelineTime(frames, timelineTime)

      if (newFrame === undefined) return

      moveToFrame(animationTimeline, newFrame, frames, timelineTime)
    },
    []
  )

  // When we're sliding along the scrubber, we can sort of sit in between two
  // frames, and that's fine. It allows the user to watch the animation back.
  // But when they let go of the mouse we need to lock onto a frame. So this
  // does that. It grabs the nearest frame to the current scrub and moves to it.
  const handleOnMouseUp = useCallback(
    (animationTimeline: AnimationTimeline, frames: Frame[]) => {
      const newFrame = frameNearestTimelineTime(frames, timelineValue)
      if (newFrame === undefined) return

      moveToFrame(animationTimeline, newFrame, frames)
    },
    [timelineValue]
  )

  const handleGoToBreakpoint = useCallback(
    (
      direction: 1 | -1,
      animationTimeline: AnimationTimeline,
      frames: Frame[]
    ) => {
      const breakpoints = getBreakpointLines(editorView)

      if (breakpoints.length === 0) return

      let currentFrameIdx = frameIdxNearestTimelineTime(frames, timelineValue)
      if (currentFrameIdx === undefined) return

      const newFrameIndex = findFrameIndex(
        frames,
        currentFrameIdx,
        breakpoints,
        direction
      )

      if (newFrameIndex === null || newFrameIndex === -1) return

      moveToFrame(animationTimeline, frames[newFrameIndex], frames)
    },
    [timelineValue, editorView]
  )

  function findFrameIndex(
    frames: Frame[],
    currentIndex: number,
    breakpoints: number[],
    direction: 1 | -1
  ): number | null {
    if (direction === -1) {
      // finds backwards the closest frame that has one of the lines in the breakpoints array
      return frames
        .slice(0, currentIndex)
        .findLastIndex((frame) => breakpoints.includes(frame.line))
    } else {
      // finds forwards the closest frame that has one of the lines in the breakpoints array
      const nextIndex = frames
        .slice(currentIndex + 1)
        .findIndex((frame) => breakpoints.includes(frame.line))
      return nextIndex !== -1 ? nextIndex + currentIndex + 1 : null
    }
  }

  const handleGoToPreviousBreakpoint = (
    animationTimeline: AnimationTimeline,
    frames: Frame[]
  ) => handleGoToBreakpoint(-1, animationTimeline, frames)

  const handleGoToNextBreakpoint = (
    animationTimeline: AnimationTimeline,
    frames: Frame[]
  ) => handleGoToBreakpoint(1, animationTimeline, frames)

  const handleGoToPreviousFrame = useCallback(
    (animationTimeline: AnimationTimeline, frames: Frame[]) => {
      let currentFrameIdx = frameIdxNearestTimelineTime(frames, timelineValue)

      // If there's no frame for this, then it's the last frame
      if (currentFrameIdx === undefined) {
        currentFrameIdx = frames.length - 1
      }
      if (currentFrameIdx == 0) return

      const prevFrame = frames[currentFrameIdx - 1]
      moveToFrame(animationTimeline, prevFrame, frames)
    },
    [timelineValue]
  )

  const handleGoToNextFrame = useCallback(
    (animationTimeline: AnimationTimeline, frames: Frame[]) => {
      const currentFrameIdx =
        timelineValue > 0
          ? frameIdxNearestTimelineTime(frames, timelineValue)
          : 0

      if (currentFrameIdx === undefined) return
      if (currentFrameIdx >= frames.length - 1) return

      moveToFrame(animationTimeline, frames[currentFrameIdx + 1], frames)
    },
    [timelineValue]
  )

  const handleGoToFirstFrame = useCallback(
    (animationTimeline: AnimationTimeline, frames: Frame[]) => {
      moveToFrame(animationTimeline, frames[0], frames)
    },
    []
  )

  const handleGoToEndOfTimeline = useCallback(
    (animationTimeline: AnimationTimeline, frames: Frame[]) => {
      moveToFrame(animationTimeline, frames[frames.length - 1], frames)
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
      animationTimeline: AnimationTimeline
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
    animationTimeline: AnimationTimeline,
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

  const frameNearestTimelineTime = (
    frames: Frame[],
    timelineTime: number
  ): Frame | undefined => {
    if (!frames.length) return undefined

    // If we're past the last frame, return the last frame
    if (timelineTime > frames[frames.length - 1].timelineTime) {
      return frames[frames.length - 1]
    }

    const idx = frameIdxNearestTimelineTime(frames, timelineTime)
    if (idx === undefined) return undefined

    return frames[idx]
  }

  const frameIdxNearestTimelineTime = (
    frames: Frame[],
    timelineTime: number
  ): number | undefined => {
    if (!frames.length) return undefined

    const idx = frames.findIndex((frame) => frame.timelineTime >= timelineTime)
    if (idx == -1) return undefined
    if (idx == 0) return idx

    // Return the id of whichever of the previous frame and this frame is closest
    return Math.abs(frames[idx - 1].timelineTime - timelineTime) <
      Math.abs(frames[idx].timelineTime - timelineTime)
      ? idx - 1
      : idx
  }

  const moveToFrame = (
    animationTimeline: AnimationTimeline,
    newFrame: Frame,
    frames: Frame[],
    newTimelineTime?: number,
    pause: boolean = true
  ) => {
    const isLastFrame = frames.indexOf(newFrame) == frames.length - 1
    newTimelineTime = newTimelineTime || newFrame.timelineTime

    // Update to the new frame time.
    if (pause) {
      animationTimeline.pause()
      setShouldAutoplayAnimation(false)
    }

    if (animationTimeline.paused) {
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
  const updateInputBackground = useCallback(() => {
    const input = rangeRef.current
    if (!input) return

    const value = parseFloat(input.value)
    const min = parseFloat(input.min)
    const max = parseFloat(input.max)

    const percentage = ((value - min) / (max - min)) * 100
    // 7128F5 - jiki purple
    const backgroundStyle = `linear-gradient(to right, #7128F5 ${percentage}%, #fff ${percentage}%)`
    input.style.background = backgroundStyle
  }, [])

  useEffect(() => {
    updateInputBackground()
  }, [timelineValue, animationTimeline])

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
    handleGoToNextBreakpoint,
    handleGoToPreviousBreakpoint,
    rangeRef,
    updateInputBackground,
  }
}

export function calculateMinInputValue(frames: Frame[]) {
  // If there is only one frame, then the time will be 0,
  // and the scrubber will disabled. But it still needs a range
  // to look correct, so we just give it a range backwards, so
  // that 0 is at the end.
  return frames.length < 2 ? -1 : 0
}

export function calculateMaxInputValue(animationTimeline: AnimationTimeline) {
  return Math.round(
    animationTimeline.timeline.duration * TIME_TO_TIMELINE_SCALE_FACTOR
  )
}
