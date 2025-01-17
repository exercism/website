import React from 'react'
import { GraphicalIcon } from '@/components/common/GraphicalIcon'
import CopyToClipboardButton from '@/components/common/CopyToClipboardButton'
import useErrorStore from '../store/errorStore'

export function UnhandledErrorView() {
  const { unhandledErrorBase64 } = useErrorStore()
  return (
    <div className="border-t-1 border-borderColor6">
      <div className="text-center py-40 px-40 max-w-[600px] mx-auto">
        <GraphicalIcon
          className={`w-[48px] h-[48px] m-auto mb-20 filter-textColor6`}
          icon="bug"
        />
        <div className="text-h5 mb-6 text-textColor6">
          Oops! Something went wrong.
        </div>
        <div className="mb-20 text-textColor6 leading-160 text-16 text-balance">
          No worries - just click the copy button below to grab the error
          details, and share it with us on Discord!
        </div>
        <CopyToClipboardButton textToCopy={unhandledErrorBase64} />
      </div>
    </div>
  )
}
