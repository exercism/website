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
          Oops! Something went <strong className="font-bold">very</strong>{' '}
          wrong.
        </div>
        <div className="mb-20 text-textColor6 leading-160 text-16 text-balance">
          It would be very helpful if you could tell us about this error so we
          can improve things. Please click the button below to copy the
          mysterious text to your clipboard, and share it with us on Discord or
          the forum. Thank you! 💙
        </div>
        <CopyToClipboardButton textToCopy={unhandledErrorBase64} />
      </div>
    </div>
  )
}
