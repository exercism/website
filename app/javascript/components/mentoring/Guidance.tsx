import React, { useState, useCallback } from 'react'
import { Accordion } from '../common/Accordion'

export const Guidance = (): JSX.Element => {
  const [accordionState, setAccordionState] = useState([
    {
      index: 'solution',
      isOpen: true,
    },
    {
      index: 'notes',
      isOpen: false,
    },
    {
      index: 'feedback',
      isOpen: false,
    },
  ])

  const handleClick = useCallback(
    (index: string) => {
      setAccordionState(
        accordionState.map((state) => {
          return {
            index: state.index,
            isOpen: index === state.index,
          }
        })
      )
    },
    [accordionState]
  )

  const isOpen = useCallback(
    (index: string) => {
      const state = accordionState.find((state) => state.index === index)

      if (!state) {
        throw new Error('Accordion index not found')
      }

      return state.isOpen
    },
    [accordionState]
  )

  return (
    <div>
      <Accordion
        index="solution"
        open={isOpen('solution')}
        onClick={handleClick}
      >
        <Accordion.Header>How you solved the exercise</Accordion.Header>
        <Accordion.Panel>
          <p>Solution here</p>
        </Accordion.Panel>
      </Accordion>
      <Accordion index="notes" open={isOpen('notes')} onClick={handleClick}>
        <Accordion.Header>Mentor notes</Accordion.Header>
        <Accordion.Panel>
          <p>Notes here</p>
        </Accordion.Panel>
      </Accordion>
      <Accordion
        index="feedback"
        open={isOpen('feedback')}
        onClick={handleClick}
      >
        <Accordion.Header>Automated feedback</Accordion.Header>
        <Accordion.Panel>
          <p>Feedback here</p>
        </Accordion.Panel>
      </Accordion>
    </div>
  )
}
