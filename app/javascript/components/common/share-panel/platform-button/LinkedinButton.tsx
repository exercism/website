import React from 'react'
import { GraphicalIcon } from '../../GraphicalIcon'

const shareLink = ({ url, title }: { url: string; title: string }) => {
  return encodeURI(
    `https://www.linkedin.com/shareArticle?url=${url}&title=${title}`
  )
}

export const LinkedinButton = ({
  url,
  title,
}: {
  url: string
  title: string
}): JSX.Element => {
  return (
    <a
      href={shareLink({ url, title })}
      className="linkedin"
      target="_blank"
      rel="noreferrer"
    >
      <GraphicalIcon icon="external-site-linkedin" />
      LinkedIn
    </a>
  )
}
