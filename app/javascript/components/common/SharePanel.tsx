import React, { forwardRef, HTMLProps } from 'react'
import CopyToClipboardButton from './CopyToClipboardButton'
import { SharePlatform } from '../types'
import { PlatformButton } from './share-panel/PlatformButton'

type Props = {
  title: string
  shareTitle: string
  url: string
  className?: string
  platforms: readonly SharePlatform[]
} & HTMLProps<HTMLDivElement>

export const SharePanel = forwardRef<HTMLDivElement, Props>(
  ({ title, url, shareTitle, className, platforms, ...props }, ref) => {
    const classNames = `${className} c-share-panel`
    return (
      <div className={classNames} {...props} ref={ref}>
        <h3>{title}</h3>
        <div className="btns">
          {platforms.map((p) => (
            <PlatformButton key={p} platform={p} url={url} title={shareTitle} />
          ))}
        </div>
        <CopyToClipboardButton textToCopy={url} />
      </div>
    )
  }
)
