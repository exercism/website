import React, { useContext } from 'react'
import ReactDOM from 'react-dom'
import { usePanel } from '../../hooks/use-panel'
import { GraphicalIcon } from './GraphicalIcon'

const ComboButtonContext = React.createContext({
  open: false,
  panelAttributes: {},
})

export const ComboButton = ({
  className = '',
  children,
}: React.PropsWithChildren<{ className?: string }>): JSX.Element => {
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

  const classNames = ['c-combo-button', className]

  return (
    <ComboButtonContext.Provider
      value={{ open: open, panelAttributes: panelAttributes }}
    >
      <div className={classNames.join(' ')}>
        {children}
        <button
          onClick={() => setOpen(!open)}
          {...buttonAttributes}
          className="--dropdown-segment"
        >
          <GraphicalIcon icon="chevron-down" />
        </button>
      </div>
    </ComboButtonContext.Provider>
  )
}

ComboButton.PrimarySegment = ({ children }: React.PropsWithChildren<{}>) => {
  if (!children || !React.isValidElement(children)) {
    return null
  }

  return (
    <React.Fragment>
      {React.cloneElement(children, { className: '--primary-segment' })}
    </React.Fragment>
  )
}

ComboButton.DropdownSegment = ({ children }: React.PropsWithChildren<{}>) => {
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
