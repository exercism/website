import { useCallback, useEffect, useRef } from 'react'
import { getIframesMatchPercentage } from '../utils/getIframesMatchPercentage'
import { updateIFrame } from '../utils/updateIFrame'

// set up expected output and reference output
export function useSetupIFrames(
  config: CSSExercisePageConfig,
  code: CSSExercisePageCode
) {
  const actualIFrameRef = useRef<HTMLIFrameElement>(null)
  const expectedIFrameRef = useRef<HTMLIFrameElement>(null)
  const expectedReferenceIFrameRef = useRef<HTMLIFrameElement>(null)

  useEffect(() => {
    const { html, css } = config.expected
    updateIFrame(expectedIFrameRef, { html, css }, code)
    updateIFrame(expectedReferenceIFrameRef, { html, css }, code)
  }, [])

  // since curtainMode and diffMode is off by default, we don't render the iframe
  // this updates the newly added iframe's inner value if curtainMode or diffMode is changed

  const handleCompare = useCallback(async () => {
    const percentage = await getIframesMatchPercentage(
      actualIFrameRef,
      expectedIFrameRef
    )

    return percentage
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

const cssPattern = {
  html: '',
  css: `
body{
height: 350px;
width: 350px;
padding: 0;
margin: 0;
overflow: hidden;
background-color: #e5e5f7;
opacity: 0.8;
background-image:  linear-gradient(135deg, #444cf7 25%, transparent 25%), linear-gradient(225deg, #444cf7 25%, transparent 25%), linear-gradient(45deg, #444cf7 25%, transparent 25%), linear-gradient(315deg, #444cf7 25%, #e5e5f7 25%);
background-position: 10px 0, 10px 0, 0 0, 0 0;
background-size: 10px 10px;
background-repeat: repeat;
}
  `,
}

const boxExample = {
  js: undefined,
  html: `<div class='box'></div>`,
  css: `
body{
  height: 100vh;
  width: 100vw;
  margin: 0;
  background: #0ad;
  display: grid;
  place-items: center;
}

.box{
  background: #8ba;
  height: 50px;
  width: 50px;
}`,
}
