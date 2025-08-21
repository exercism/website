// i18n-key-prefix: sectionHeader
// i18n-namespace: components/settings/github-syncer/common
import React from 'react'
import { InsiderBubble } from './InsiderBubble'

export function SectionHeader({ title }: { title: string }) {
  return (
    <div className="!mb-6 flex justify-start items-center gap-12">
      <h2 className="!mb-0">{title}</h2>
      <InsiderBubble />
    </div>
  )
}
