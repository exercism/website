import React from 'react'
import { SiteUpdate } from './site-updates-list/SiteUpdate'
import { SiteUpdate as SiteUpdateProps, SiteUpdateContext } from '../types'

export default function SiteUpdatesList({
  updates,
  context,
}: {
  updates: readonly SiteUpdateProps[]
  context: SiteUpdateContext
}): JSX.Element {
  return (
    <div className="updates">
      {updates.map((update, i) => {
        return <SiteUpdate key={i} context={context} update={update} />
      })}
    </div>
  )
}
