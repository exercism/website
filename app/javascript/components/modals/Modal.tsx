import React from 'react'
import { Aria, default as ReactModal, Props } from 'react-modal'
import { Icon } from '../common/Icon'
import { Wrapper } from '../common/Wrapper'
import { ActiveBackground, Confetti } from '@exercism/active-background'

type Theme = 'light' | 'dark' | 'unset'
export type ModalProps = Omit<Props, 'isOpen' | 'onRequestClose'> & {
  className?: string
  closeButton?: boolean
  open: boolean
  onClose: () => void
  cover?: boolean
  celebratory?: boolean
  theme?: Theme
  aria?: Aria
  ReactModalClassName?: string
}

export function Modal({
  open,
  onClose,
  className,
  closeButton = false,
  cover = false,
  celebratory = false,
  theme = 'unset',
  children,
  aria,
  ReactModalClassName,
  ...props
}: React.PropsWithChildren<ModalProps>): JSX.Element {
  const overlayClassNames = [
    'c-modal',
    `theme-${theme}`,
    className,
    cover ? '--cover' : '',
  ]

  return (
    <ReactModal
      aria={{ modal: true, ...aria }}
      role="dialog"
      ariaHideApp={false}
      isOpen={open}
      onRequestClose={onClose}
      shouldCloseOnOverlayClick={!closeButton}
      className={`--modal-content ${ReactModalClassName}`}
      overlayClassName={overlayClassNames.join(' ')}
      overlayElement={(props, contentElement) => (
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
            <div className="--modal-container">
              {closeButton ? <CloseButton onClose={onClose} /> : null}
              {contentElement}
            </div>
          </Wrapper>
        </div>
      )}
      {...props}
    >
      {children}
    </ReactModal>
  )
}

export type CloseButtonProps = Pick<ModalProps, 'onClose'>

function CloseButton({ onClose }: CloseButtonProps) {
  return (
    <button type="button" onClick={onClose} className="--close-button">
      <Icon icon="cross" alt="Close modal" />
    </button>
  )
}

export default Modal
