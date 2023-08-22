import React, { createContext, useState, useEffect } from 'react'
import { Tab, TabContext } from '../../common/Tab'
import { FileViewer } from './FileViewer'
import {
  TestContentWrapper,
  TestPanel,
  TestsPanel,
} from '@/components/editor/index'
import { File, TestFile } from '../../types'
import { CopyButton } from './iteration-view/iteration-header/CopyButton'

const TabsContext = createContext<TabContext>({
  current: '',
  switchToTab: () => null,
})

export const FilePanel = ({
  files,
  language,
  indentSize,
  instructions,
  testFiles,
  showCopyButton = false,
}: {
  files: readonly File[]
  language: string
  indentSize: number
  instructions?: string
  testFiles?: readonly TestFile[]
  showCopyButton?: boolean
}): JSX.Element | null => {
  const [tab, setTab] = useState<string>('')

  useEffect(() => {
    if (files.length === 0) {
      return
    }

    setTab(files[0].filename + 0)
  }, [files])

  if (files.length === 0) {
    return null
  }

  return (
    <TabsContext.Provider
      value={{
        current: tab,
        switchToTab: (filename: string) => setTab(filename),
      }}
    >
      <div className="c-iteration-pane">
        <div className="tabs" role="tablist">
          <div className="flex flex-grow relative">
            {files.map((file, idx) => (
              <Tab
                key={file.filename + idx}
                id={file.filename + idx}
                context={TabsContext}
              >
                {file.filename}
              </Tab>
            ))}

            {instructions ? (
              <Tab key="instructions" id="instructions" context={TabsContext}>
                Instructions
              </Tab>
            ) : null}

            {testFiles ? (
              <Tab key="tests" id="tests" context={TabsContext}>
                Tests
              </Tab>
            ) : null}
          </div>
          {files && showCopyButton && <CopyButton files={files} />}
        </div>

        <div className="c-code-pane">
          {files.map((file, idx) => (
            <Tab.Panel
              key={file.filename + idx}
              id={file.filename + idx}
              context={TabsContext}
            >
              <FileViewer
                file={file}
                language={language}
                indentSize={indentSize}
              />
            </Tab.Panel>
          ))}
        </div>
        {instructions ? (
          <Tab.Panel
            key="instructions"
            id="instructions"
            context={TabsContext}
            className="overflow-auto"
          >
            <div
              className="p-16 c-textual-content --small"
              dangerouslySetInnerHTML={{ __html: instructions }}
            />
          </Tab.Panel>
        ) : null}
        {testFiles ? (
          <TestsPanel context={TabsContext}>
            <TestContentWrapper testFiles={testFiles} tabContext={TabsContext}>
              <TestPanel highlightjsLanguage={language} />
            </TestContentWrapper>
          </TestsPanel>
        ) : null}
      </div>
    </TabsContext.Provider>
  )
}
