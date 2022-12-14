import React from 'react'
import { Tab } from '../common/Tab'
import { TabsContext } from '../Editor'
import { useHighlighting } from '../../utils/highlight'
import { TestFile } from '../types'

type TestsPanelProps = {
  testFiles: readonly TestFile[]
  highlightjsLanguage: string
}

export const TestsPanel = ({
  testFiles,
  highlightjsLanguage,
}: TestsPanelProps): JSX.Element => {
  const ref = useHighlighting<HTMLDivElement>()

  return (
    <Tab.Panel
      id="tests"
      context={TabsContext}
      className="tests c-code-pane"
      ref={ref}
    >
      {testFiles.map((testFile) => (
        <pre key={testFile.filename}>
          <code
            className={highlightjsLanguage}
            data-highlight-line-numbers={true}
            data-highlight-line-number-start={1}
          >
            {testFile.content}
          </code>
        </pre>
      ))}
    </Tab.Panel>
  )
}
