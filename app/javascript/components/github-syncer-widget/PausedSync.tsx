import React from 'react'

// Syncer disabled: "Your syncer is currently disabled. Visit your settings (LINK <<) to enable it"
export function PausedSync({
  settingsLink,
}: {
  settingsLink: string
}): JSX.Element {
  return (
    <div className="flex flex-col items-center py-24">
      <h6 className="font-semibold text-16 mb-16">
        Your syncer is currently <span className="text-orange">paused.</span>
      </h6>
      <p className="text-center text-balance">
        Visit your{' '}
        <a href={settingsLink} className="text-prominentLinkColor">
          settings
        </a>{' '}
        to resume syncing.
      </p>
    </div>
  )
}
