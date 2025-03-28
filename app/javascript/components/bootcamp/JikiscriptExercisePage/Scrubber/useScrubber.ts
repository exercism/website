import {
  useState,
  useEffect,
  useCallback,
  useRef,
  useContext,
  useMemo,
} from 'react'

import useEditorStore from '../store/editorStore'
import type { AnimationTimeline } from '../AnimationTimeline/AnimationTimeline'
import type { Frame } from '@/interpreter/frames'
import { showError } from '../utils/showError'
import type { StaticError } from '@/interpreter/error'
import { INFO_HIGHLIGHT_COLOR } from '../CodeMirror/extensions/lineHighlighter'
import useAnimationTimelineStore from '../store/animationTimelineStore'
import { JikiscriptExercisePageContext } from '../JikiscriptExercisePageContextWrapper'
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
    breakpoints,
    foldedLines,
    setHighlightedLine,
    setHighlightedLineColor,
    setInformationWidgetData,
    shouldShowInformationWidget,
    setShouldShowInformationWidget,
    setUnderlineRange,
  } = useEditorStore()

  const { editorView, isSpotlightActive } = useContext(
    JikiscriptExercisePageContext
  )

  const { setIsTimelineComplete, setShouldAutoplayAnimation } =
    useAnimationTimelineStore()

  const lastFrame = useMemo(() => frames[frames.length - 1], [frames])

  // We start with a series of finder functions. These are used to find
  // the prev/next/current frame with consideration to things like folding
  // and breakpoints.

  // This simply finds the previous frame with respect to folding
  const findPrevFrameIdx = useCallback(
    (currentIdx: number): number | undefined => {
      // Go through all the frames from the previous one to the first
      // of the frames, and return the first one that isn't folded.
      for (let idx = currentIdx - 1; idx >= 0; idx--) {
        const frame = frames[idx]
        if (!foldedLines.includes(frame.line)) return idx
      }
      return undefined
    },
    [frames, foldedLines]
  )

  // And this one finds the next frame with respect to folding
  const findNextFrame = useCallback(
    (currentIdx: number): Frame | undefined => {
      // Go through all the frames from the next one to the length
      // of the frames, and return the first one that isn't folded.
      for (let idx = currentIdx + 1; idx < frames.length; idx++) {
        const frame = frames[idx]
        if (!foldedLines.includes(frame.line)) return frame
      }
      return undefined
    },
    [frames, foldedLines]
  )

  // This one is the key frame that finds the frame nearest to the current
  // time. It's used throughout, especially for aligning with the scrubber.
  const findFrameIdxNearestTimelineTime = useCallback(
    (timelineTime: number): number | undefined => {
      if (!frames.length) return undefined

      // If we've not started playing yet, return the first frame
      if (timelineTime < 0) return 0

      let idx = frames.findIndex((frame) => {
        return (
          frame.timelineTime >= timelineTime &&
          !foldedLines.includes(frame.line)
        )
      })

      // If there's no frame after the timeline time, return the last frame
      if (idx == -1) return frames.length - 1

      // If we have the first frame, then there's no need to check previous ones
      if (idx == 0) return idx

      // Get the previous frame to compare with
      const prevFrameIdx = findPrevFrameIdx(idx)

      // If there's no previous frame, then we're happy with what we've got
      if (!prevFrameIdx) return idx

      // Return the id of whichever of the previous frame and this frame is closest
      return Math.abs(frames[idx - 1].timelineTime - timelineTime) <
        Math.abs(frames[idx].timelineTime - timelineTime)
        ? prevFrameIdx
        : idx
    },
    [frames, findPrevFrameIdx, foldedLines]
  )

  // Similarly we have checkers for breakpoints. These also
  // check for folding as we don't jump to a breakpoint that's
  // folded.
  const findPrevBreakpointFrame = useCallback(
    (currentIndex: number): Frame | undefined =>
      frames
        .slice(0, currentIndex)
        .findLast(
          (frame) =>
            breakpoints.includes(frame.line) &&
            !foldedLines.includes(frame.line)
        ),
    [breakpoints, foldedLines, frames]
  )
  const findNextBreakpointFrame = useCallback(
    (currentIndex: number): Frame | undefined =>
      frames
        .slice(currentIndex + 1)
        .find(
          (frame) =>
            breakpoints.includes(frame.line) &&
            !foldedLines.includes(frame.line)
        ),
    [breakpoints, foldedLines, frames]
  )
  const findBreakpointFrameBetweenTimes = useCallback(
    (startTimelineTime: number, endTimelineTime: number): Frame | undefined =>
      frames.find(
        (frame) =>
          frame.timelineTime > startTimelineTime &&
          frame.timelineTime < endTimelineTime &&
          breakpoints.includes(frame.line) &&
          !foldedLines.includes(frame.line)
      ),
    [frames, breakpoints, foldedLines]
  )

  const findFrameNearestTimelineTime = useCallback(
    (timelineTime: number): Frame | undefined => {
      if (!frames.length) return undefined

      // If we're past the last frame, return the last frame
      if (timelineTime > lastFrame.timelineTime) return lastFrame

      const idx = findFrameIdxNearestTimelineTime(timelineTime)
      if (idx === undefined) return undefined

      return frames[idx]
    },
    [frames, findFrameIdxNearestTimelineTime, lastFrame]
  )

  const moveToFrame = useCallback(
    (
      animationTimeline: AnimationTimeline,
      newFrame: Frame,
      newTimelineTime?: number,
      pause: boolean = true
    ) => {
      const isLastFrame = newFrame.timelineTime == lastFrame.timelineTime
      newTimelineTime = newTimelineTime || newFrame.timelineTime

      // Update to the new frame time.
      if (pause) {
        // throw new Error("H4")
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
          animationTimeline.seek(
            newTimelineTime / TIME_TO_TIMELINE_SCALE_FACTOR
          )
        }
      }

      // Finally, set the new time. Note, this potentially gets
      // changed in the aimationTimeline block above, so don't do it
      // early and guard/return.
      setTimelineValue(newTimelineTime)
    },
    [frames, lastFrame]
  )

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
  }, [rangeRef.current])

  // Whenever the information widget is shown, we want to pause the animation
  // and scroll to the relevant line. This effect means when the information
  // toggle button is pressed the animation will stop and scroll to the right
  // place. We don't scroll to the line while the animation is playing as it's
  // really annoying when you're trying to debug.
  useEffect(() => {
    if (shouldShowInformationWidget) {
      animationTimeline.pause()
      const frame = findFrameNearestTimelineTime(timelineValue)
      if (frame == undefined) return

      scrollToLine(editorView, frame.line)
    }
  }, [shouldShowInformationWidget])

  // This effect ensures there's an actual frame when the user pauses the
  // timeline (via any means). The other effects check the timeline syncs
  // at each step that's played, but they don't guarantee that a pause
  // at a weird halfway point will sync up. This guards that.
  useEffect(() => {
    // We use a set timeout as we want to ensure this is actually paused
    // not just in a pause/unpause cycle, which we often use to clear
    // state just before we start playing. 10ms is enough and not noticable
    // to the user.
    setTimeout(() => {
      // If we're actually now playing, then don't do anything here.
      if (!animationTimeline.paused) return

      // If we've not played, we're not propery pausing, so don't
      // override whatever over effect is driving this.
      if (timelineValue == -1) return

      const newTimelineValue = Math.round(
        animationTimeline.progress * TIME_TO_TIMELINE_SCALE_FACTOR
      )

      // If we're already locked onto a frame, then leave
      if (frames.some((frame) => frame.timelineTime === newTimelineValue))
        return

      // Otherwise jump to the nearest actual frame.
      moveToFrame(
        animationTimeline,
        findFrameNearestTimelineTime(newTimelineValue) || frames[0]
      )
    }, 10)
  }, [animationTimeline.paused, findFrameNearestTimelineTime, moveToFrame])

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
        const nextBreakpointFrame = findBreakpointFrameBetweenTimes(
          timelineValue,
          newTimelineValue
        )

        if (nextBreakpointFrame && !isSpotlightActive) {
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
  }, [
    animationTimeline,
    frames,
    findBreakpointFrameBetweenTimes,
    isSpotlightActive,
  ])

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
    const breakpointFrame = findBreakpointFrameBetweenTimes(
      0,
      errorFrame.timelineTime
    )
    if (breakpointFrame) {
      moveToFrame(animationTimeline, breakpointFrame)

      // We also want to turn on the info widget if
      // we're jumping to a breakpoint.
      setShouldShowInformationWidget(true)
      return
    }

    // Otherwise we proceed straight to our error frame.
    moveToFrame(animationTimeline, errorFrame)
  }, [frames, findBreakpointFrameBetweenTimes])

  // This effect is responsible for updating the highlighted line and
  // information widget based on currentFrame. It runs every time the timelineValue
  // changes, which happens on any type of navigation or animation.
  useEffect(() => {
    const currentFrame = findFrameNearestTimelineTime(timelineValue)

    cleanUpEditor(editorView)

    // If for some reason we don't have a frame here, return
    // (although I don't see how this is possible).
    if (!currentFrame) return

    // Don't show lines while the animation is playing.
    if (!animationTimeline.paused) return

    setHighlightedLine(currentFrame.line)

    // We don't want to scroll to the line unless the tooltip
    // is showing - it's really annoying otherwise!
    if (shouldShowInformationWidget) {
      scrollToLine(editorView, currentFrame.line)
    }

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
    const frame = findFrameNearestTimelineTime(timelineTime)
    if (frame === undefined) return

    moveToFrame(animationTimeline, frame, timelineTime, false)
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
      animationTimeline: AnimationTimeline
    ) => {
      const timelineTime = Number((event.target as HTMLInputElement).value)
      const newFrame = findFrameNearestTimelineTime(timelineTime)

      if (newFrame === undefined) return

      moveToFrame(animationTimeline, newFrame, timelineTime)
      setShouldShowInformationWidget(true)
    },
    []
  )

  // When we're sliding along the scrubber, we can sort of sit in between two
  // frames, and that's fine. It allows the user to watch the animation back.
  // But when they let go of the mouse we need to lock onto a frame. So this
  // does that. It grabs the nearest frame to the current scrub and moves to it.
  const handleOnMouseUp = useCallback(
    (animationTimeline: AnimationTimeline, frames: Frame[]) => {
      const newFrame = findFrameNearestTimelineTime(timelineValue)
      if (newFrame === undefined) return

      moveToFrame(animationTimeline, newFrame)
    },
    [timelineValue, findFrameNearestTimelineTime, moveToFrame]
  )

  const handleGoToBreakpoint = useCallback(
    (direction: 'previous' | 'next', animationTimeline: AnimationTimeline) => {
      if (breakpoints.length === 0) return

      let currentFrameIdx = findFrameIdxNearestTimelineTime(timelineValue)
      if (currentFrameIdx === undefined) return

      let newFrame =
        direction == 'previous'
          ? findPrevBreakpointFrame(currentFrameIdx)
          : findNextBreakpointFrame(currentFrameIdx)

      if (newFrame == undefined) return

      moveToFrame(animationTimeline, newFrame)
      setShouldShowInformationWidget(true)
    },
    [
      timelineValue,
      breakpoints,
      findFrameIdxNearestTimelineTime,
      findPrevBreakpointFrame,
      findNextBreakpointFrame,
      moveToFrame,
    ]
  )

  const handleGoToPreviousBreakpoint = (animationTimeline: AnimationTimeline) =>
    handleGoToBreakpoint('previous', animationTimeline)

  const handleGoToNextBreakpoint = (animationTimeline: AnimationTimeline) =>
    handleGoToBreakpoint('next', animationTimeline)

  const handleGoToPreviousFrame = useCallback(
    (animationTimeline: AnimationTimeline, frames: Frame[]) => {
      let currentFrameIdx = findFrameIdxNearestTimelineTime(timelineValue)

      // If there's no frame for this, then we've got no-where to go
      // And if we're at the start (or before!) there's also nothing to do
      if (currentFrameIdx === undefined || currentFrameIdx < 1) {
        return
      }

      const prevFrameIdx = findPrevFrameIdx(currentFrameIdx)

      // If we have no previous frame, then there's nothing to do
      if (prevFrameIdx === undefined) {
        return
      }

      moveToFrame(animationTimeline, frames[prevFrameIdx])
      setShouldShowInformationWidget(true)
    },
    [
      timelineValue,
      findFrameIdxNearestTimelineTime,
      findPrevFrameIdx,
      moveToFrame,
    ]
  )

  const handleGoToNextFrame = useCallback(
    (animationTimeline: AnimationTimeline, frames: Frame[]) => {
      const currentFrameIdx = findFrameIdxNearestTimelineTime(timelineValue)

      // If there's no current frame, something has gone very
      // wrong, so let's just do nothing!
      if (currentFrameIdx === undefined) return

      const nextFrame = findNextFrame(currentFrameIdx)

      if (nextFrame === undefined) return

      moveToFrame(animationTimeline, nextFrame)
      setShouldShowInformationWidget(true)
    },
    [timelineValue, findFrameIdxNearestTimelineTime, findNextFrame, moveToFrame]
  )

  const handleGoToFirstFrame = useCallback(
    (animationTimeline: AnimationTimeline) => {
      moveToFrame(animationTimeline, frames[0])
      setShouldShowInformationWidget(true)
    },
    [frames]
  )

  const handleGoToEndOfTimeline = useCallback(
    (animationTimeline: AnimationTimeline) => {
      moveToFrame(animationTimeline, lastFrame)
      setShouldShowInformationWidget(true)
    },
    [lastFrame]
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
        handleGoToFirstFrame(animationTimeline)
        break

      case 'ArrowUp':
        handleGoToEndOfTimeline(animationTimeline)
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
    findFrameNearestTimelineTime,
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
