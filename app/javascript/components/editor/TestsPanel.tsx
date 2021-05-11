import React from 'react'
import { Tab } from '../common/Tab'
import { TabsContext } from '../Editor'

export const TestsPanel = ({
  tests,
  language,
}: {
  tests: string
  language: string
}) => (
  <Tab.Panel id="tests" context={TabsContext} className="tests c-code-pane">
    <pre>
      <code
        className={language}
        data-highlight-line-numbers={true}
        data-highlight-line-number-start={1}
        dangerouslySetInnerHTML={{ __html: tests }}
      />
    </pre>
  </Tab.Panel>
)
