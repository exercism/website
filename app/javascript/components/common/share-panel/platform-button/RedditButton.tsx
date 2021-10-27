import React from 'react'
import { GraphicalIcon } from '../../GraphicalIcon'

const shareLink = ({ url, title }: { url: string; title: string }) => {
  return encodeURI(`http://www.reddit.com/submit?url=${url}&title=${title}`)
}

export const RedditButton = ({
  url,
  title,
}: {
  url: string
  title: string
}): JSX.Element => {
  return (
    <a
      href={shareLink({ url, title })}
      className="reddit"
      target="_blank"
      rel="noreferrer"
    >
      <GraphicalIcon icon="external-site-reddit" />
      Reddit
    </a>
  )
}
