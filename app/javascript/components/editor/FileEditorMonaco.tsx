import React, { useEffect, useCallback, useRef, useState } from 'react'
import MonacoEditor from 'react-monaco-editor'
import { MonacoServices } from 'monaco-languageclient'
import * as monacoEditor from 'monaco-editor/esm/vs/editor/editor.api'
import { initVimMode, VimMode } from 'monaco-vim'
import { EmacsExtension } from 'monaco-emacs'
import { Keybindings, WrapSetting } from './types'
import { File } from '../types'
import { setupThemes } from './file-editor/themes'

type FileRef = {
  filename: string
  model: monacoEditor.editor.ITextModel
  state: monacoEditor.editor.ICodeEditorViewState | null
}

export type FileEditorHandle = {
  getFiles: () => File[]
  setFiles: (files: File[]) => void
  openPalette: () => void
}

export function FileEditorMonaco({
  language,
  editorDidMount,
  onRunTests,
  onSubmit,
  theme,
  keybindings,
  files,
  wrap,
}: {
  editorDidMount: (editor: FileEditorHandle) => void
  language: string
  onRunTests: () => void
  onSubmit: () => void
  theme: string
  keybindings: Keybindings
  files: File[]
  wrap: WrapSetting
}): JSX.Element {
  const options: monacoEditor.editor.IStandaloneEditorConstructionOptions = {
    minimap: { enabled: false },
    wordWrap: wrap,
    glyphMargin: true,
    lightbulb: { enabled: true },
    automaticLayout: true,
    model: null,
    scrollBeyondLastLine: false,
    fontFamily: "'Source Code Pro', monospace",
    fontSize: 14,
    padding: { top: 20 },
    scrollbar: {
      useShadows: true,
      verticalHasArrows: false,
      horizontalHasArrows: false,
      vertical: 'auto',
      horizontal: 'auto',
      verticalScrollbarSize: 18,
      horizontalScrollbarSize: 18,
      arrowSize: 30,
    },
  }
  const [tab, setTab] = useState(0)
  const containerRef = useRef<HTMLDivElement>(null)
  const filesRef = useRef<FileRef[]>(
    files.map((file) => ({
      filename: file.filename,
      model: monacoEditor.editor.createModel(file.content, language),
      state: null,
    }))
  )
  const setFiles = useCallback((files: File[]) => {
    filesRef.current?.forEach((fileRef: FileRef) => {
      const file = files.find((file) => file.filename === fileRef.filename)

      if (!file) {
        return
      }

      fileRef.model.setValue(file.content)
    })
  }, [])
  const getFiles = useCallback(
    () =>
      filesRef.current?.map((fileRef: FileRef) => {
        return {
          filename: fileRef.filename,
          content: fileRef.model.getValue(),
        }
      }),
    [filesRef]
  )
  const statusBarRef = useRef<HTMLDivElement | null>(null)
  const editorRef = useRef<monacoEditor.editor.IStandaloneCodeEditor>()
  const keybindingRef = useRef<VimMode | EmacsExtension | null>()

  const handleEditorDidMount = (
    editor: monacoEditor.editor.IStandaloneCodeEditor
  ) => {
    editorRef.current = editor

    editor.addAction({
      id: 'runTests',
      label: 'Run tests',
      keybindings: [monacoEditor.KeyCode.F2],
      run: onRunTests,
    })

    editor.addAction({
      id: 'submit',
      label: 'Submit',
      keybindings: [monacoEditor.KeyCode.F3],
      run: onSubmit,
    })

    MonacoServices.install(editor)

    editor.setModel(filesRef.current[0].model)

    // Fix a custom code font rendering bug
    // See https://github.com/exercism/website/issues/742#issuecomment-816806513
    document.fonts.ready.then(() => monacoEditor.editor.remeasureFonts())

    editorDidMount({ getFiles, setFiles, openPalette })
  }

  const handleEditorWillMount = () => {
    setupThemes()
  }

  const openPalette = useCallback(() => {
    const editor = editorRef.current

    if (!editor) {
      return
    }

    editor.focus()
    editor.trigger(null, 'editor.action.quickCommand', {})
  }, [editorRef])

  useEffect(() => {
    if (!editorRef.current || !statusBarRef.current) {
      return
    }

    keybindingRef.current?.dispose()

    switch (keybindings) {
      case Keybindings.VIM:
        keybindingRef.current = initVimMode(
          editorRef.current,
          statusBarRef.current
        )

        break
      case Keybindings.EMACS:
        const extension = new EmacsExtension(editorRef.current)
        extension.start()

        keybindingRef.current = extension

        break
    }
  }, [editorRef, statusBarRef, keybindings, keybindingRef])

  const switchTab = useCallback(
    (index) => {
      if (!filesRef.current || !editorRef.current) {
        return
      }

      const switchingTo = filesRef.current[index]

      if (!switchingTo) {
        return
      }

      setTab(index)

      filesRef.current[tab].state = editorRef.current.saveViewState()
      editorRef.current.setModel(switchingTo.model)

      if (switchingTo.state !== null) {
        editorRef.current.restoreViewState(switchingTo.state)
      }

      editorRef.current.focus()
    },
    [tab]
  )

  const [{ width, height }, setSize] = useState<{
    width: string | number
    height: string | number
  }>({ width: '100%', height: '100%' })

  useEffect(() => {
    let lastAnimationFrame: number | undefined

    function determineNewSize() {
      lastAnimationFrame = undefined
      const { current } = containerRef
      if (!current) {
        return
      }

      setSize(current.getBoundingClientRect())
    }

    function onResize() {
      if (lastAnimationFrame) {
        return
      }

      lastAnimationFrame = requestAnimationFrame(determineNewSize)
    }

    window.addEventListener('resize', onResize)
    return () => {
      lastAnimationFrame !== undefined &&
        cancelAnimationFrame(lastAnimationFrame)
      window.removeEventListener('resize', onResize)
    }
  }, [containerRef])

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
      <MonacoEditor
        language={language}
        editorDidMount={handleEditorDidMount}
        editorWillMount={handleEditorWillMount}
        options={options}
        theme={theme}
        width={width}
        height={height}
      />
      <div ref={statusBarRef}></div>
    </div>
  )
}
