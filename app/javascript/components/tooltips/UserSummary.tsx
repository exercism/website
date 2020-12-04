import React from 'react'
import { Tooltip } from './Tooltip'

interface UserSummaryTooltipProps {
  contentEndpoint: string
  hoverRequestToShow: boolean
  focusRequestToShow: boolean
  referenceElement: HTMLElement | null
  referenceUserHandle: string
}

export const UserSummaryTooltip = ({
  contentEndpoint,
  hoverRequestToShow,
  focusRequestToShow,
  referenceElement,
  referenceUserHandle,
}: UserSummaryTooltipProps): JSX.Element | null => {
  return (
    <Tooltip
      id={`user-summary-tooltip-${referenceUserHandle}`}
      className="c-user-tooltip"
      referenceElement={referenceElement}
      contentEndpoint={contentEndpoint}
      hoverRequestToShow={hoverRequestToShow}
      focusRequestToShow={focusRequestToShow}
    />
  )
}
