import React, {
  useCallback,
  useRef,
  useState,
  useEffect,
  createContext,
} from 'react'
import { Keybindings, WrapSetting, Themes, TabBehavior } from './types'
import { File } from '../types'

import { CodeMirror, Handler } from '../misc/CodeMirror'

import { EditorConfig } from '../Editor'

import { Tab, TabContext } from '../common/Tab'

export type FileEditorHandle = {
  getFiles: () => File[]
  setFiles: (files: File[]) => void
  openPalette: () => void
}

export const TabsContext = createContext<TabContext>({
  current: '',
  switchToTab: () => {},
})

export function FileEditorCodeMirror({
  language,
  editorDidMount,
  onRunTests,
  onSubmit,
  theme,
  keybindings,
  files,
  wrap,
  tabBehavior,
  config,
}: {
  editorDidMount: (editor: FileEditorHandle) => void
  language: string
  onRunTests: () => void
  onSubmit: () => void
  theme: Themes
  keybindings: Keybindings
  files: File[]
  wrap: WrapSetting
  tabBehavior: TabBehavior
  config: EditorConfig
}): JSX.Element {
  const [tab, setTab] = useState(files[0].filename)
  const containerRef = useRef<HTMLDivElement>(null)
  const editorRefs = useRef<Handler[]>([])

  const setFiles = useCallback((files: File[]) => {
    editorRefs.current?.forEach((editor, i) => {
      editor.setValue(files[i].content)
    })
  }, [])

  const getFiles = useCallback(() => {
    return editorRefs.current?.map((editor, i) => {
      return {
        filename: files[i].filename,
        content: editor.getValue() || '',
      }
    })
  }, [files])

  const openPalette = useCallback(() => null, [])

  useEffect(() => {
    editorDidMount({ getFiles, setFiles, openPalette })
  }, [editorDidMount, getFiles, openPalette, setFiles])

  console.log(files)

  return (
    <TabsContext.Provider
      value={{
        current: tab,
        switchToTab: (id: string) => setTab(id),
      }}
    >
      <div ref={containerRef} className="c-iteration-pane">
        <div className="tabs">
          {files.map((file) => (
            <Tab context={TabsContext} key={file.filename} id={file.filename}>
              {file.filename}
            </Tab>
          ))}
        </div>
        {files.map((file, index) => (
          <Tab.Panel
            context={TabsContext}
            key={file.filename}
            id={file.filename}
          >
            <CodeMirror
              key={file.filename}
              value={file.content}
              editorDidMount={(editor) => {
                const oldEditors = [...editorRefs.current]

                oldEditors[index] = editor

                editorRefs.current = oldEditors
              }}
              tabSize={config.tabSize}
              useSoftTabs={config.useSoftTabs}
              language={language}
              wrap={wrap !== 'off'}
              isTabCaptured={tabBehavior === 'captured'}
              theme={theme}
              commands={[
                {
                  key: 'F2',
                  run: () => {
                    onRunTests()
                    return true
                  },
                },
                {
                  key: 'F3',
                  run: () => {
                    onSubmit()
                    return true
                  },
                },
              ]}
            />
          </Tab.Panel>
        ))}
      </div>
    </TabsContext.Provider>
  )
}
