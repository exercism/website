import React from 'react'
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
  const overlayClassNames = ['c-modal', className, cover ? '--cover' : '']

  return (
    <ReactModal
      isOpen={open}
      onRequestClose={onClose}
      className={'--modal-content'}
      overlayClassName={overlayClassNames.join(' ')}
      appElement={document.querySelector('body') as HTMLElement}
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
            {contentElement}
          </Wrapper>
        </div>
      )}
      {...props}
    >
      {children}
    </ReactModal>
  )
}
