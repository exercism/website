import React, { useLayoutEffect } from 'react'
import { default as ReactModal, Props } from 'react-modal'
import { Wrapper } from '../common/Wrapper'
import { ActiveBackground, Confetti } from '@exercism/active-background'

export type ModalProps = Omit<Props, 'isOpen' | 'onRequestClose'> & {
  className: string
  open: boolean
  onClose: () => void
  cover?: boolean
  celebratory?: boolean
}

export const Modal = ({
  open,
  onClose,
  className,
  cover = false,
  celebratory = false,
  children,
  ...props
}: React.PropsWithChildren<ModalProps>): JSX.Element => {
  useLayoutEffect(() => {
    // Required for accessibility: http://reactcommunity.org/react-modal/accessibility/#app-element
    ReactModal.setAppElement(document.querySelector('body') as HTMLElement)
  })

  const overlayClassNames = ['c-modal', className, cover ? '--cover' : '']

  const reactModalProps = {
    ...props,
    className: '--modal-content',
    overlayClassName: overlayClassNames.join(' '),
  }

  return (
    <ReactModal isOpen={open} onRequestClose={onClose} {...reactModalProps}>
      <Wrapper
        condition={celebratory}
        wrapper={(children) => (
          <ActiveBackground Pattern={Confetti}>{children}</ActiveBackground>
        )}
      >
        {children}
      </Wrapper>
    </ReactModal>
  )
}
