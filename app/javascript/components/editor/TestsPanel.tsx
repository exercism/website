import React, {
  createContext,
  useCallback,
  useContext,
  useEffect,
  useRef,
  useState,
} from 'react'
import { highlightAll } from '@/utils'
import { TestFile } from '@/components/types'
import { Tab, TabContext } from '@/components/common/Tab'
import { TabsContext } from '../Editor'

type TestsPanelProps = {
  testFiles: readonly TestFile[]
  highlightjsLanguage: string
}

export const TestsPanel = ({
  testFiles,
  highlightjsLanguage,
}: TestsPanelProps): JSX.Element => {
  const testRef = useRef<HTMLPreElement>(null)
  const [testTab, setTestTab] = useState<TestFile>(testFiles[0])

  const switchToTab = useCallback(
    (filename: string) => {
      const testFile = testFiles.find((f) => f.filename === filename)
      if (!testFile) {
        throw new Error('File not found')
      } else {
        setTestTab(testFile)
      }
    },
    [testFiles]
  )

  const TestContext = createContext<TabContext>({
    current: testFiles[0].filename,
    switchToTab,
  })

  const currentTab = useContext(TabsContext).current

  useEffect(() => {
    if (!testRef.current) {
      return
    }

    highlightAll(testRef.current)
  }, [testTab, TestContext])

  return (
    <TestContext.Provider
      value={{
        current: testTab.filename,
        switchToTab,
      }}
    >
      {testFiles.length > 1 && currentTab === 'tests' ? (
        <div className="test-tabs">
          {testFiles.map((file) => (
            <Tab context={TestContext} key={file.filename} id={file.filename}>
              {file.filename}
            </Tab>
          ))}
        </div>
      ) : null}
      <Tab.Panel id="tests" context={TabsContext}>
        <Tab.Panel
          id={testTab.filename}
          context={TestContext}
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
    </TestContext.Provider>
  )
}
