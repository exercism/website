import React from 'react'

export function InfoMessage({
  insidersStatus,
  insidersPath,
  isInsider,
}: {
  insidersStatus: string
  insidersPath: string
  isInsider: boolean
}): JSX.Element {
  if (isInsider) {
    return (
      <p className="text-p-base mb-16">
        As an Exercism Insider, you have access to Dark Mode. Choose between
        light, dark, or automatically update based on your system preferences.
        Enjoy! 💎
      </p>
    )
  }

  switch (insidersStatus) {
    case 'eligible':
    case 'eligible_lifetime':
      return (
        <p className="text-p-base mb-16">
          You&apos;re eligible to join Insiders.{' '}
          <a href={insidersPath}>Get started here.</a>
        </p>
      )
    default:
      return (
        <p className="text-p-base mb-16">
          Dark Mode is only available to Exercism Insiders.&nbsp;
          <strong>
            <a className="text-prominentLinkColor" href={insidersPath}>
              Donate to Exercism
            </a>
          </strong>{' '}
          and become an Insider to access Dark Mode, ChatGPT integration and
          more.
        </p>
      )
  }
}
