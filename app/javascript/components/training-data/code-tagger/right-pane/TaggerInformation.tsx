import React from 'react'
import AutomationRules from './AutomationRules'
import Considerations from './Considerations'

export function TaggerInformation(): JSX.Element {
  return (
    <div className="flex flex-col mb-20">
      <Considerations />
      <AutomationRules />
    </div>
  )
}
