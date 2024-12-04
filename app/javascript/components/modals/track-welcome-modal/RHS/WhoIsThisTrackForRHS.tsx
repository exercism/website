import { Track } from '@/components/types'
import React from 'react'

export function WhoIsThisTrackForRHS({ track }: { track: Track }): JSX.Element {
  return (
    <div className="rhs">
      <h2 className="text-h4 mb-16">Who is this track for?</h2>
      <ul className="flex flex-col gap-8 text-16 font-medium">
        <li> ✅ Developers Learning {track.title}</li>
        <li>✅ Developers Practicing {track.title}</li>

        <li>✅ Beginners Practicing {track.title} (but learning elsewhere).</li>

        <li>❌ Beginners Learning {track.title}</li>
      </ul>
    </div>
  )
}
