import React from 'react'
import { StepButton } from './components/StepButton'

export function SelectedOnlineEdiorStep({
  onContinueToOnlineEditor,
  onGoBack,
}: Record<'onGoBack' | 'onContinueToOnlineEditor', () => void>): JSX.Element {
  return (
    <>
      <header>
        <p>
          Great. In that case let&apos;s jump straight into the first exercise -
          “Hello, World!
        </p>
      </header>

      <div className="flex gap-12 items-center">
        <StepButton onClick={onGoBack}>Go back</StepButton>
        <StepButton onClick={onContinueToOnlineEditor}>
          Continue to online editor
        </StepButton>
      </div>
    </>
  )
}
