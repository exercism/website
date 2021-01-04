import React, { useState } from 'react'

export type AccordionContext = {
  index: string
  open: boolean
  setOpen: (open: boolean) => void
}

const Context = React.createContext<AccordionContext>({
  index: '',
  open: false,
  setOpen: () => {},
})

export const Accordion = ({
  index,
  open: initialOpen,
  children,
}: {
  index: string
  open: boolean
  children?: React.ReactNode
}): JSX.Element => {
  const [open, setOpen] = useState(initialOpen)

  return (
    <Context.Provider value={{ open, index, setOpen }}>
      {children}
    </Context.Provider>
  )
}

const AccordionHeader = ({
  children,
}: {
  children?: React.ReactNode
}): JSX.Element => {
  const { open, index, setOpen } = React.useContext(Context)

  return (
    <button
      type="button"
      onClick={() => setOpen(!open)}
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
