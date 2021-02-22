import React, { useLayoutEffect } from 'react'
import { default as ReactModal, Props } from 'react-modal'

export type ModalProps = Omit<Props, 'isOpen' | 'onRequestClose'> & {
  className: string
  open: boolean
  onClose: () => void
  cover?: boolean
}

export const Modal = ({
  open,
  onClose,
  className,
  cover = false,
  ...props
}: React.PropsWithChildren<ModalProps>): JSX.Element => {
  useLayoutEffect(() => {
    // Required for accessibility: http://reactcommunity.org/react-modal/accessibility/#app-element
    ReactModal.setAppElement(document.querySelector('body') as HTMLElement)
  })

  const overlayClassNames = ['c-modal', className, cover ? '--cover' : '']

  const reactModalProps = {
    ...props,
    className: cover ? 'md-container' : '--modal-content',
    overlayClassName: overlayClassNames.join(' '),
  }

  return (
    <ReactModal isOpen={open} onRequestClose={onClose} {...reactModalProps} />
  )
}
