import React from 'react'
import { CommitMessageTemplateSection } from './CommitMessageTemplateSection'
import { DangerZoneSection } from './DangerZoneSection'
import { PathTemplateSection } from './PathTemplateSection'
import { ProcessingMethodSection } from './ProcessingMethodSection.1'
import { IterationFilesSection } from './IterationFilesSection'
import { StatusSection } from './StatusSection'

export function ConnectedSection() {
  return (
    <>
      <StatusSection />
      <ProcessingMethodSection />
      <IterationFilesSection />
      <PathTemplateSection />
      <CommitMessageTemplateSection />
      <DangerZoneSection />
    </>
  )
}
