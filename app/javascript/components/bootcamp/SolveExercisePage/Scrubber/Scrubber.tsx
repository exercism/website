import React from 'react'
import { useEffect, useState } from 'react'
import { calculateMaxInputValue, useScrubber } from './useScrubber'
import useEditorStore from '@/components/bootcamp/SolveExercisePage/store/editorStore'
import { TooltipInformation } from './ScrubberTooltipInformation'
import { InformationWidgetToggleButton } from './InformationWidgetToggleButton'
import { Icon } from '@/components/common'
import { Frame } from '@/interpreter/frames'
import { AnimationTimeline } from '../AnimationTimeline/AnimationTimeline'

function Scrubber({
  animationTimeline,
  frames,
}: {
  animationTimeline: AnimationTimeline | undefined | null
  frames: Frame[]
}) {
  const [isPlaying, setIsPlaying] = useState(false)

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
    handleScrubToCurrentTime,
  } = useScrubber({
    setIsPlaying,
    animationTimeline,
    frames,
  })

  useEffect(() => {
    if (isPlaying || hasCodeBeenEdited) {
      setShouldShowInformationWidget(false)
    }
  }, [isPlaying, hasCodeBeenEdited])

  // when user switches between test results, scrub to animation timeline's persisted currentTime
  useEffect(() => {
    if (!animationTimeline) {
      return
    }
    handleScrubToCurrentTime(animationTimeline)
  }, [animationTimeline?.timeline.currentTime])

  return (
    <div
      data-cy="scrubber"
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
            frames
          )}
          onClick={() => {
            animationTimeline?.play(() => setShouldShowInformationWidget(false))
          }}
        />
      )}
      <input
        data-cy="scrubber-range-input"
        disabled={shouldScrubberBeDisabled(
          hasCodeBeenEdited,
          animationTimeline,
          frames
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
          frames
        )}
      />
      <InformationWidgetToggleButton disabled={hasCodeBeenEdited} />
      <TooltipInformation
        hasCodeBeenEdited={hasCodeBeenEdited}
        notEnoughFrames={frames.length === 1}
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
    <button disabled={disabled} className="play-button" onClick={onClick}>
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
    <div className="frame-stepper-buttons">
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
  frames: Frame[]
) {
  // if the code has been edited, the scrubber should be disabled
  // if there is no animation timeline and there is only one frame, the scrubber should be disabled
  return hasCodeBeenEdited || (!animationTimeline && frames.length === 1)
}
