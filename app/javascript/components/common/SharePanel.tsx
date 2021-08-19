import React, { forwardRef, HTMLProps } from 'react'
import { GraphicalIcon, CopyToClipboardButton } from '.'

type Props = {
  title: string
  shareTitle: string
  url: string
  className?: string
} & HTMLProps<HTMLDivElement>

const facebookLink = ({ url }: { url: string }) => {
  return encodeURI(`https://www.facebook.com/share.php?u=${url}`)
}

const twitterLink = ({ url, title }: { url: string; title: string }) => {
  return encodeURI(`https://twitter.com/intent/tweet?url=${url}&title=${title}`)
}

const redditLink = ({ url, title }: { url: string; title: string }) => {
  return encodeURI(`http://www.reddit.com/submit?url=${url}&title=${title}`)
}

const linkedinLink = ({ url, title }: { url: string; title: string }) => {
  return encodeURI(
    `https://www.linkedin.com/shareArticle?url=${url}&title=${title}`
  )
}

const devToLink = ({ url, title }: { url: string; title: string }) => {
  const markdown = `
    ---
    title: ${title}
    ---
    ${url}
  `

  return `https://dev.to/new?prefill=${encodeURI(markdown)}`
}

export const SharePanel = forwardRef<HTMLDivElement, Props>(
  ({ title, url, shareTitle, className, ...props }, ref) => {
    const classNames = `${className} c-share-panel`
    return (
      <div className={classNames} {...props} ref={ref}>
        <h3>{title}</h3>
        <div className="btns">
          <a
            href={devToLink({ url, title: shareTitle })}
            className="devto"
            target="_blank"
            rel="noreferrer"
          >
            <GraphicalIcon icon="external-site-devto" />
            DEV.to
          </a>
          <a
            href={linkedinLink({ url, title: shareTitle })}
            className="linkedin"
            target="_blank"
            rel="noreferrer"
          >
            <GraphicalIcon icon="external-site-linkedin" />
            LinkedIn
          </a>
          <a
            href={redditLink({ url, title: shareTitle })}
            className="reddit"
            target="_blank"
            rel="noreferrer"
          >
            <GraphicalIcon icon="external-site-reddit" />
            Reddit
          </a>
          <a
            href={twitterLink({ url, title: shareTitle })}
            className="twitter"
            target="_blank"
            rel="noreferrer"
          >
            <GraphicalIcon icon="external-site-twitter" />
            Twitter
          </a>
          <a
            href={facebookLink({ url })}
            className="facebook"
            target="_blank"
            rel="noreferrer"
          >
            <GraphicalIcon icon="external-site-facebook" />
            Facebook
          </a>
        </div>
        <CopyToClipboardButton textToCopy={url} />
      </div>
    )
  }
)
