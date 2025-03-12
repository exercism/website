import { useCallback, useEffect, useRef } from 'react'
import toast from 'react-hot-toast'
import { updateIFrame } from './utils/updateIFrame'
import { getIframesMatchPercentage } from './utils/getIframesMatchPercentage'

// set up expected output and reference output
export function useSetupIFrames() {
  const actualIFrameRef = useRef<HTMLIFrameElement>(null)
  const expectedIFrameRef = useRef<HTMLIFrameElement>(null)
  const expectedReferenceIFrameRef = useRef<HTMLIFrameElement>(null)

  useEffect(() => {
    const { html, css } = accentDetection
    updateIFrame(expectedIFrameRef, html, css)
    updateIFrame(expectedReferenceIFrameRef, html, css)
  }, [])

  const handleCompare = useCallback(async () => {
    const percentage = await getIframesMatchPercentage(
      actualIFrameRef,
      expectedIFrameRef
    )
    if (percentage === 100) {
      toast.success(`MATCHING! ${percentage}%`)
    } else {
      toast.error(`NOT MATCHING! ${percentage}%`)
    }
  }, [])

  return {
    actualIFrameRef,
    expectedIFrameRef,
    expectedReferenceIFrameRef,
    handleCompare,
  }
}

// examples
const helloWorld = {
  html: `
  <div id="asdf">Hello world!</div>
  `,
  css: `
  #asdf {
    color: red;
    font-weight: bold;
    font-size: 24px;
  }
    `,
}

const accentDetection = {
  html: `
  <div>Építészeti kiállítás</div>
  `,
  css: `

  body{
  margin: 0;
  height: 350px;
  overflow: hidden;
  }
   div {
    color: #242325;
    background-color: #DC965A;
    font-family: "Trebuchet MS";
    font-weight: semi-bold;
    font-size: 24px;
    padding: 8px 4px;
    height: 100%;
    width: 100%;
    text-align: center;
  }
    `,
}
