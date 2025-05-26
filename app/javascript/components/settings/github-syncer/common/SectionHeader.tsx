import React, { useContext } from 'react'
import { InsiderBubble } from './InsiderBubble'
import { GitHubSyncerContext } from '../GitHubSyncerForm'

export function SectionHeader({ title }: { title: string }) {
  const { isUserInsider } = useContext(GitHubSyncerContext)
  if (isUserInsider) {
    return <h2>{title}</h2>
  }
  return (
    <div className="flex justify-between items-start">
      <h2>{title}</h2>
      <InsiderBubble />
    </div>
  )
}
