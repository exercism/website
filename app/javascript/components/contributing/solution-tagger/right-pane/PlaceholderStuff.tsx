import React from 'react'
import AutomationRules from './AutomationRules'
import Considerations from './Considerations'

export function PlaceholderStuff(): JSX.Element {
  return (
    <div className="flex flex-col mb-64">
      <Considerations />
      <AutomationRules />
    </div>
  )
}
