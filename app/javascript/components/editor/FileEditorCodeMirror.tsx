import React, { useCallback, useRef, useState, useEffect } from 'react'
import { Keybindings, WrapSetting, Themes } from './types'
import { File } from '../types'

import { CodeMirror, Handler } from '../misc/CodeMirror'

import { EditorConfig } from '../Editor'

export type FileEditorHandle = {
  getFiles: () => File[]
  setFiles: (files: File[]) => void
  openPalette: () => void
}

export function FileEditorCodeMirror({
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
  theme: Themes
  keybindings: Keybindings
  files: File[]
  wrap: WrapSetting
  config: EditorConfig
}): JSX.Element {
  const [tab, setTab] = useState(0)
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
          <CodeMirror
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
            // options={{
            //   keyMap: keybindings,
            // }}
          />
        </div>
      ))}
    </div>
  )
}
