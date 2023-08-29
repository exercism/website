import React, { useState, useCallback } from 'react'
import { LazyTippy } from '@/components/misc/LazyTippy'
import { Icon } from '@/components/common'
import CopyToClipboardButton from '@/components/common/CopyToClipboardButton'

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

  return (
    <LazyTippy
      content={<DownloadPanel command={command} />}
      interactive={true}
      visible={isPanelOpen}
      maxWidth="none"
      onClickOutside={handlePanelClose}
    >
      <button
        className="btn-s btn-default download-btn"
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
    <div className="z-tooltip bg-backgroundColorA shadow-lgZ1 py-24 px-24 rounded-8">
      <h3 className="text-h5 mb-8">Download this solution via the CLI</h3>
      <p className="text-p-base mb-8">
        This solution will be downloaded into a subdirectory specifically for
        this student.
      </p>
      <CopyToClipboardButton textToCopy={command} />
    </div>
  )
}
