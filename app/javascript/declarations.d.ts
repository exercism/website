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

interface Fonts {
  ready: Promise<void>
}

interface Document {
  fonts: Fonts
}

interface Window {
  turboLoaded: boolean
}

declare module 'nim-codemirror-mode' {
  import { StreamParser } from '@codemirror/stream-parser'
  export const nim: StreamParser<unknown>
}

declare module '@exercism/twine2-story-format/src/story' {
  export default class Story {
    constructor(params: any)
    start: (params: any) => any
  }
}

declare module 'highlightjs-sap-abap' {
  import { LanguageFn } from 'highlight.js'
  const setup: LanguageFn

  export default setup
}
