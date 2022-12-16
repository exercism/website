import React, { useContext, useLayoutEffect, useRef, useState } from 'react'
import { highlightAll } from '@/utils'
import { Tab } from '@/components/common/Tab'
import { TestContentContext, TestTabContext } from './TestContentWrapper'

type TestsPanelProps = {
  highlightjsLanguage: string
}
export const TestsPanel = ({
  highlightjsLanguage,
}: TestsPanelProps): JSX.Element => {
  const { testTab, tabContext } = useContext(TestContentContext)

  const testRef = useRef<HTMLPreElement>(null)
  const memoTestRef = useRef<HTMLDivElement>(null)

  const [treeMap, setTreeMap] = useState<{ [key: string]: HTMLPreElement }>({})
  const [reusing, setReusing] = useState<boolean>(false)

  useLayoutEffect(() => {
    if (!testRef.current || !memoTestRef.current) {
      return
    }

    if (!(testTab.filename in treeMap)) {
      setReusing(false)
      highlightAll(testRef.current)
      // eslint-disable-next-line @typescript-eslint/no-non-null-assertion
      setTreeMap((t) => ({ ...t, [testTab.filename]: testRef.current! }))
    } else {
      setReusing(true)
      while (memoTestRef.current.firstChild) {
        memoTestRef.current.removeChild(memoTestRef.current.firstChild)
      }
      memoTestRef.current.appendChild(treeMap[testTab.filename])
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [testTab])

  return (
    <Tab.Panel id="tests" context={tabContext}>
      <Tab.Panel
        id={testTab.filename}
        context={TestTabContext}
        className="tests c-code-pane"
      >
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
        <div className={!reusing ? 'hidden' : ''} ref={memoTestRef}></div>
      </Tab.Panel>
    </Tab.Panel>
  )
}
