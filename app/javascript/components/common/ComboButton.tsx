import React, { useContext } from 'react'
import ReactDOM from 'react-dom'
import { usePanel } from '../../hooks/use-panel'
import { GraphicalIcon } from './GraphicalIcon'

const ComboButtonContext = React.createContext({
  open: false,
  setPanelElement: (
    value: React.SetStateAction<HTMLDivElement | null>
  ): void => {},
  styles: {},
  attributes: {},
})

export const ComboButton = ({
  className,
  children,
}: React.PropsWithChildren<{ className: string }>): JSX.Element => {
  const {
    open,
    setOpen,
    setButtonElement,
    setPanelElement,
    styles,
    attributes,
  } = usePanel({
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
      value={{
        setPanelElement: setPanelElement,
        open: open,
        styles: styles,
        attributes: attributes,
      }}
    >
      <div className={classNames.join(' ')}>
        {children}
        <div className="--dropdown-segment">
          <button
            onClick={() => {
              setOpen(!open)
            }}
            ref={setButtonElement}
          >
            <GraphicalIcon icon="chevron-down" />
          </button>
        </div>
      </div>
    </ComboButtonContext.Provider>
  )
}

ComboButton.EditorSegment = ({ children }: React.PropsWithChildren<{}>) => {
  return <div className="--editor-segment">{children}</div>
}

ComboButton.DropdownSegment = ({ children }: React.PropsWithChildren<{}>) => {
  const { setPanelElement, open, styles, attributes } = useContext(
    ComboButtonContext
  )
  return (
    <React.Fragment>
      <Panel
        setPanelElement={setPanelElement}
        open={open}
        styles={styles}
        attributes={attributes}
      >
        {children}
      </Panel>
    </React.Fragment>
  )
}

type PanelProps = {
  open: boolean
  styles: { [key: string]: React.CSSProperties }
  attributes: {
    [key: string]: {
      [key: string]: string
    }
  }
  setPanelElement: React.Dispatch<React.SetStateAction<HTMLDivElement | null>>
}

const Panel = ({
  open,
  styles,
  setPanelElement,
  attributes,
  children,
}: React.PropsWithChildren<PanelProps>) => {
  const portalContainer = document.getElementById('portal-container')

  if (!portalContainer) {
    throw new Error('No portal container found')
  }

  return ReactDOM.createPortal(
    <div ref={setPanelElement} style={styles.popper} {...attributes.popper}>
      {open ? children : null}
    </div>,
    portalContainer
  )
}
