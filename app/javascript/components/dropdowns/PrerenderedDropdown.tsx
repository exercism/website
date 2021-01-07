import React from 'react'
import { Dropdown } from './Dropdown'

interface PrerenderedDropdownProps {
  id: string
  className: string
  referenceElement: HTMLElement | null
  prerenderedContent: string
}

export const PrerenderedDropdown = ({
  id,
  className,
  referenceElement,
  prerenderedContent,
}: PrerenderedDropdownProps): JSX.Element | null => {
  return (
    <Dropdown
      id={id}
      className={className}
      referenceElement={referenceElement}
      prerenderedContent={prerenderedContent}
    />
  )
}
