import React from 'react'
import { Tab } from '../common/Tab'
import { TabsContext } from '../Editor'
import { useHighlighting } from '../../utils/highlight'

export const TestsPanel = ({
  tests,
  highlightjsLanguage,
}: {
  tests: string
  highlightjsLanguage: string
}): JSX.Element => {
  const ref = useHighlighting<HTMLPreElement>()

  return (
    <Tab.Panel id="tests" context={TabsContext} className="tests c-code-pane">
      <pre ref={ref}>
        <code
          className={highlightjsLanguage}
          data-highlight-line-numbers={true}
          data-highlight-line-number-start={1}
        >
          {tests}
        </code>
      </pre>
    </Tab.Panel>
  )
}
