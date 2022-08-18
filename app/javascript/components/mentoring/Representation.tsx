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
        right={<RightPane />}
      />
    </div>
  )
}

function RightPane() {
  return (
    <div>
      <AutomationRules />
      <MentoringConversation />
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
    <div className="p-24 pt-16 shadow-xsZ1v2 mb-24">
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

function AlertText({ text }: { text: string }): JSX.Element {
  return (
    <div className="font-semibold text-16 text-alert flex flex-row items-center mb-[12px]">
      <GraphicalIcon
        className="w-[24px] h-[24px] mr-[16px] alert-filter"
        icon="alert-circle"
      />
      {text}
    </div>
  )
}

function MentoringConversation() {
  return (
    <div className="p-[24px] pt-[0px]">
      <h2 className="text-h4 mb-[10.5px]">How important is this?</h2>
      <RadioGroup />
    </div>
  )
}

function RadioGroup() {
  const RADIO_DATA = [
    {
      label: 'Essential',
      tooltip: {
        title: 'If you mark this as Essential',
        body: 'Student is prompted heavily to action this before proceeding. Essential enhancement.',
      },
    },
    {
      label: 'Recommended',
      tooltip: {
        title: 'If you mark this as Recommended',
        body: 'Student is prompted to action this before proceeding, but not considered essential. High-value enhancement.',
      },
    },
    {
      label: 'Optional',
      tooltip: {
        title: 'If you mark this as Optional',
        body: 'Student is not prompted to action this before proceeding, entirely a low-value enhancement.',
      },
    },
  ]

  return (
    <div>
      {RADIO_DATA.map((i) => (
        <RadioEssential key={i.label} label={i.label} />
      ))}
    </div>
  )
}

function RadioEssential({ label }: { label: string }) {
  return (
    <label className="c-radio-wrapper mb-[13px]">
      <input type="radio" />
      <div className="row text-radio-essential">
        <div className="c-radio mr-16" />
        <div className="mr-[8.5px]">{label}</div>
        <Icon
          className="w-[15px] h-[15px] textColor6-filter"
          icon="info-circle"
          alt="Info"
        />
      </div>
    </label>
  )
}
