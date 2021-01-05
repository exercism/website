import React from 'react'

export type AccordionContext = {
  id: string
  open: boolean
  onClick: (id: string) => void
}

const Context = React.createContext<AccordionContext>({
  id: '',
  open: false,
  onClick: (id: string) => {},
})

export const Accordion = ({
  id,
  open,
  onClick,
  children,
}: {
  id: string
  open: boolean
  onClick: (id: string) => void
  children?: React.ReactNode
}): JSX.Element => {
  return (
    <Context.Provider value={{ open, id, onClick }}>
      {children}
    </Context.Provider>
  )
}

const AccordionHeader = ({
  children,
}: {
  children?: React.ReactNode
}): JSX.Element => {
  const { open, id, onClick } = React.useContext(Context)

  return (
    <button
      type="button"
      onClick={() => onClick(id)}
      aria-expanded={open}
      aria-controls={`accordion-panel-${id}`}
      id={`accordion-header-${id}`}
    >
      {children}
    </button>
  )
}
AccordionHeader.displayName = 'AccordionHeader'
Accordion.Header = AccordionHeader

const AccordionPanel = ({ children }: { children: React.ReactNode }) => {
  const { open, id } = React.useContext(Context)

  return (
    <div
      id={`accordion-panel-${id}`}
      aria-labelledby={`accordion-panel-${id}`}
      hidden={!open}
    >
      {children}
    </div>
  )
}

AccordionPanel.displayName = 'AccordionPanel'
Accordion.Panel = AccordionPanel
