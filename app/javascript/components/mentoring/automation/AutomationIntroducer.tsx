import React from 'react'
import Introducer from '@/components/common/Introducer'

export function AutomationIntroducer({
  hideEndpoint,
}: {
  hideEndpoint: string
}): JSX.Element {
  return (
    <Introducer
      endpoint={hideEndpoint}
      additionalClassNames="mb-24"
      icon="automation"
    >
      <h2>Initiate feedback automation…Beep boop bop…</h2>
      <p>
        Automation is a space that allows you to see common solutions to
        exercises and write feedback once for all students with that particular
        solution.
      </p>
    </Introducer>
  )
}
