import React, { createContext, useState, useEffect } from 'react'
import { Tab, TabContext } from '../../common/Tab'
import { FileViewer } from './FileViewer'
import { File } from '../../types'

const TabsContext = createContext<TabContext>({
  current: '',
  switchToTab: () => {},
})

export const FilePanel = ({
  files,
  language,
}: {
  files: File[]
  language: string
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
        </div>
        <div className="c-code-pane">
          {files.map((file) => (
            <Tab.Panel
              key={file.digest}
              id={file.filename}
              context={TabsContext}
            >
              <FileViewer file={file} language={language} />
            </Tab.Panel>
          ))}
        </div>
      </div>
    </TabsContext.Provider>
  )
}
