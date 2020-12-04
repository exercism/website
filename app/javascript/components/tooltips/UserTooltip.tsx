import React from 'react'
import { Tooltip } from './Tooltip'

interface UserTooltipProps {
  contentEndpoint: string
  hoverRequestToShow: boolean
  focusRequestToShow: boolean
  referenceElement: HTMLElement | null
  referenceUserHandle: string
}

export const UserTooltip = ({
  contentEndpoint,
  hoverRequestToShow,
  focusRequestToShow,
  referenceElement,
  referenceUserHandle,
}: UserTooltipProps): JSX.Element | null => {
  return (
    <Tooltip
      id={`user-tooltip-${referenceUserHandle}`}
      className="c-user-tooltip"
      referenceElement={referenceElement}
      contentEndpoint={contentEndpoint}
      hoverRequestToShow={hoverRequestToShow}
      focusRequestToShow={focusRequestToShow}
    />
  )
}
