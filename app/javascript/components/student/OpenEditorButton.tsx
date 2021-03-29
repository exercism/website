import React from 'react'
import { StartExerciseButton } from './open-editor-button/StartExerciseButton'

export const OpenEditorButton = (
  props:
    | { status: 'locked'; links: null }
    | { status: 'available'; links: { start: string } }
    | { status: 'completed' | 'published'; links: { exercise: string } }
    | { status: 'iterated' | 'started'; links: { exercise: string } }
): JSX.Element | null => {
  switch (props.status) {
    case 'locked':
      return (
        <div className="c-combo-button --disabled">
          <div className="--editor-segment">Open Editor</div>
        </div>
      )
    case 'available':
      return <StartExerciseButton endpoint={props.links.start} />
    case 'published':
    case 'completed':
      return (
        <div className="c-combo-button">
          <a href={props.links.exercise} className="--editor-segment">
            Open editor
          </a>
        </div>
      )
    default:
      return (
        <div className="c-combo-button">
          <a href={props.links.exercise} className="--editor-segment">
            Continue in editor
          </a>
        </div>
      )
  }
}
