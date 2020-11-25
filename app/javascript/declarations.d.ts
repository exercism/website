declare module 'reconnecting-websocket' {
  interface ReconnectingWebsocket extends WebSocket {
    [key: string]: any
    new (
      url: string | (() => string),
      protocols?: string | Array<string>,
      options?: {
        maxReconnectionDelay?: number
        minReconnectionDelay?: number
        reconnectionDelayGrowFactor?: number
        connectionTimeout?: number
        maxRetries?: number
        debug?: boolean
      }
    ): ReconnectingWebsocket

    close(
      code?: number,
      reason?: string,
      options?: {
        keepClosed?: boolean
        fastClosed?: boolean
        delay?: number
      }
    ): void
  }

  const ReconnectingWebsocket: ReconnectingWebsocket
  export = ReconnectingWebsocket
}

declare module 'monaco-vim' {
  import * as monacoEditor from 'monaco-editor/esm/vs/editor/editor.api'

  function initVimMode(
    editor: monacoEditor.editor.IStandaloneCodeEditor,
    statusBarNode: HTMLElement,
    StatusBarClass?: any,
    sanitizer?: any
  ): VimMode

  type VimMode = {
    dispose: () => void
  }
}
