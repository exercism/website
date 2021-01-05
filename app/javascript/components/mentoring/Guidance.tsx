import React, { useState, useCallback } from 'react'
import { Accordion } from '../common/Accordion'

export const Guidance = (): JSX.Element => {
  const [accordionState, setAccordionState] = useState([
    {
      id: 'solution',
      isOpen: true,
    },
    {
      id: 'notes',
      isOpen: false,
    },
    {
      id: 'feedback',
      isOpen: false,
    },
  ])

  const handleClick = useCallback(
    (id: string) => {
      setAccordionState(
        accordionState.map((state) => {
          return {
            id: state.id,
            isOpen: id === state.id,
          }
        })
      )
    },
    [accordionState]
  )

  const isOpen = useCallback(
    (id: string) => {
      const state = accordionState.find((state) => state.id === id)

      if (!state) {
        throw new Error('Accordion id not found')
      }

      return state.isOpen
    },
    [accordionState]
  )

  return (
    <div>
      <Accordion id="solution" open={isOpen('solution')} onClick={handleClick}>
        <Accordion.Header>How you solved the exercise</Accordion.Header>
        <Accordion.Panel>
          <p>Solution here</p>
        </Accordion.Panel>
      </Accordion>
      <Accordion id="notes" open={isOpen('notes')} onClick={handleClick}>
        <Accordion.Header>Mentor notes</Accordion.Header>
        <Accordion.Panel>
          <p>Notes here</p>
        </Accordion.Panel>
      </Accordion>
      <Accordion id="feedback" open={isOpen('feedback')} onClick={handleClick}>
        <Accordion.Header>Automated feedback</Accordion.Header>
        <Accordion.Panel>
          <p>Feedback here</p>
        </Accordion.Panel>
      </Accordion>
    </div>
  )
}
