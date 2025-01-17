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
import useAnimationTimelineStore from '../store/animationTimelineStore'

const FRAME_DURATION = 50

export function useScrubber({
  setIsPlaying,
  animationTimeline,
  frames,
}: {
  setIsPlaying: React.Dispatch<React.SetStateAction<boolean>>
  animationTimeline: AnimationTimeline | undefined | null
  frames: Frame[]
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

  const { isTimelineComplete, setIsTimelineComplete } =
    useAnimationTimelineStore()

  // this effect is responsible for updating the scrubber value based on the current time of animationTimeline
  useEffect(() => {
    if (animationTimeline) {
      animationTimeline.onUpdate((anime) => {
        setTimeout(() => {
          setValue(anime.currentTime)
        }, FRAME_DURATION)
      })
    } else {
      setValue(0)
    }
    // TODO Add something very specific to listen to here
  }, [animationTimeline?.completed])

  // this effect is responsible for updating the highlighted line and information widget based on currentFrame
  useEffect(() => {
    let currentFrame: Frame | undefined = frames.find(
      (f) => f.status === 'ERROR'
    )

    if (!currentFrame) {
      if (animationTimeline) {
        currentFrame = animationTimeline.currentFrame
      } else {
        currentFrame = frames[value]
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
    // TODO: same as above
    value,
    animationTimeline?.currentFrameIndex,
    frames,
  ])

  useEffect(() => {
    if (animationTimeline?.timeline.completed) {
      setIsTimelineComplete(true)
    } else {
      setIsTimelineComplete(false)
    }
  }, [animationTimeline?.timeline.completed])

  // when user switches between test results, scrub to animation timeline's persisted currentTime
  useEffect(() => {
    if (!animationTimeline) {
      return
    }
    handleScrubToCurrentTime(animationTimeline)
  }, [animationTimeline?.timeline.currentTime])

  const handleScrubToCurrentTime = useCallback(
    (animationTimeline: AnimationTimeline | undefined | null) => {
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
      animationTimeline: AnimationTimeline | undefined | null,
      frames: Frame[]
    ) => {
      const newValue = Number((event.target as HTMLInputElement).value)
      setValue(newValue)

      if (animationTimeline) {
        animationTimeline.pause()
        animationTimeline.seek(newValue)
      } else {
        const validIndex = Math.max(0, newValue)
        const highlightedLine = newValue === -1 ? 0 : frames[validIndex].line
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
      animationTimeline: AnimationTimeline | undefined | null,
      frames: Frame[]
    ) => {
      if (informationWidgetData.line === 0) {
        handleChange(event, animationTimeline, frames)
      }
    },
    [handleChange, informationWidgetData.line]
  )

  const scrubberValueAnimation = useRef<AnimeInstance | null>()

  const handleOnMouseUp = useCallback(
    (
      animationTimeline: AnimationTimeline | undefined | null,
      frames: Frame[]
    ) => {
      if (!animationTimeline) return
      // find closest frame to progress
      const { progress } = animationTimeline
      const { duration } = animationTimeline.timeline
      let closestTime = duration
      let closestDifference = Math.abs(duration - progress)

      for (const frame of frames) {
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
    (
      animationTimeline: AnimationTimeline | undefined | null,
      frames: Frame[]
    ) => {
      if (!animationTimeline) {
        // index shouldn't be under 0 or above the last frame
        const validIndex = Math.min(Math.max(0, value - 1), frames.length - 1)
        setValue(validIndex)
        return
      }

      if (scrubberValueAnimation.current) {
        anime.remove(scrubberValueAnimation.current)
      }

      const currentTime = animationTimeline.progress
      const lastFrameTime = frames[frames.length - 1].time

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
    (
      animationTimeline: AnimationTimeline | undefined | null,
      frames: Frame[]
    ) => {
      if (!animationTimeline) {
        // index shouldn't be under 0 or above the last frame
        const validIndex = Math.min(Math.max(0, value + 1), frames.length - 1)
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

  const handleGoToFirstFrame = useCallback(
    (animationTimeline: AnimationTimeline | undefined | null) => {
      if (animationTimeline) {
        animationTimeline.seekFirstFrame()
        scrollToHighlightedLine()
      }
    },
    []
  )

  const handleGoToEndOfTimeline = useCallback(
    (animationTimeline: AnimationTimeline | undefined | null) => {
      if (animationTimeline) {
        animationTimeline.seekEndOfTimeline()
        scrollToHighlightedLine()
      }
    },
    []
  )

  /*
   when holding a key down, store it in a set and escape invoking frame-stepping handlers.
   let user browse scrubber freely
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
  }, [value])

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

export function calculateMaxInputValue(
  animationTimeline: AnimationTimeline | undefined | null,
  frames: Frame[]
) {
  if (animationTimeline) {
    return animationTimeline.timeline.duration
  }

  return frames.length - 1
}
