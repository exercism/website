import React from 'react'
import { Accordion } from './Accordion'
import { GraphicalIcon } from './GraphicalIcon'

export default function AccordionHeader({
  isOpen,
  title,
}: {
  isOpen: boolean
  title: string
}): JSX.Element {
  return (
    <Accordion.Header>
      {isOpen ? (
        <GraphicalIcon icon="minus-circle" />
      ) : (
        <GraphicalIcon icon="plus-circle" />
      )}
      <div className="--title">{title}</div>
    </Accordion.Header>
  )
}
