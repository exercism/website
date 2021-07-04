import React from 'react'
import { Tooltip } from './Tooltip'

interface UserTooltipProps {
  contentEndpoint: string
  hoverRequestToShow: boolean
  focusRequestToShow: boolean
  referenceElement: HTMLElement | null
  referenceUserHandle: string
  placement?:
    | 'right'
    | 'auto'
    | 'auto-start'
    | 'auto-end'
    | 'top'
    | 'bottom'
    | 'left'
    | 'top-start'
    | 'top-end'
    | 'bottom-start'
    | 'bottom-end'
    | 'right-start'
    | 'right-end'
    | 'left-start'
    | 'left-end'
}

export const UserTooltip = ({
  contentEndpoint,
  hoverRequestToShow,
  focusRequestToShow,
  referenceElement,
  referenceUserHandle,
  placement,
}: UserTooltipProps): JSX.Element | null => {
  return (
    <Tooltip
      id={`user-tooltip-${referenceUserHandle}`}
      className="c-user-tooltip"
      referenceElement={referenceElement}
      contentEndpoint={contentEndpoint}
      hoverRequestToShow={hoverRequestToShow}
      focusRequestToShow={focusRequestToShow}
      placement={placement}
    />
  )
}
