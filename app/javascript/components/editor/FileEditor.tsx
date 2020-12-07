import React, { useEffect, useCallback, useMemo, useRef, useState } from 'react'
import MonacoEditor from 'react-monaco-editor'
import * as monacoEditor from 'monaco-editor/esm/vs/editor/editor.api'
import { listen, MessageConnection } from 'vscode-ws-jsonrpc'
import {
  MonacoLanguageClient,
  CloseAction,
  ErrorAction,
  MonacoServices,
  createConnection,
  MonacoModelIdentifier,
} from 'monaco-languageclient'
import normalizeUrl from 'normalize-url'
import ReconnectingWebsocket from 'reconnecting-websocket'
import { v4 as uuidv4 } from 'uuid'
import { initVimMode, VimMode } from 'monaco-vim'
import { EmacsExtension } from 'monaco-emacs'
import { Keybindings, File, WrapSetting } from './types'

type FileRef = {
  filename: string
  model: monacoEditor.editor.ITextModel
  state: monacoEditor.editor.ICodeEditorViewState | null
}

export type FileEditorHandle = {
  getFiles: () => File[]
}

const SAVE_INTERVAL = 500

export function FileEditor({
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
  // const languageServerUrl: string = useMemo(() => {
  //   const languageServerHost = document.querySelector<HTMLMetaElement>(
  //     'meta[name="language-server-url"]'
  //   )?.content

  //   if (!languageServerHost) {
  //     throw 'Language server host not found'
  //   }

  //   return normalizeUrl(`${languageServerHost}/${language}/${uuidv4()}`)
  // }, [document, language, uuidv4])

  // useEffect(() => {
  //   const webSocket = new ReconnectingWebsocket(languageServerUrl, [], {
  //     maxReconnectionDelay: 10000,
  //     minReconnectionDelay: 1000,
  //     reconnectionDelayGrowFactor: 1.3,
  //     connectionTimeout: 10000,
  //     maxRetries: Infinity,
  //     debug: false,
  //   })

  //   listen({
  //     webSocket,
  //     onConnection: (connection) => {
  //       const languageClient = new MonacoLanguageClient({
  //         name: 'Language Client',
  //         clientOptions: {
  //           documentSelector: [language],
  //           errorHandler: {
  //             error: () => ErrorAction.Continue,
  //             closed: () => CloseAction.DoNotRestart,
  //           },
  //         },
  //         connectionProvider: {
  //           get: (errorHandler, closeHandler) => {
  //             return Promise.resolve(
  //               createConnection(connection, errorHandler, closeHandler)
  //             )
  //           },
  //         },
  //       })
  //       const disposable = languageClient.start()
  //       connection.onClose(() => disposable.dispose())
  //     },
  //   })

  //   return () => {
  //     webSocket.close()
  //   }
  // }, [languageServerUrl])

  const options: monacoEditor.editor.IStandaloneEditorConstructionOptions = {
    minimap: { enabled: false },
    wordWrap: wrap,
    glyphMargin: true,
    lightbulb: { enabled: true },
    automaticLayout: true,
    model: null,
  }
  const [tab, setTab] = useState(0)
  const filesRef = useRef<FileRef[]>(
    files.map((file) => ({
      filename: file.filename,
      model: monacoEditor.editor.createModel(file.content, language),
      state: null,
    }))
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

    editorDidMount({
      getFiles: () =>
        filesRef.current?.map((fileRef: FileRef) => {
          return {
            filename: fileRef.filename,
            content: fileRef.model.getValue(),
          }
        }),
    })
  }

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

  return (
    <div className="c-file-editor">
      <div className="tabs">
        {files.map((file, index) => (
          <button
            key={file.filename}
            type="button"
            onClick={() => switchTab(index)}
          >
            {file.filename}
          </button>
        ))}
      </div>
      <MonacoEditor
        language={language}
        editorDidMount={handleEditorDidMount}
        options={options}
        theme={theme}
      />
      <div ref={statusBarRef}></div>
    </div>
  )
}
