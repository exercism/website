import React from 'react'
import { LazyTippy, LazyTippyProps } from './LazyTippy'
import { followCursor } from 'tippy.js'

export type ExercismTippyProps = LazyTippyProps

export const ExercismTippy = (props: ExercismTippyProps): JSX.Element => {
  return (
    <LazyTippy
      animation="shift-away-subtle"
      followCursor="horizontal"
      maxWidth="none"
      plugins={[followCursor]}
      {...props}
    />
  )
}
