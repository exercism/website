import React, { createContext, useState, useEffect } from 'react'
import { Tab, TabContext } from '../../common/Tab'
import { FileViewer } from './FileViewer'
import { File, TestFile } from '../../types'

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
}: {
  files: readonly File[]
  language: string
  indentSize: number
  instructions?: string
  testFiles?: readonly TestFile[]
}): JSX.Element | null => {
  const [tab, setTab] = useState<string>('')

  useEffect(() => {
    if (files.length === 0) {
      return
    }

    setTab(files[0].filename)
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
          {files.map((file) => (
            <Tab key={file.digest} id={file.filename} context={TabsContext}>
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
        <div className="c-code-pane">
          {files.map((file) => (
            <Tab.Panel
              key={file.digest}
              id={file.filename}
              context={TabsContext}
            >
              <FileViewer
                file={file}
                language={language}
                indentSize={indentSize}
              />
            </Tab.Panel>
          ))}
          {instructions ? (
            <Tab.Panel
              key="instructions"
              id="instructions"
              context={TabsContext}
            >
              <div
                className="p-16 c-textual-content --small"
                dangerouslySetInnerHTML={{ __html: instructions }}
              />
            </Tab.Panel>
          ) : null}
          {testFiles ? (
            <Tab.Panel key="tests" id="tests" context={TabsContext}>
              {testFiles.map((test) => {
                return (
                  <FileViewer
                    key={test.filename}
                    file={{
                      ...test,
                      type: 'exercise',
                      digest: '',
                    }}
                    language={language}
                    indentSize={indentSize}
                  />
                )
              })}
            </Tab.Panel>
          ) : null}
        </div>
      </div>
    </TabsContext.Provider>
  )
}
