import React from 'react'
import { SharePlatform } from '../../types'
import { DevToButton } from './platform-button/DevToButton'
import { LinkedinButton } from './platform-button/LinkedinButton'
import { RedditButton } from './platform-button/RedditButton'
import { FacebookButton } from './platform-button/FacebookButton'
import { TwitterButton } from './platform-button/TwitterButton'

export const PlatformButton = ({
  platform,
  ...props
}: {
  platform: SharePlatform
  title: string
  url: string
}): JSX.Element => {
  switch (platform) {
    case 'devto':
      return <DevToButton {...props} />
    case 'linkedin':
      return <LinkedinButton {...props} />
    case 'reddit':
      return <RedditButton {...props} />
    case 'facebook':
      return <FacebookButton {...props} />
    case 'twitter':
      return <TwitterButton {...props} />
  }
}
