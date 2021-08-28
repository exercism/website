import React, { useContext, forwardRef } from 'react'
import ReactDOM from 'react-dom'
import { usePanel } from '../../hooks/use-panel'
import { Icon } from './Icon'

const ComboButtonContext = React.createContext({
  open: false,
  panelAttributes: {},
})

type Props = React.PropsWithChildren<{ className?: string; enabled?: boolean }>

export const ComboButton = forwardRef<HTMLDivElement, Props>(
  ({ className = '', children, enabled = true }, ref) => {
    const { open, setOpen, buttonAttributes, panelAttributes } = usePanel({
      placement: 'bottom-end',
      modifiers: [
        {
          name: 'offset',
          options: {
            offset: [0, 14],
          },
        },
      ],
    })

    const classNames = [
      'c-combo-button',
      enabled ? '' : '--disabled',
      className,
    ]

    return (
      <ComboButtonContext.Provider
        value={{ open: open, panelAttributes: panelAttributes }}
      >
        <div className={classNames.join(' ')} ref={ref}>
          {children}
          <button
            onClick={() => setOpen(!open)}
            {...buttonAttributes}
            className="--dropdown-segment"
            disabled={!enabled}
          >
            <Icon icon="chevron-down" alt="Open dropdown" />
          </button>
        </div>
      </ComboButtonContext.Provider>
    )
  }
)

export const PrimarySegment = ({ children }: React.PropsWithChildren<{}>) => {
  if (!children || !React.isValidElement(children)) {
    return null
  }

  return (
    <React.Fragment>
      {React.cloneElement(children, { className: '--primary-segment' })}
    </React.Fragment>
  )
}

export const DropdownSegment = ({ children }: React.PropsWithChildren<{}>) => {
  const { open, panelAttributes } = useContext(ComboButtonContext)
  return (
    <React.Fragment>
      <Panel open={open} panelAttributes={panelAttributes}>
        {children}
      </Panel>
    </React.Fragment>
  )
}

type PanelProps = {
  open: boolean
  panelAttributes: {
    [key: string]: {
      [key: string]: string
    }
  }
}

const Panel = ({
  open,
  panelAttributes,
  children,
}: React.PropsWithChildren<PanelProps>) => {
  const portalContainer = document.getElementById('portal-container')

  if (!portalContainer || !open) {
    return null
  }

  return ReactDOM.createPortal(
    <div {...panelAttributes}>{children}</div>,
    portalContainer
  )
}
