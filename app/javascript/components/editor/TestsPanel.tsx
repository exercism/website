import React from 'react'
import { Tab } from '../common/Tab'
import { TabsContext } from '../Editor'
import { useHighlighting } from '../../utils/highlight'
import { TestFile } from '../types'

export const TestsPanel = ({
  testFiles,
  highlightjsLanguage,
}: {
  testFiles: readonly TestFile[]
  highlightjsLanguage: string
}): JSX.Element => {
  const ref = useHighlighting<HTMLDivElement>()

  return (
    <Tab.Panel
      id="tests"
      context={TabsContext}
      className="tests c-code-pane"
      ref={ref}
    >
      {testFiles.map((testFile) => {
        return (
          <pre key={testFile.filename}>
            <code
              className={highlightjsLanguage}
              data-highlight-line-numbers={true}
              data-highlight-line-number-start={1}
            >
              {testFile.content}
            </code>
          </pre>
        )
      })}
    </Tab.Panel>
  )
}
