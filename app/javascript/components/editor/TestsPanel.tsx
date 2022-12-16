import React, { useContext, useEffect, useRef, useState } from 'react'
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

  const [tree, setTree] = useState<{ [key: string]: HTMLPreElement }>({})
  const [reusing, setReusing] = useState<boolean>(false)

  useEffect(() => {
    if (!testRef.current || !memoTestRef.current) {
      return
    }

    if (!(testTab.filename in tree)) {
      setReusing(false)
      highlightAll(testRef.current)
      setTree((t) => ({ ...t, [testTab.filename]: testRef.current! }))
    } else {
      setReusing(true)
      while (memoTestRef.current.firstChild) {
        memoTestRef.current.removeChild(memoTestRef.current.firstChild)
      }
      memoTestRef.current.appendChild(tree[testTab.filename])
    }
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
