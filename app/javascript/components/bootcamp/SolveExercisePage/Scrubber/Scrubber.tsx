import React, { useContext, useEffect, useMemo } from 'react'
import { useState } from 'react'
import { calculateMaxInputValue, useScrubber } from './useScrubber'
import useEditorStore from '@/components/bootcamp/SolveExercisePage/store/editorStore'
import { InformationWidgetToggleButton } from './InformationWidgetToggleButton'
import { Icon } from '@/components/common'
import { Frame } from '@/interpreter/frames'
import { AnimationTimeline } from '../AnimationTimeline/AnimationTimeline'
import { TooltipInformation } from './ScrubberTooltipInformation'
import { SolveExercisePageContext } from '../SolveExercisePageContextWrapper'
import { getBreakpointLines } from '../CodeMirror/getBreakpointLines'
import { t } from 'xstate'

function Scrubber({
  animationTimeline,
  frames,
  context,
}: {
  animationTimeline: AnimationTimeline | undefined | null
  frames: Frame[]
  context?: string
}) {
  const [_, setIsPlaying] = useState(false)

  const { hasCodeBeenEdited, setShouldShowInformationWidget } = useEditorStore()
  const { isSpotlightActive } = useContext(SolveExercisePageContext)

  const {
    timelineValue,
    handleChange,
    handleOnMouseUp,
    handleOnKeyUp,
    handleOnKeyDown,
    updateInputBackground,
    rangeRef,
    handleGoToNextFrame,
    handleGoToPreviousFrame,
    handleGoToNextBreakpoint,
    handleGoToPreviousBreakpoint,
  } = useScrubber({
    setIsPlaying,
    animationTimeline,
    frames,
    hasCodeBeenEdited,
    context,
  })

  return (
    <div
      data-ci="scrubber"
      id="scrubber"
      onClick={() => {
        // we wanna focus the range input, so keyboard shortcuts work
        rangeRef.current?.focus()
      }}
      tabIndex={-1}
      className="relative group"
    >
      {animationTimeline && (
        <PlayButton
          disabled={shouldScrubberBeDisabled(
            hasCodeBeenEdited,
            animationTimeline,
            frames,
            isSpotlightActive
          )}
          onClick={() => {
            animationTimeline?.play(() => setShouldShowInformationWidget(false))
          }}
        />
      )}
      <input
        data-ci="scrubber-range-input"
        disabled={shouldScrubberBeDisabled(
          hasCodeBeenEdited,
          animationTimeline,
          frames,
          isSpotlightActive
        )}
        type="range"
        onKeyUp={(event) => handleOnKeyUp(event, animationTimeline)}
        onKeyDown={(event) => handleOnKeyDown(event, animationTimeline, frames)}
        min={0}
        ref={rangeRef}
        max={calculateMaxInputValue(animationTimeline, frames)}
        onInput={updateInputBackground}
        value={timelineValue}
        onChange={(event) => {
          handleChange(event, animationTimeline, frames)
          updateInputBackground()
        }}
        onMouseUp={() => handleOnMouseUp(animationTimeline, frames)}
      />
      <FrameStepperButtons
        onNext={() => handleGoToNextFrame(animationTimeline, frames)}
        onPrev={() => handleGoToPreviousFrame(animationTimeline, frames)}
        disabled={shouldScrubberBeDisabled(
          hasCodeBeenEdited,
          animationTimeline,
          frames,
          isSpotlightActive
        )}
      />
      <BreakpointStepperButtons
        timelineTime={timelineValue}
        frames={frames}
        onNext={() => handleGoToNextBreakpoint(animationTimeline, frames)}
        onPrev={() => handleGoToPreviousBreakpoint(animationTimeline, frames)}
        disabled={shouldScrubberBeDisabled(
          hasCodeBeenEdited,
          animationTimeline,
          frames,
          isSpotlightActive
        )}
      />
      <InformationWidgetToggleButton
        disabled={hasCodeBeenEdited || isSpotlightActive}
      />
      <TooltipInformation
        hasCodeBeenEdited={hasCodeBeenEdited}
        notEnoughFrames={frames.length === 1}
        animationTimeline={animationTimeline}
      />
    </div>
  )
}

export default Scrubber

function PlayButton({
  disabled,
  onClick,
}: {
  disabled: boolean
  onClick: () => void
}) {
  return (
    <button
      data-ci="play-button"
      disabled={disabled}
      className="play-button"
      onClick={onClick}
    >
      <Icon icon="bootcamp-play" alt="Play" width={32} height={32} />
    </button>
  )
}

function FrameStepperButtons({
  onNext,
  onPrev,
  disabled,
}: {
  onNext: () => void
  onPrev: () => void
  disabled: boolean
}) {
  return (
    <div data-ci="frame-stepper-buttons" className="frame-stepper-buttons">
      <button disabled={disabled} onClick={onPrev}>
        <Icon
          icon="bootcamp-chevron-right"
          alt="Previous"
          className="rotate-180"
        />
      </button>
      <button disabled={disabled} onClick={onNext}>
        <Icon icon="bootcamp-chevron-right" alt="Next" />
      </button>
    </div>
  )
}

function BreakpointStepperButtons({
  timelineTime,
  frames,
  onNext,
  onPrev,
  disabled,
}: {
  timelineTime: number
  frames: Frame[]
  onNext: () => void
  onPrev: () => void
  disabled: boolean
}) {
  const { breakpoints } = useEditorStore()
  if (breakpoints.length == 0) return null

  const isPrevBreakpoint = prevBreakpointExists(
    timelineTime,
    frames,
    breakpoints
  )
  const isNextBreakpoint = nextBreakpointExists(
    timelineTime,
    frames,
    breakpoints
  )

  return (
    <div data-ci="frame-stepper-buttons" className="breakpoint-stepper-buttons">
      <button disabled={disabled || !isPrevBreakpoint} onClick={onPrev}>
        <Icon
          icon="bootcamp-chevron-right"
          alt="Previous"
          className="rotate-180"
        />
      </button>
      <button disabled={disabled || !isNextBreakpoint} onClick={onNext}>
        <Icon icon="bootcamp-chevron-right" alt="Next" />
      </button>
    </div>
  )
}

function prevBreakpointExists(
  timelineTime: number,
  frames: Frame[],
  breakpoints: number[]
) {
  return breakpoints.some((breakpoint) => {
    return frames.some((frame) => {
      return frame.line === breakpoint && frame.timelineTime < timelineTime
    })
  })
}

function nextBreakpointExists(
  timelineTime: number,
  frames: Frame[],
  breakpoints: number[]
) {
  return breakpoints.some((breakpoint) => {
    return frames.some((frame) => {
      return frame.line === breakpoint && frame.timelineTime > timelineTime
    })
  })
}

function shouldScrubberBeDisabled(
  hasCodeBeenEdited: boolean,
  animationTimeline: AnimationTimeline | undefined | null,
  frames: Frame[],
  isSpotlightActive: boolean
) {
  // if the code has been edited, the scrubber should be disabled
  // if there is no animation timeline and there is only one frame, the scrubber should be disabled
  return (
    hasCodeBeenEdited ||
    (!animationTimeline && frames.length === 1) ||
    isSpotlightActive
  )
}
