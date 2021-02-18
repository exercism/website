import React, { useLayoutEffect } from 'react'
import { default as ReactModal, Props } from 'react-modal'

export type ModalProps = Omit<Props, 'isOpen' | 'onRequestClose'> & {
  className: string
  open: boolean
  onClose: () => void
}

export const Modal = ({
  open,
  onClose,
  className,
  ...props
}: React.PropsWithChildren<ModalProps>): JSX.Element => {
  useLayoutEffect(() => {
    // Required for accessibility: http://reactcommunity.org/react-modal/accessibility/#app-element
    ReactModal.setAppElement(document.querySelector('body') as HTMLElement)
  })

  const reactModalProps = {
    ...props,
    className: '--modal-content',
    overlayClassName: `c-modal ${className}`,
  }

  return (
    <ReactModal isOpen={open} onRequestClose={onClose} {...reactModalProps} />
  )
}
