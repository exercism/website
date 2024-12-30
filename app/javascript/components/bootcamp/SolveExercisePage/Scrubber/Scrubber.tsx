import React from 'react'
import { useEffect, useState } from 'react'
import { calculateMaxInputValue, useScrubber } from './useScrubber'
import useEditorStore from '@/components/bootcamp/SolveExercisePage/store/editorStore'
import { TooltipInformation } from './ScrubberTooltipInformation'
import { InformationWidgetToggleButton } from './InformationWidgetTiggleButton'

function Scrubber({ testResult }: { testResult: NewTestResult }) {
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
    testResult,
  })

  useEffect(() => {
    if (isPlaying || hasCodeBeenEdited) {
      setShouldShowInformationWidget(false)
    }
  }, [isPlaying, hasCodeBeenEdited])

  // when user switches between test results, scrub to animation timeline's persisted currentTime
  useEffect(() => {
    if (!testResult.animationTimeline) {
      return
    }
    handleScrubToCurrentTime(testResult.animationTimeline)
  }, [testResult.animationTimeline?.timeline.currentTime])

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
      <PlayButton
        disabled={shouldScrubberBeDisabled(hasCodeBeenEdited, testResult)}
        onClick={() => testResult.animationTimeline?.play()}
      />
      <input
        data-cy="scrubber-range-input"
        disabled={shouldScrubberBeDisabled(hasCodeBeenEdited, testResult)}
        type="range"
        onKeyUp={(event) => handleOnKeyUp(event, testResult)}
        onKeyDown={(event) => handleOnKeyDown(event, testResult)}
        min={0}
        ref={rangeRef}
        max={calculateMaxInputValue(testResult)}
        onInput={updateInputBackground}
        value={value}
        onMouseDown={(event) => handleMouseDown(event, testResult)}
        onChange={(event) => {
          handleChange(event, testResult)
          updateInputBackground()
        }}
        onMouseUp={() => handleOnMouseUp(testResult)}
      />
      <FrameStepperButtons
        onNext={() => handleGoToNextFrame(testResult)}
        onPrev={() => handleGoToPreviousFrame(testResult)}
        disabled={shouldScrubberBeDisabled(hasCodeBeenEdited, testResult)}
      />
      <InformationWidgetToggleButton
        disabled={shouldScrubberBeDisabled(hasCodeBeenEdited, testResult)}
      />
      <TooltipInformation
        hasCodeBeenEdited={hasCodeBeenEdited}
        notEnoughFrames={testResult.frames.length === 1}
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
      <img src="/play.svg" alt="" width={32} height={32} />
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
        <img src="/chevron-right.svg" className="rotate-180" />
      </button>
      <button disabled={disabled} onClick={onNext}>
        <img src="/chevron-right.svg" />
      </button>
    </div>
  )
}

function shouldScrubberBeDisabled(
  hasCodeBeenEdited: boolean,
  testResult: NewTestResult
) {
  // if the code has been edited, the scrubber should be disabled
  // if there is no animation timeline and there is only one frame, the scrubber should be disabled
  return (
    hasCodeBeenEdited ||
    (!testResult.animationTimeline && testResult.frames.length === 1)
  )
}
