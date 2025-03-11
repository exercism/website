import React, { forwardRef } from 'react'
export const ActualOutput = forwardRef<HTMLIFrameElement>((props, ref) => {
  return (
    <div className="p-12">
      <h3 className="mb-12 font-mono font-semibold">Your code: </h3>
      <div className="border-1 border-textColor1 rounded-12 w-[350px] h-[350px]">
        <iframe className="h-full w-full" ref={ref} src="" frameBorder="0" />
      </div>
    </div>
  )
})
