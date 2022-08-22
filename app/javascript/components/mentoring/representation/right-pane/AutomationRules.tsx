import React, { useCallback, useState } from 'react'
import { Accordion } from '../../../common/Accordion'
import AccordionHeader from '../../../common/AccordionHeader'
import AlertText from './AlertText'

export default function AutomationRules(): JSX.Element {
  const [accordionState, setAccordionState] = useState([
    {
      id: 'global',
      isOpen: false,
    },
    {
      id: 'track-specific',
      isOpen: false,
    },
    {
      id: 'exercise-specific',
      isOpen: false,
    },
  ])

  const handleClick = useCallback(
    (id: string) => {
      setAccordionState(
        accordionState.map((state) => {
          const isOpen = id === state.id && !state.isOpen
          return {
            id: state.id,
            isOpen: isOpen,
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
    <div className="px-24 shadow-xsZ1v2 mb-24">
      <AlertText text="Important rules when giving feedback" />
      <Accordion id="global" isOpen={isOpen('global')} onClick={handleClick}>
        <AccordionHeader isOpen={isOpen('global')} title="Global" />
        <Accordion.Panel>
          <div className="c-textual-content --small">
            <p>
              Try and guide the student towards this solution. It is the best
              place for them to reach at this point during the Track.
            </p>
          </div>
        </Accordion.Panel>
      </Accordion>
      <Accordion
        id="track-specific"
        isOpen={isOpen('track-specific')}
        onClick={handleClick}
      >
        <AccordionHeader
          isOpen={isOpen('track-specific')}
          title="Track-specific"
        />
        <Accordion.Panel>
          <div className="c-textual-content --small">
            <p>
              Try and guide the student towards this solution. It is the best
              place for them to reach at this point during the Track.
            </p>
          </div>
        </Accordion.Panel>
      </Accordion>
      <Accordion
        id="exercise-specific"
        isOpen={isOpen('exercise-specific')}
        onClick={handleClick}
      >
        <AccordionHeader
          isOpen={isOpen('exercise-specific')}
          title="Exercise-specific"
        />
        <Accordion.Panel>
          <div className="c-textual-content --small">
            <ul>
              <li>Do not give feedback on the order of imports</li>
              <li>Do not give feedback on the naming</li>
              <li>Do not give feedback on namespaces</li>
            </ul>
          </div>
        </Accordion.Panel>
      </Accordion>
    </div>
  )
}
