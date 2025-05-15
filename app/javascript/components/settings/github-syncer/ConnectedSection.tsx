import React from 'react'
import { CommitMessageTemplateSection } from './CommitMessageTemplateSection'
import { DangerZoneSection } from './DangerZoneSection'
import { PathTemplateSection } from './PathTemplateSection'
import { ProcessingMethodSection } from './ProcessingMethodSection'

export function ConnectedSection() {
  return (
    <>
      <ProcessingMethodSection />
      <PathTemplateSection />
      <CommitMessageTemplateSection />
      <DangerZoneSection />
    </>
  )
}
