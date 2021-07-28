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
  const ref = useHighlighting<HTMLDivElement>()

  return (
    <Tab.Panel id="tests" context={TabsContext} className="tests c-code-pane">
      <div ref={ref}>
        <pre>
          <code
            className={language}
            data-highlight-line-numbers={true}
            data-highlight-line-number-start={1}
            dangerouslySetInnerHTML={{ __html: tests }}
          />
        </pre>
      </div>
    </Tab.Panel>
  )
}
