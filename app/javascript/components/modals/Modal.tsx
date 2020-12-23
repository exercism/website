import React, { useLayoutEffect } from 'react'
import { default as ReactModal } from 'react-modal'

export const Modal = ({
  open,
  onClose,
  children,
  className,
  ...props
}: {
  open: boolean
  onClose: () => void
  children?: React.ReactNode
  className: string
}): JSX.Element => {
  useLayoutEffect(() => {
    // Required for accessibility: http://reactcommunity.org/react-modal/accessibility/#app-element
    ReactModal.setAppElement(document.querySelector('body') as HTMLElement)
  })

  const reactModalProps = {
    ...props,
    className: 'modal-content',
    overlayClassName: `${className} modal-overlay`,
  }

  return (
    <ReactModal isOpen={open} onRequestClose={onClose} {...reactModalProps}>
      {children}
    </ReactModal>
  )
}
