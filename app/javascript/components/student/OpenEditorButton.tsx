import React from 'react'
import { CopyToClipboardButton } from '../common'
import {
  ComboButton,
  PrimarySegment,
  DropdownSegment,
} from '../common/ComboButton'
import { StartExerciseButton } from './open-editor-button/StartExerciseButton'
import { GenericTooltip } from '../misc/ExercismTippy'

export const OpenEditorButton = (
  props:
    | { status: 'locked'; command: string; links: null }
    | { status: 'available'; command: string; links: { start: string } }
    | {
        status: 'completed' | 'published'
        command: string
        links: { exercise: string }
      }
    | {
        status: 'iterated' | 'started'
        command: string
        links: { exercise: string }
      }
): JSX.Element | null => {
  let primarySegment

  switch (props.status) {
    case 'locked':
      primarySegment = <div>Open in editor</div>
      break
    case 'available':
      primarySegment = <StartExerciseButton endpoint={props.links.start} />
      break
    case 'published':
    case 'completed':
      primarySegment = <a href={props.links.exercise}>Open in editor</a>
      break
    default:
      primarySegment = <a href={props.links.exercise}>Continue in editor</a>
      break
  }

  return (
    <GenericTooltip
      disabled={props.status !== 'locked'}
      content="This exercise is currently locked"
    >
      <ComboButton enabled={props.status !== 'locked'}>
        <PrimarySegment>{primarySegment}</PrimarySegment>
        <DropdownSegment>
          {/* TODO: (required) Firm up this copy and inject the link */}
          <div className="c-open-editor-button-dropdown">
            <h3>Download and work locally</h3>
            <p>
              Prefer to use the tools you're familiar with, than our online
              editor? No problem! You can download this exericse and work on it
              locally, then submit it when you're happy.
            </p>
            <CopyToClipboardButton textToCopy={props.command} />

            <p>
              First time using our local setup? Read our{' '}
              <a href="#">guide to solving exercises locally</a> to understand
              the flow and instal Exercism locally. Then come back here and use
              the command above to start the exercise.
            </p>
          </div>
        </DropdownSegment>
      </ComboButton>
    </GenericTooltip>
  )
}
