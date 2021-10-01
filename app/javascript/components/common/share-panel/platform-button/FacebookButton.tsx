import React from 'react'
import { GraphicalIcon } from '../../GraphicalIcon'

const shareLink = ({ url }: { url: string }) => {
  return encodeURI(`https://www.facebook.com/share.php?u=${url}`)
}

export const FacebookButton = ({ url }: { url: string }): JSX.Element => {
  return (
    <a
      href={shareLink({ url })}
      className="facebook"
      target="_blank"
      rel="noreferrer"
    >
      <GraphicalIcon icon="external-site-facebook" />
      Facebook
    </a>
  )
}
