import React from 'react'
import { LazyTippy, LazyTippyProps } from './LazyTippy'
import { followCursor, roundArrow } from 'tippy.js'

export type ExercismTippyProps = LazyTippyProps

export const ExercismTippy = (props: ExercismTippyProps): JSX.Element => {
  return (
    <LazyTippy
      animation="shift-away-subtle"
      followCursor="horizontal"
      maxWidth="none"
      plugins={[followCursor]}
      delay={100}
      {...props}
    />
  )
}

export const GenericTooltip = (props: ExercismTippyProps): JSX.Element => {
  return (
    <ExercismTippy
      arrow={roundArrow}
      {...props}
      content={
        <div className={`c-generic-tooltip ${props.className}`}>
          {props.content}
        </div>
      }
    />
  )
}
