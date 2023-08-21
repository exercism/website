import React, { forwardRef } from 'react'
import { ExerciseStatus } from '../types'
import { ExerciseTooltip } from '../tooltips/ExerciseTooltip'
import { ExercismTippy } from '../misc/ExercismTippy'

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
    <ExercismTippy
      delay={100}
      content={<ExerciseTooltip endpoint={links.tooltip} />}
    >
      <ReferenceElement
        className={`c-ed --${exerciseStatus} --${type}`}
        link={links.exercise}
      />
    </ExercismTippy>
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
