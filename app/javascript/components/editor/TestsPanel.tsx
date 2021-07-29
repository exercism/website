import React from 'react'
import { Tab } from '../common/Tab'
import { TabsContext } from '../Editor'
import { useHighlighting } from '../../utils/highlight'

export const TestsPanel = ({
  tests,
  language,
}: {
  tests: string
  language: string
}): JSX.Element => {
  const ref = useHighlighting<HTMLPreElement>()

  return (
    <Tab.Panel id="tests" context={TabsContext} className="tests c-code-pane">
      <pre ref={ref}>
        <code
          className={language}
          data-highlight-line-numbers={true}
          data-highlight-line-number-start={1}
          dangerouslySetInnerHTML={{ __html: tests }}
        />
      </pre>
    </Tab.Panel>
  )
}
