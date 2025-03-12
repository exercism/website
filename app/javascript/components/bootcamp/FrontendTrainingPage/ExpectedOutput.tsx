import React from 'react'
import { FrontendTrainingPageContext } from './FrontendTrainingPage'
export function ExpectedOutput() {
  const context = React.useContext(FrontendTrainingPageContext)

  if (!context) {
    return null
  }

  const { expectedIFrameRef } = context

  return (
    <div className="p-12">
      <h3 className="mb-12 font-mono font-semibold">Expected: </h3>
      <div className="border-1 border-textColor1 rounded-12 w-[350px] h-[350px]">
        <iframe
          className="h-[350px] w-[350px]"
          ref={expectedIFrameRef}
          src=""
          frameBorder="0"
        />
      </div>
    </div>
  )
}
