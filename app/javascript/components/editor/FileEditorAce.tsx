import React, {
  createRef,
  useCallback,
  useRef,
  useState,
  useEffect,
} from 'react'
import { Keybindings, WrapSetting } from './types'
import { File } from '../types'

import AceEditor from 'react-ace'
import ReactAce from 'react-ace/lib/ace'
import { EditorConfig } from '../Editor'

export type FileEditorHandle = {
  getFiles: () => File[]
  setFiles: (files: File[]) => void
  openPalette: () => void
}

export function FileEditorAce({
  language,
  editorDidMount,
  onRunTests,
  onSubmit,
  theme,
  keybindings,
  files,
  wrap,
  config,
}: {
  editorDidMount: (editor: FileEditorHandle) => void
  language: string
  onRunTests: () => void
  onSubmit: () => void
  theme: string
  keybindings: Keybindings
  files: File[]
  wrap: WrapSetting
  config: EditorConfig
}): JSX.Element {
  const [tab, setTab] = useState(0)
  const containerRef = useRef<HTMLDivElement>(null)
  const editorRefs = useRef(files.map(() => createRef<ReactAce>()))

  const setFiles = useCallback((files: File[]) => {
    editorRefs.current?.forEach((editor, i) => {
      editor.current?.editor.setValue(files[i].content)
    })
  }, [])

  const getFiles = useCallback(() => {
    return editorRefs.current?.map((editor, i) => {
      return {
        filename: files[i].filename,
        content: editor.current?.editor.getValue() || '',
      }
    })
  }, [files])

  const openPalette = useCallback(() => null, [])

  useEffect(() => {
    editorDidMount({ getFiles, setFiles, openPalette })
  }, [editorDidMount, getFiles, openPalette, setFiles])

  useEffect(() => {
    editorRefs.current?.map((editor, i) => {
      setTimeout(() => editor.current?.editor.resize(), 1)
    })
  }, [editorDidMount])

  const switchTab = useCallback((index) => {
    setTab(index)
  }, [])

  return (
    <div ref={containerRef} className="c-iteration-pane">
      <div className="tabs">
        {files.map((file, index) => (
          <button
            key={file.filename}
            type="button"
            onClick={() => switchTab(index)}
            className="c-tab selected"
          >
            {file.filename}
          </button>
        ))}
      </div>
      {files.map((file, index) => (
        <div className="editor" key={file.filename} hidden={index !== tab}>
          <AceEditor
            name={file.filename}
            height="100%"
            width="100%"
            tabSize={config.tabSize}
            mode={language}
            theme={theme}
            editorProps={{ $blockScrolling: true }}
            keyboardHandler={keybindings}
            wrapEnabled={wrap !== 'off'}
            defaultValue={file.content}
            ref={editorRefs.current[index]}
            fontSize="15px"
            setOptions={{
              useSoftTabs: config.useSoftTabs,
              navigateWithinSoftTabs: config.useSoftTabs,
              fontFamily: "'Source Code Pro', monospace",
              showPrintMargin: false,
              fixedWidthGutter: true,
            }}
            commands={[
              {
                name: 'Run tests',
                bindKey: { win: 'F2', mac: 'F2' },
                exec: onRunTests,
              },
              {
                name: 'Submit',
                bindKey: { win: 'F3', mac: 'F3' },
                exec: onSubmit,
              },
            ]}
          />
        </div>
      ))}
    </div>
  )
}
