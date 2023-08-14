import React, { useCallback, useEffect, useState, useRef } from 'react'
import { copyToClipboard } from '../../utils/copyToClipboard'
import { Icon } from './Icon'

const KEY_NAMES = Object.freeze({
  SPACE: ' ',
})

const KEY_NAMES_LEGACY = Object.freeze({
  SPACE: 'Space',
})

export default function CopyToClipboardButton({
  textToCopy,
}: {
  textToCopy: string
}): JSX.Element {
  const buttonRef = useRef<HTMLButtonElement | null>(null)
  const [justCopied, setJustCopied] = useState(false)

  const copyTextToClipboard = useCallback(async () => {
    await copyToClipboard(textToCopy)
    setJustCopied(true)
  }, [textToCopy])

  const onKeyPress = useCallback(
    async (e: KeyboardEvent) => {
      if ((e.code === 'KeyC' || e.key === 'c') && (e.ctrlKey || e.metaKey)) {
        e.preventDefault()
        await copyTextToClipboard()
        return
      }

      if (e.key === KEY_NAMES_LEGACY.SPACE || e.key === KEY_NAMES.SPACE) {
        e.preventDefault()
        buttonRef.current?.click()
        return
      }
    },

    [copyTextToClipboard]
  )

  const onClick = useCallback(
    async (e) => {
      e.preventDefault()
      await copyTextToClipboard()
    },
    [copyTextToClipboard]
  )

  const onFocus = useCallback(
    () => buttonRef.current?.addEventListener('keydown', onKeyPress),
    [onKeyPress]
  )

  const onBlur = useCallback(
    () => buttonRef.current?.removeEventListener('keydown', onKeyPress),
    [onKeyPress]
  )

  useEffect(() => {
    if (!justCopied) {
      return
    }

    const justCopiedTimeout = 1000
    const timer = setTimeout(() => setJustCopied(false), justCopiedTimeout)
    return () => clearTimeout(timer)
  }, [justCopied, setJustCopied])

  return (
    <button
      ref={buttonRef}
      type="button"
      onClick={onClick}
      onFocus={onFocus}
      onBlur={onBlur}
      className="c-copy-text-to-clipboard center-message"
      aria-label={`Copy "${textToCopy}" to the cliboard`}
    >
      <div className="text">{textToCopy}</div>
      <Icon icon="clipboard" alt="Copy to clipboard" />
      {justCopied ? <span className="message">Copied</span> : null}
      <span data-test-clipboard data-content={textToCopy} />
    </button>
  )
}
