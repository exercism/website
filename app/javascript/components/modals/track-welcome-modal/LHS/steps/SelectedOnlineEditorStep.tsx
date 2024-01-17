import React from 'react'
import { StepButton } from './components/StepButton'
import { ButtonContainer } from './components/ButtonContainer'

export function SelectedOnlineEdiorStep({
  onContinueToOnlineEditor,
  onReset,
}: Record<'onReset' | 'onContinueToOnlineEditor', () => void>): JSX.Element {
  return (
    <>
      <header>
        <p>
          Great. In that case let&apos;s jump straight into the first exercise -
          “Hello, World!
        </p>
      </header>

      <ButtonContainer>
        <StepButton onClick={onReset}>Reset</StepButton>
        <StepButton onClick={onContinueToOnlineEditor}>
          Continue to online editor
        </StepButton>
      </ButtonContainer>
    </>
  )
}
