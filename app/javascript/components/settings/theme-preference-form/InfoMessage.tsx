import React from 'react'

export function InfoMessage({
  insidersStatus,
  insidersPath,
  isPremium,
  premiumPath,
}: {
  insidersStatus: string
  insidersPath: string
  isPremium: boolean
  premiumPath: string
}): JSX.Element {
  if (isPremium) {
    return (
      <p className="text-p-base mb-16">
        As an Exercism Premium member, you have access to Dark Mode. Choose
        between light, dark, or automatically update based on your system
        preferences. Enjoy! 💎
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
          Dark Mode is only available to Exercism Premium Members.&nbsp;
          <strong>
            <a className="text-prominentLinkColor" href={premiumPath}>
              Upgrade to Premium
            </a>
          </strong>{' '}
          to access Dark Mode, ChatGPT integration and more.
        </p>
      )
  }
}
