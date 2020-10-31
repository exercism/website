import React, { useEffect, useState } from 'react'

export function CopyToClipboardButton({ textToCopy }: { textToCopy: string }) {
  if (navigator.clipboard === undefined) {
    return null
  }

  const [justCopied, setJustCopied] = useState(false)

  const onClick = async () => {
    await navigator.clipboard.writeText(textToCopy)
    setJustCopied(true)
  }

  useEffect(() => {
    if (!justCopied) {
      return
    }

    const justCopiedTimeout = 2000
    const timer = setTimeout(() => setJustCopied(false), justCopiedTimeout)
    return () => clearTimeout(timer)
  }, [justCopied, setJustCopied])

  return (
    <button
      onClick={onClick}
      className={`c-copy-to-clipboard-button ${justCopied ? 'copied' : ''}`}
    >
      {justCopied ? 'Copied' : 'Copy'}
    </button>
  )
}
