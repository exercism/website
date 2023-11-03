import React from 'react'
import { PlaceholderStuff } from './PlaceholderStuff'
import { TagSelector } from './TagSelector'
import { TagsFilter } from '@/components/student/tracks-list/TagsFilter'

export function RightPane({
  tags,
}: {
  tags: Record<string, string>
}): JSX.Element {
  return (
    <div className="px-24 h-100 flex flex-col">
      <PlaceholderStuff />
      <TagSelector tags={tags} />
      <button className="btn-m btn-primary mt-auto mb-64">Save, next!</button>
    </div>
  )
}
