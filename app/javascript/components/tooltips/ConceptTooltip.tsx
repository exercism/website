import React from 'react'
import { Tooltip } from './Tooltip'

interface ConceptTooltipProps {
  contentEndpoint: string
  hoverRequestToShow: boolean
  focusRequestToShow: boolean
  referenceElement: HTMLElement | null
  referenceConceptSlug: string
  focusable?: boolean
}

export const ConceptTooltip = ({
  contentEndpoint,
  hoverRequestToShow,
  focusRequestToShow,
  referenceElement,
  referenceConceptSlug,
}: ConceptTooltipProps): JSX.Element | null => {
  const tooltipId = `concept-tooltip${
    referenceConceptSlug ? `-${referenceConceptSlug}` : referenceConceptSlug
  }`

  return (
    <Tooltip
      id={tooltipId}
      className="c-concept-tooltip"
      referenceElement={referenceElement}
      contentEndpoint={contentEndpoint}
      hoverRequestToShow={hoverRequestToShow}
      focusRequestToShow={focusRequestToShow}
      focusable={false}
    />
  )
}
