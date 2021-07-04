import React, { forwardRef } from 'react'
import { ExerciseStatus } from '../types'
import { usePanel } from '../../hooks/use-panel'
import { ExerciseTooltip } from '../tooltips/ExerciseTooltip'

export const ExerciseStatusDot = ({
  slug,
  exerciseStatus,
  type,
  links,
}: {
  slug: string
  exerciseStatus: ExerciseStatus
  type: string
  links: {
    tooltip: string
    exercise?: string
  }
}): JSX.Element => {
  const { open, setOpen, buttonAttributes, panelAttributes } = usePanel({
    placement: 'right-start',
    modifiers: [
      {
        name: 'offset',
        options: {
          offset: [0, 8],
        },
      },
    ],
  })

  return (
    <React.Fragment>
      <ReferenceElement
        {...buttonAttributes}
        onMouseEnter={() => setOpen(true)}
        onMouseLeave={() => setOpen(false)}
        className={`c-ed --${exerciseStatus} --${type}`}
        link={links.exercise}
      />
      {open ? (
        <ExerciseTooltip
          slug={slug}
          endpoint={links.tooltip}
          {...panelAttributes}
        />
      ) : null}
    </React.Fragment>
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
