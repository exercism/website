import React from 'react'
import { useState } from 'react'
import { calculateMaxInputValue, useScrubber } from './useScrubber'
import useEditorStore from '@/components/bootcamp/SolveExercisePage/store/editorStore'
import { InformationWidgetToggleButton } from './InformationWidgetToggleButton'
import { Icon } from '@/components/common'
import { Frame } from '@/interpreter/frames'
import { AnimationTimeline } from '../AnimationTimeline/AnimationTimeline'
import { TooltipInformation } from './ScrubberTooltipInformation'

function Scrubber({
  animationTimeline,
  frames,
}: {
  animationTimeline: AnimationTimeline | undefined | null
  frames: Frame[]
}) {
  const [_, setIsPlaying] = useState(false)

  const { hasCodeBeenEdited, setShouldShowInformationWidget } = useEditorStore()

  const {
    value,
    handleChange,
    handleOnMouseUp,
    handleOnKeyUp,
    handleOnKeyDown,
    handleMouseDown,
    updateInputBackground,
    rangeRef,
    handleGoToNextFrame,
    handleGoToPreviousFrame,
    isSpotlightActive,
  } = useScrubber({
    setIsPlaying,
    animationTimeline,
    frames,
    hasCodeBeenEdited,
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
        value={value}
        onMouseDown={(event) =>
          handleMouseDown(event, animationTimeline, frames)
        }
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
