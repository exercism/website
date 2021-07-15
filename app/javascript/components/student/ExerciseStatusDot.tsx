import React, { forwardRef } from 'react'
import { ExerciseStatus } from '../types'
import { ExerciseTooltip } from '../tooltips/ExerciseTooltip'
import { followCursor } from 'tippy.js'
import { LazyTippy } from '../misc/LazyTippy'

export const ExerciseStatusDot = ({
  exerciseStatus,
  type,
  links,
}: {
  exerciseStatus: ExerciseStatus
  type: string
  links: {
    tooltip: string
    exercise?: string
  }
}): JSX.Element => {
  return (
    <LazyTippy
      animation="shift-away-subtle"
      followCursor="horizontal"
      maxWidth="none"
      plugins={[followCursor]}
      content={<ExerciseTooltip endpoint={links.tooltip} />}
    >
      <ReferenceElement
        className={`c-ed --${exerciseStatus} --${type}`}
        link={links.exercise}
      />
    </LazyTippy>
  )
}

const ReferenceElement = forwardRef<
  HTMLElement,
  React.HTMLProps<HTMLDivElement> &
    React.HTMLProps<HTMLAnchorElement> & { link?: string }
>(({ link, ...props }, ref) => {
  return link ? (
    <a href={link} ref={ref as React.RefObject<HTMLAnchorElement>} {...props} />
  ) : (
    <div ref={ref as React.RefObject<HTMLDivElement>} {...props} />
  )
})
