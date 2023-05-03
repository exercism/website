import React from 'react'

export function InfoMessage({
  insidersStatus,
  insidersPath,
}: {
  insidersStatus: string
  insidersPath: string
}): JSX.Element {
  switch (insidersStatus) {
    case 'active':
    case 'active_lifetime':
      return (
        <p className="text-p-base mb-16">
          As an Exercism Insider, you have access to Dark Theme. Choose between
          light, dark, or automatically update based on your system preferences.
          Thank you for being part of Exercism! 💙
        </p>
      )
    case 'eligible':
    case 'eligible_lifetime':
      return (
        <p className="text-p-base mb-16">
          You&apos;re eligible to join Insiders.{' '}
          <a href={insidersPath}>Get started here.</a>
        </p>
      )
    case 'ineligible':
      return (
        <p className="text-p-base mb-16">
          Dark theme is only available to Exercism Insiders.
        </p>
      )
    default:
      return (
        <p className="text-p-base mb-16">
          [Learn more about Exercism Insiders](...).
        </p>
      )
  }
}
