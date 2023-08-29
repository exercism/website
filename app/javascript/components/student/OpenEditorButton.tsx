import React, { JSXElementConstructor } from 'react'
import CopyToClipboardButton from '@/components/common/CopyToClipboardButton'
import {
  ComboButton,
  PrimarySegment,
  DropdownSegment,
} from '@/components/common/ComboButton'
import { GenericTooltip } from '@/components/misc/ExercismTippy'
import { StartExerciseButton } from './open-editor-button/StartExerciseButton'

type Props =
  | {
      editorEnabled: boolean
      status: 'locked'
      command: string
      links: { local: string }
    }
  | {
      editorEnabled: boolean
      status: 'available'
      command: string
      links: { start: string; local: string }
    }
  | {
      editorEnabled: boolean
      status: 'completed' | 'published'
      command: string
      links: { exercise: string; local: string }
    }
  | {
      editorEnabled: boolean
      status: 'iterated' | 'started'
      command: string
      links: { exercise: string; local: string }
    }

export default function OpenEditorButton(props: Props): JSX.Element | null {
  return (
    <ButtonTooltip {...props}>
      <ComboButton enabled={props.status !== 'locked'}>
        <PrimarySegment>
          <Button {...props} />
        </PrimarySegment>
        <DropdownSegment>
          <DropdownPanel {...props} />
        </DropdownSegment>
      </ComboButton>
    </ButtonTooltip>
  )
}

const Button = (props: Props & { className?: string }) => {
  switch (props.status) {
    case 'locked':
      return props.editorEnabled ? (
        <div className={props.className}>Open in editor</div>
      ) : (
        <button className={`${props.className} --disabled`}>
          Open in editor
        </button>
      )
    case 'available':
      return props.editorEnabled ? (
        <StartExerciseButton
          endpoint={props.links.start}
          className={props.className}
        />
      ) : (
        <button className={`${props.className} --disabled`}>
          Start in editor
        </button>
      )
    case 'published':
    case 'completed':
      return props.editorEnabled ? (
        <a href={props.links.exercise} className={props.className}>
          Open in editor
        </a>
      ) : (
        <button className={`${props.className} --disabled`}>
          Open in editor
        </button>
      )
    default:
      return props.editorEnabled ? (
        <a href={props.links.exercise} className={props.className}>
          Continue in editor
        </a>
      ) : (
        <button className={`${props.className} --disabled`}>
          Continue in editor
        </button>
      )
  }
}

const DropdownPanel = ({
  editorEnabled,
  command,
  links,
}: {
  editorEnabled: boolean
  command: string
  links: { local: string }
}) => {
  const downloadPrompt = editorEnabled
    ? `Prefer to use the tools you're familiar with, than our online editor? No problem!`
    : 'This exercise is not available using the online editor.'

  return (
    <div className="c-open-editor-button-dropdown">
      <h3>Download and work locally</h3>
      <p>
        {downloadPrompt} You can download this exercise and work on it locally,
        then submit it when you&apos;re happy.
      </p>
      <CopyToClipboardButton textToCopy={command} />

      <p>
        First time using our local setup? Read our{' '}
        <a href={links.local} target="_blank" rel="noreferrer">
          guide to solving exercises locally
        </a>{' '}
        to understand the flow and install Exercism locally. Then come back here
        and use the command above to start the exercise.
      </p>
    </div>
  )
}

const ButtonTooltip = ({
  status,
  editorEnabled,
  children,
}: {
  status: string
  editorEnabled: boolean
  children:
    | React.ReactElement<any, string | JSXElementConstructor<any>>
    | undefined
}): JSX.Element | null => {
  if (!editorEnabled) {
    const content = (
      <>
        <p>
          The online editor is not available for this exercise. Solve this
          exercise locally and submit it via the CLI.
        </p>
        <p>Click the arrow to the right for more information.</p>
      </>
    )
    return <GenericTooltip content={content}>{children}</GenericTooltip>
  }

  if (status === 'locked') {
    return (
      <GenericTooltip content="This exercise is currently locked">
        {children}
      </GenericTooltip>
    )
  }

  return <React.Fragment>{children}</React.Fragment>
}
