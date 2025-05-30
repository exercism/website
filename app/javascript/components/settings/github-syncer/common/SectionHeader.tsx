import React, { useContext } from 'react'
import { InsiderBubble } from './InsiderBubble'
import { GitHubSyncerContext } from '../GitHubSyncerForm'

export function SectionHeader({ title }: { title: string }) {
  const { isUserInsider } = useContext(GitHubSyncerContext)
  if (isUserInsider) {
    return <h2 className="!mb-6">{title}</h2>
  }
  return (
    <div className="!mb-6 flex justify-start items-center gap-12">
      <h2 className="!mb-0">{title}</h2>
      <InsiderBubble />
      <div className="absolute inset-0 opacity-0.8 z-100 cursor-not-allowed" />
    </div>
  )
}
