import React, { useState, useCallback, useEffect } from 'react'
import { copyToClipboard } from '@/utils/copyToClipboard'
import { Icon } from '@/components/common'
import type { File } from '@/components/types'

const formatForClipboard = (
  files: readonly File[],
  separator = '\n\n\n\n\n'
): string => {
  return files.map((f) => f.content).join(separator)
}

const JUST_COPIED_TIMEOUT = 1000

export const CopyButton = ({
  files,
}: {
  files: readonly File[]
}): JSX.Element => {
  const [justCopied, setJustCopied] = useState(false)
  const textToCopy = formatForClipboard(files)
  const classNames = [
    'c-copy-text-to-clipboard',
    justCopied ? '--copied' : '',
  ].filter((c) => c.length > 0)

  const handleCopy = useCallback(
    async (e) => {
      e.stopPropagation()
      await copyToClipboard(textToCopy)

      setJustCopied(true)
    },
    [textToCopy]
  )
  useEffect(() => {
    if (!justCopied) {
      return
    }

    const timer = setTimeout(() => setJustCopied(false), JUST_COPIED_TIMEOUT)

    return () => clearTimeout(timer)
  }, [justCopied, setJustCopied])

  return (
    <button type="button" className={classNames.join(' ')} onClick={handleCopy}>
      <Icon icon="clipboard" alt="Copy solution" />
      {justCopied ? <span className="message">Copied</span> : null}
      <span data-test-clipboard data-content={textToCopy} />
    </button>
  )
}
