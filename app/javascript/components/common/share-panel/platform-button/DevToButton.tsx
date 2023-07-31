import React from 'react'
import { GraphicalIcon } from '../../GraphicalIcon'

const shareLink = ({ url, title }: { url: string; title: string }) => {
  const markdown = `
    ---
    title: ${title}
    ---
    ${url}
  `

  return `https://dev.to/new?prefill=${encodeURI(markdown)}`
}

export const DevToButton = ({
  url,
  title,
}: {
  url: string
  title: string
}): JSX.Element => {
  return (
    <a
      href={shareLink({ url, title })}
      className="devto"
      target="_blank"
      rel="noreferrer"
    >
      <GraphicalIcon icon="external-site-devto" />
      DEV.to
    </a>
  )
}
