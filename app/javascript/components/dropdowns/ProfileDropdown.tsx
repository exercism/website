import React from 'react'
import { PrerenderedDropdown } from './PrerenderedDropdown'

interface ProfileDropdownProps {
  prerenderedContent: string
  referenceElement: HTMLElement | null
}

export const ProfileDropdown = ({
  prerenderedContent,
  referenceElement,
}: ProfileDropdownProps): JSX.Element | null => {
  return (
    <PrerenderedDropdown
      id="profile-dropdown"
      className="c-profile-dropdown"
      referenceElement={referenceElement}
      prerenderedContent={prerenderedContent}
    />
  )
}
