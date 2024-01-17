import React from 'react'
import { StepButton } from './components/StepButton'

export function SelectedOnlineEdiorStep({
  onContinueToOnlineEditor,
}: Record<'onContinueToOnlineEditor', () => void>): JSX.Element {
  return (
    <>
      <p>
        Great. In that case let&apos;s jump straight into the first exercise -
        “Hello, World!
      </p>

      <StepButton onClick={onContinueToOnlineEditor}>
        Continue to online editor
      </StepButton>
    </>
  )
}
