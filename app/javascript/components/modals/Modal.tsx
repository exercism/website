import React, { useLayoutEffect } from 'react'
import * as ReactModal from 'react-modal'

export const Modal = ({
  open,
  onClose,
  children,
  ...props
}: {
  open: boolean
  onClose: () => void
  children?: React.ReactNode
}): JSX.Element => {
  useLayoutEffect(() => {
    // Required for accessibility: http://reactcommunity.org/react-modal/accessibility/#app-element
    ReactModal.setAppElement(document.querySelector('body') as HTMLElement)
  })

  return (
    <ReactModal isOpen={open} onRequestClose={onClose} {...props}>
      {children}
    </ReactModal>
  )
}
