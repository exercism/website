import React, { useContext } from 'react'
import { StepButton } from './components/StepButton'
import { ButtonContainer } from './components/ButtonContainer'
import CopyToClipboardButton from '@/components/common/CopyToClipboardButton'
import { TrackContext } from '../..'

export function SelectedLocalMachineStep({
  onContinueToLocalMachine,
  onReset,
}: Record<'onReset' | 'onContinueToLocalMachine', () => void>): JSX.Element {
  const { track } = useContext(TrackContext)
  return (
    <>
      <p className="mb-8">
        I&apos;ll write the text out later including a link to the CLI
        walkthrough, and the copy-to-clipboard widget for Hello World. If you
        get those links in, I&apos;ll do the rest.
      </p>
      <CopyToClipboardButton
        textToCopy={`exercism download --exercise=hello-world --track=${track.title}`}
      />
      <ButtonContainer>
        <StepButton onClick={onReset}>Reset</StepButton>
        <StepButton onClick={onContinueToLocalMachine}>Continue</StepButton>
      </ButtonContainer>
    </>
  )
}
