import React from 'react'
import { Accordion } from '../common/Accordion'

export const Guidance = (): JSX.Element => {
  return (
    <div>
      <Accordion index="solution" open={true}>
        <Accordion.Header>How you solved the exercise</Accordion.Header>
        <Accordion.Panel>
          <p>Solution here</p>
        </Accordion.Panel>
      </Accordion>
      <Accordion index="notes" open={false}>
        <Accordion.Header>Mentor notes</Accordion.Header>
        <Accordion.Panel>
          <p>Notes here</p>
        </Accordion.Panel>
      </Accordion>
      <Accordion index="notes" open={false}>
        <Accordion.Header>Automated feedback</Accordion.Header>
        <Accordion.Panel>
          <p>Feedback here</p>
        </Accordion.Panel>
      </Accordion>
    </div>
  )
}
