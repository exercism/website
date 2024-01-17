import React from 'react'
import { StepButton } from './components/StepButton'

export function SelectedOnlineEdiorStep({
  onContinueToOnlineEditor,
}: Record<'onContinueToOnlineEditor', () => void>): JSX.Element {
  return (
    <>
      <p className="mb-16">
        Great. In that case let&apos;s jump straight into the first exercise -
        “Hello, World!
      </p>

      <StepButton onClick={onContinueToOnlineEditor} className="w-fit">
        Continue to online editor
      </StepButton>
    </>
  )
}
