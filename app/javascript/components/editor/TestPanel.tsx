import React, { useContext, useLayoutEffect, useRef, useState } from 'react'
import { highlightAll } from '@/utils/highlight'
import { Tab } from '@/components/common/Tab'
import { TestContentContext, TestTabContext } from './TestContentWrapper'

type TestPanelProps = {
  highlightjsLanguage: string
}
export const TestPanel = ({
  highlightjsLanguage,
}: TestPanelProps): JSX.Element => {
  const { testTab } = useContext(TestContentContext)

  const testRef = useRef<HTMLPreElement>(null)
  const memoTestRef = useRef<HTMLDivElement>(null)

  const [treeMap, setTreeMap] = useState<{ [key: string]: HTMLPreElement }>({})
  const [reusing, setReusing] = useState<boolean>(false)

  // useLayoutEffect is necessary, because the highlighting must be completed _before_ render
  useLayoutEffect(() => {
    if (!testRef.current || !memoTestRef.current) {
      return
    }

    // The highlighter fn is a bit expensive to run, therefore this block makes sure it won't be run on the same file again
    // see https://github.com/exercism/website/pull/3320
    // Checks if the filename has already been transformed into a highlighted representation
    // if not, highlights it, and saves it in a hashMap
    if (!(testTab.filename in treeMap)) {
      setReusing(false)
      highlightAll(testRef.current)

      // disable linter - if we get here, testRef.current is guaranteed to be here, otherwise it would've returned early
      // eslint-disable-next-line @typescript-eslint/no-non-null-assertion
      setTreeMap((t) => ({ ...t, [testTab.filename]: testRef.current! }))
    } else {
      setReusing(true)

      // when testTab is updated, it removes the previously rendered dom element -  which comes from the treeMap hashmap
      while (memoTestRef.current.firstChild) {
        memoTestRef.current.removeChild(memoTestRef.current.firstChild)
      }

      // ...and appends another child element to our memoTestRef container
      memoTestRef.current.appendChild(treeMap[testTab.filename])
    }

    // we only want to rerun it if testTab changes
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [testTab])

  return (
    <Tab.Panel
      id={testTab.filename}
      context={TestTabContext}
      className="tests c-code-pane"
    >
      {/*
        this cannot be removed from the DOM, because if this pre tag doesn't exist,
        a new testFile is loaded for the first time (not from the hashmap), the highlighter useEffect won't run,
        because testRef.current will be missing, will exit early, won't render anything.

        this can be further optimized by comparing filenames and keys stored in the hashmap
        and ejecting this block if the two numbers/arrays are the same
        but is not necessary at this point
        */}
      <pre
        ref={testRef}
        className={reusing ? 'hidden' : ''}
        key={testTab.filename}
      >
        <code
          className={highlightjsLanguage}
          data-highlight-line-numbers={true}
          data-highlight-line-number-start={1}
        >
          {testTab.content}
        </code>
      </pre>
      {/* injecting cached DOM elements into this container */}
      <div className={reusing ? '' : 'hidden'} ref={memoTestRef}></div>
    </Tab.Panel>
  )
}
