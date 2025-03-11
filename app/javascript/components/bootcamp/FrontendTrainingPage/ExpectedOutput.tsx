import React, { forwardRef, useEffect } from 'react'
import { updateIFrame } from './updateIFrame'
export const ExpectedOutput = forwardRef<HTMLIFrameElement>((props, ref) => {
  useEffect(() => {
    updateIFrame(ref, html, css)
  }, [ref])

  return (
    <div className="p-12">
      <h3 className="mb-12 font-mono font-semibold">Expected: </h3>
      <div className="border-1 border-textColor1 rounded-12 w-[350px] h-[350px]">
        <iframe className="h-full w-full" ref={ref} src="" frameBorder="0" />
      </div>
    </div>
  )
})

const html = `
<div class="asdf">Hello world!</div>
`

const css = `
.asdf {
  color: red;
  font-weight: bold;
  font-size: 24px;
}
  `
