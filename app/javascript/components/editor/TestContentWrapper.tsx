import React, { useState, useContext, useCallback, createContext } from 'react'
import { TabContext, Tab } from '../common'
import { TestFile } from '../types'
import { TabsContext } from './FileEditorCodeMirror'

export const TestTabContext = createContext<TabContext>({
  current: '',
  switchToTab: () => null,
})

type TestContentContextType = {
  testTab: { filename: string; content: string }
  setTestTab: (file: TestFile) => void
  testFiles: readonly TestFile[]
  tabContext: React.Context<TabContext>
  testTabGroupCss?: string
}

export const TestContentContext = createContext<TestContentContextType>({
  testTab: { filename: '', content: '' },
  setTestTab: () => null,
  testFiles: [],
  tabContext: TabsContext,
  testTabGroupCss: '',
})

export function TestContentWrapper({
  testFiles,
  children,
  tabContext,
  testTabGroupCss,
}: {
  children: React.ReactNode
} & Pick<
  TestContentContextType,
  'testTabGroupCss' | 'tabContext' | 'testFiles'
>): JSX.Element {
  const [testTab, setTestTab] = useState<TestFile>(testFiles[0])

  return (
    <TestContentContext.Provider
      value={{ testTab, setTestTab, tabContext, testFiles, testTabGroupCss }}
    >
      <TabContextWrapper>{children}</TabContextWrapper>
    </TestContentContext.Provider>
  )
}

function TabContextWrapper({ children }: { children: React.ReactNode }) {
  const { testTab, setTestTab, tabContext, testFiles, testTabGroupCss } =
    useContext(TestContentContext)
  const { current: currentTab } = useContext(tabContext)

  const switchToTab = useCallback(
    (filename: string) => {
      const testFile = testFiles.find((f) => f.filename === filename)
      if (!testFile) {
        throw new Error('File not found')
      } else {
        setTestTab(testFile)
      }
    },
    [setTestTab, testFiles]
  )

  return (
    <TestTabContext.Provider
      value={{
        current: testTab.filename,
        switchToTab,
      }}
    >
      {testFiles.length > 1 && currentTab === 'tests' ? (
        <div className={`c-test-tabs ${testTabGroupCss}`}>
          {testFiles.map((file) => (
            <Tab
              context={TestTabContext}
              key={file.filename}
              id={file.filename}
            >
              {file.filename}
            </Tab>
          ))}
        </div>
      ) : null}
      <div className="border-t-1 border-borderColor7">{children}</div>
    </TestTabContext.Provider>
  )
}
