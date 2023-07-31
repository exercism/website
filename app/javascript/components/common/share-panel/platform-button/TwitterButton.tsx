import React from 'react'
import { GraphicalIcon } from '../../GraphicalIcon'

const shareLink = ({ url, title }: { url: string; title: string }) => {
  return encodeURI(`https://twitter.com/intent/tweet?url=${url}&title=${title}`)
}

export const TwitterButton = ({
  url,
  title,
}: {
  url: string
  title: string
}): JSX.Element => {
  return (
    <a
      href={shareLink({ url, title: title })}
      className="twitter"
      target="_blank"
      rel="noreferrer"
    >
      <GraphicalIcon icon="external-site-twitter" />
      Twitter
    </a>
  )
}
