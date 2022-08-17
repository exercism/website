import React, { useCallback, useState } from 'react'
import { GraphicalIcon, Icon, SplitPane } from '../common'
import { Accordion } from '../common/Accordion'

export function Representation(): JSX.Element {
  return (
    <div className="c-mentor-discussion">
      <SplitPane
        defaultLeftWidth="90%"
        leftMinWidth={550}
        rightMinWidth={625}
        id="mentoring-session"
        left={<div>left</div>}
        right={<AutomationRules />}
      />
    </div>
  )
}

const AccordionHeader = ({
  isOpen,
  title,
}: {
  isOpen: boolean
  title: string
}) => {
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

function AutomationRules() {
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
    <div className="px-24 py-16">
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
            <p>
              Try and guide the student towards this solution. It is the best
              place for them to reach at this point during the Track.
            </p>
          </div>
        </Accordion.Panel>
      </Accordion>
    </div>
  )
}

function AlertText({ text }: { text: string }): JSX.Element {
  return (
    <div className="font-semibold text-16 text-alert flex flex-row items-center">
      <GraphicalIcon
        className="w-[24px] h-[24px] mr-[16px] magnifier-filter"
        icon="alert-circle"
      />
      {text}
    </div>
  )
}
