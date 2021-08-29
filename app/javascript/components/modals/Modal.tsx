import React from 'react'
import { default as ReactModal, Props } from 'react-modal'
import { Icon } from '../common'
import { Wrapper } from '../common/Wrapper'
import { ActiveBackground, Confetti } from '@exercism/active-background'

type Theme = 'light' | 'dark'
export type ModalProps = Omit<Props, 'isOpen' | 'onRequestClose'> & {
  className: string
  closeButton?: boolean
  open: boolean
  onClose: () => void
  cover?: boolean
  celebratory?: boolean
  theme?: Theme
}

export const Modal = ({
  open,
  onClose,
  className,
  closeButton = false,
  cover = false,
  celebratory = false,
  theme = 'light',
  children,
  ...props
}: React.PropsWithChildren<ModalProps>): JSX.Element => {
  const overlayClassNames = [
    'c-modal',
    `theme-${theme}`,
    className,
    cover ? '--cover' : '',
  ]

  const overlayElement = (props: any, contentElement: any) => (
    <div {...props}>
      <Wrapper
        condition={celebratory}
        wrapper={(children) => (
          <ActiveBackground
            Pattern={Confetti}
            patternOptions={{
              colorPairs: [
                ['#df0049', '#660671'],
                ['#00e857', '#005291'],
                ['#2bebbc', '#05798a'],
                ['#ffd200', '#b06c00'],
              ],
              confettiPaperCount: 100,
              confettiRibbonCount: 40,
              speed: 30,
            }}
          >
            {children}
          </ActiveBackground>
        )}
      >
        {contentElement}
      </Wrapper>
    </div>
  )

  return (
    <ReactModal
      ariaHideApp={process.env.NODE_ENV !== 'test'}
      isOpen={open}
      onRequestClose={onClose}
      overlayClassName={overlayClassNames.join(' ')}
      className="--modal-container"
      appElement={document.querySelector('body') as HTMLElement}
      overlayElement={overlayElement}
      {...props}
    >
      {closeButton ? (
        <button type="button" onClick={onClose} className="--close-button">
          <Icon icon="cross" alt="Close modal" />
        </button>
      ) : null}
      <div className="--modal-content">{children}</div>
    </ReactModal>
  )
}
