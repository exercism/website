import React from 'react'
import { Dropdown } from './Dropdown'

interface ProfileDropdownProps {
  prerenderedContent: string
  referenceElement: HTMLElement | null
}

export const ProfileDropdown = ({
  prerenderedContent,
  referenceElement,
}: ProfileDropdownProps): JSX.Element | null => {
  return (
    <Dropdown
      id="profile-dropdown"
      className="c-profile-dropdown"
      referenceElement={referenceElement}
      prerenderedContent={prerenderedContent}
    />
  )
}
