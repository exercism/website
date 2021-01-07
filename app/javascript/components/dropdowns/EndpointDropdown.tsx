import React, { useState } from 'react'
import { useContentQuery } from '../../hooks/use-content-query'
import { Dropdown } from './Dropdown'

interface EndpointDropdownProps {
  id: string
  className: string
  referenceElement: HTMLElement | null
  contentEndpoint: string
}

export const EndpointDropdown = ({
  id,
  className,
  referenceElement,
  contentEndpoint,
}: EndpointDropdownProps): JSX.Element | null => {
  const [showState, setShowState] = useState('loading')

  const { isLoading, isError, htmlContent } = useContentQuery(
    contentEndpoint,
    contentEndpoint,
    showState != 'hidden' && showState != 'error'
  )

  // short-circuit return null if not ready to display the tooltip
  if ((showState !== 'visible' && showState !== 'invisible') || !htmlContent) {
    return null
  }

  return (
    <Dropdown
      id={id}
      className={className}
      referenceElement={referenceElement}
      htmlContent={htmlContent}
    />
  )
}
