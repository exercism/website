import { useCallback, useEffect, useRef } from 'react'

const SCRIPT_SRC =
  'https://challenges.cloudflare.com/turnstile/v0/api.js?render=explicit'

interface TurnstileRenderOptions {
  sitekey: string
  size?: 'normal' | 'compact' | 'flexible'
  execution?: 'render' | 'execute'
  appearance?: 'always' | 'execute' | 'interaction-only'
  theme?: 'light' | 'dark' | 'auto'
  callback?: (token: string) => void
  'error-callback'?: (code: string) => void
  'expired-callback'?: () => void
  'timeout-callback'?: () => void
  'before-interactive-callback'?: () => void
  'after-interactive-callback'?: () => void
}

interface TurnstileApi {
  render: (container: HTMLElement, options: TurnstileRenderOptions) => string
  execute: (widgetId: string) => void
  reset: (widgetId: string) => void
  remove: (widgetId: string) => void
}

declare global {
  interface Window {
    turnstile?: TurnstileApi
    __turnstileScriptPromise?: Promise<void>
  }
}

function loadTurnstileScript(): Promise<void> {
  if (window.turnstile) {
    return Promise.resolve()
  }
  if (window.__turnstileScriptPromise) {
    return window.__turnstileScriptPromise
  }
  window.__turnstileScriptPromise = new Promise((resolve, reject) => {
    const script = document.createElement('script')
    script.src = SCRIPT_SRC
    script.async = true
    script.defer = true
    script.onload = () => resolve()
    script.onerror = () => {
      // Clear the cached promise so a future attempt (remount, retry) re-tries
      // the network load instead of getting this rejection back forever.
      window.__turnstileScriptPromise = undefined
      reject(new Error('Failed to load Turnstile script'))
    }
    document.head.appendChild(script)
  })
  return window.__turnstileScriptPromise
}

export interface UseTurnstileResult {
  execute: () => Promise<string>
}

interface PendingResolver {
  resolve: (token: string) => void
  reject: (err: Error) => void
}

// Invisible-first Turnstile: renders an execute-mode widget in a hidden
// overlay that only appears if Cloudflare decides the user needs an
// interactive challenge. execute() resolves with a fresh captcha token.
export function useTurnstile(siteKey: string): UseTurnstileResult {
  const widgetIdRef = useRef<string | null>(null)
  const pendingRef = useRef<PendingResolver | null>(null)
  const readyRef = useRef<Promise<void> | null>(null)

  useEffect(() => {
    if (!siteKey) {
      readyRef.current = Promise.reject(
        new Error('Turnstile site key is not set')
      )
      return
    }

    let cancelled = false
    let localWidgetId: string | null = null
    // Turnstile renders its interactive challenge *inline* in the container.
    // To present it as a proper explained modal, we wrap the widget container
    // inside our own overlay+panel and toggle visibility via the
    // before-interactive-callback.
    const overlay = document.createElement('div')
    overlay.style.cssText = [
      'position: fixed',
      'inset: 0',
      'background: rgba(15, 23, 42, 0.95)',
      'display: none',
      'align-items: center',
      'justify-content: center',
      'z-index: 9999',
      'padding: 16px',
    ].join(';')

    const panel = document.createElement('div')
    panel.style.cssText = [
      'background: #fff',
      'border-radius: 12px',
      'padding: 32px 40px',
      'max-width: 500px',
      'width: 100%',
      'box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.4)',
      'font-family: inherit',
      'text-align: center',
      'display: flex',
      'flex-direction: column',
      'align-items: center',
    ].join(';')

    const heading = document.createElement('h2')
    heading.textContent = 'Please verify you are not a bot'
    heading.style.cssText =
      'margin: 0 0 12px 0; font-size: 22px; font-weight: 600; color: #0f172a;'

    const para = document.createElement('p')
    para.textContent =
      "We are constantly attacked by bots (apparently they're very keen to get into coding!). Please tick the box below to confirm you are human."
    para.style.cssText =
      'margin: 0 0 20px 0; font-size: 15px; line-height: 1.5; color: #475569;'

    const container = document.createElement('div')
    container.style.cssText = 'display: flex; justify-content: center;'

    panel.appendChild(heading)
    panel.appendChild(para)
    panel.appendChild(container)
    overlay.appendChild(panel)
    document.body.appendChild(overlay)

    const showOverlay = () => {
      overlay.style.display = 'flex'
    }
    const hideOverlay = () => {
      overlay.style.display = 'none'
    }

    readyRef.current = loadTurnstileScript().then(() => {
      if (cancelled || !window.turnstile) {
        return
      }
      localWidgetId = window.turnstile.render(container, {
        sitekey: siteKey,
        execution: 'execute',
        appearance: 'interaction-only',
        callback: (token) => {
          hideOverlay()
          pendingRef.current?.resolve(token)
          pendingRef.current = null
        },
        'error-callback': (code) => {
          hideOverlay()
          pendingRef.current?.reject(new Error(`Turnstile error: ${code}`))
          pendingRef.current = null
        },
        'expired-callback': () => {
          hideOverlay()
          pendingRef.current?.reject(
            new Error('Turnstile token expired before use')
          )
          pendingRef.current = null
        },
        'timeout-callback': () => {
          hideOverlay()
          pendingRef.current?.reject(new Error('Turnstile timed out'))
          pendingRef.current = null
        },
        'before-interactive-callback': () => {
          showOverlay()
        },
      })
      widgetIdRef.current = localWidgetId
    })
    // Mark the ready promise as handled so a script-load failure (ad blockers,
    // network blips) doesn't surface as an unhandled rejection. execute() still
    // receives the rejection via its own await and shows the captcha error UI.
    readyRef.current.catch(() => {})

    return () => {
      cancelled = true
      if (window.turnstile && localWidgetId) {
        try {
          window.turnstile.remove(localWidgetId)
        } catch {
          // Widget was never registered or already removed — ignore.
        }
      }
      if (widgetIdRef.current === localWidgetId) {
        widgetIdRef.current = null
      }
      if (overlay.parentNode) {
        overlay.parentNode.removeChild(overlay)
      }
      pendingRef.current = null
    }
  }, [siteKey])

  const execute = useCallback(async (): Promise<string> => {
    if (!readyRef.current) {
      throw new Error('Turnstile not initialized')
    }
    await readyRef.current
    if (!window.turnstile || !widgetIdRef.current) {
      throw new Error('Turnstile widget not available')
    }
    if (pendingRef.current) {
      pendingRef.current.reject(
        new Error('Turnstile execute() called while previous call was pending')
      )
    }
    return new Promise<string>((resolve, reject) => {
      pendingRef.current = { resolve, reject }
      window.turnstile!.reset(widgetIdRef.current!)
      window.turnstile!.execute(widgetIdRef.current!)
    })
  }, [])

  return { execute }
}
