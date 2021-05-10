import React from 'react'
import { GraphicalIcon, CopyToClipboardButton } from '.'

export const SharePanel = ({
  title,
  textToCopy,
}: {
  title: string
  textToCopy: string
}): JSX.Element => {
  return (
    <React.Fragment>
      <h3>{title}</h3>
      {/* TODO: Set link */}
      <div className="btns">
        {/* TODO: https://dev.to/share-to-dev-button */}
        {/* TODO: Set link */}
        <a href="#" className="devto">
          <GraphicalIcon icon="external-site-devto" />
          DEV.to
        </a>
        {/* TODO: Set link */}
        <a href="#" className="linkedin">
          <GraphicalIcon icon="external-site-linkedin" />
          LinkedIn
        </a>
        {/* TODO: Set link */}
        <a href="#" className="reddit">
          <GraphicalIcon icon="external-site-reddit" />
          Reddit
        </a>
        {/* TODO: Set link */}
        <a href="#" className="twitter">
          <GraphicalIcon icon="external-site-twitter" />
          Twitter
        </a>
        {/* TODO: Set link */}
        <a href="#" className="facebook">
          <GraphicalIcon icon="external-site-facebook" />
          Facebook
        </a>
      </div>
      {/* TODO: Set link */}
      <CopyToClipboardButton textToCopy={textToCopy} />
    </React.Fragment>
  )
}
