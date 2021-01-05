import React from 'react'

export type AccordionContext = {
  index: string
  open: boolean
  onClick: (index: string) => void
}

const Context = React.createContext<AccordionContext>({
  index: '',
  open: false,
  onClick: (index: string) => {},
})

export const Accordion = ({
  index,
  open,
  onClick,
  children,
}: {
  index: string
  open: boolean
  onClick: (index: string) => void
  children?: React.ReactNode
}): JSX.Element => {
  return (
    <Context.Provider value={{ open, index, onClick }}>
      {children}
    </Context.Provider>
  )
}

const AccordionHeader = ({
  children,
}: {
  children?: React.ReactNode
}): JSX.Element => {
  const { open, index, onClick } = React.useContext(Context)

  return (
    <button
      type="button"
      onClick={() => onClick(index)}
      aria-expanded={open}
      aria-controls={`accordion-panel-${index}`}
      id={`accordion-header-${index}`}
    >
      {children}
    </button>
  )
}
AccordionHeader.displayName = 'AccordionHeader'
Accordion.Header = AccordionHeader

const AccordionPanel = ({ children }: { children: React.ReactNode }) => {
  const { open, index } = React.useContext(Context)

  return (
    <div
      id={`accordion-panel-${index}`}
      aria-labelledby={`accordion-panel-${index}`}
      hidden={!open}
    >
      {children}
    </div>
  )
}

AccordionPanel.displayName = 'AccordionPanel'
Accordion.Panel = AccordionPanel
