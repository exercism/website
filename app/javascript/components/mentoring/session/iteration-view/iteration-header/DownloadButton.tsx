import React, { useState, useCallback } from 'react'
import { LazyTippy } from '../../../../misc/LazyTippy'
import { CopyToClipboardButton, Icon } from '../../../../common'

export const DownloadButton = ({
  command,
}: {
  command: string
}): JSX.Element => {
  const [isPanelOpen, setIsPanelOpen] = useState(false)

  const handlePanelToggle = useCallback(() => {
    setIsPanelOpen(!isPanelOpen)
  }, [isPanelOpen])

  const handlePanelClose = useCallback(() => {
    setIsPanelOpen(false)
  }, [])

  {
    /*TODO: Style button */
  }
  return (
    <LazyTippy
      content={<DownloadPanel command={command} />}
      interactive={true}
      visible={isPanelOpen}
      onClickOutside={handlePanelClose}
    >
      <button
        className="btn-enhanced"
        type="button"
        onClick={handlePanelToggle}
      >
        <Icon icon="download" alt="Download solution" />
      </button>
    </LazyTippy>
  )
}

{
  /*TODO: Style dropdown */
}
const DownloadPanel = ({ command }: { command: string }): JSX.Element => {
  return (
    <div>
      <CopyToClipboardButton textToCopy={command} />
    </div>
  )
}
