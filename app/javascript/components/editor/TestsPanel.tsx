import React, { useContext, useEffect, useRef } from 'react'
import { highlightAll } from '@/utils'
import { Tab } from '@/components/common/Tab'
import { TestContentContext, TestTabContext } from './TestContentWrapper'

type TestsPanelProps = {
  highlightjsLanguage: string
}
export const TestsPanel = ({
  highlightjsLanguage,
}: TestsPanelProps): JSX.Element => {
  const testRef = useRef<HTMLPreElement>(null)

  const { testTab, tabContext } = useContext(TestContentContext)

  useEffect(() => {
    if (!testRef.current) {
      return
    }

    highlightAll(testRef.current)
  }, [testTab])

  return (
    <Tab.Panel id="tests" context={tabContext}>
      <Tab.Panel
        id={testTab.filename}
        context={TestTabContext}
        className="tests c-code-pane"
      >
        <pre ref={testRef} key={testTab.filename}>
          <code
            className={highlightjsLanguage}
            data-highlight-line-numbers={true}
            data-highlight-line-number-start={1}
          >
            {testTab.content}
          </code>
        </pre>
      </Tab.Panel>
    </Tab.Panel>
  )
}
