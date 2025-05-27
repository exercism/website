import React from 'react'
import { CommitMessageTemplateSection } from './CommitMessageTemplateSection'
import { DangerZoneSection } from './DangerZoneSection'
import { PathTemplateSection } from './PathTemplateSection'
import { ProcessingMethodSection } from './ProcessingMethodSection'
import { IterationFilesSection } from './IterationFilesSection'
import { StatusSection } from './StatusSection'
import { ManualSyncSection } from './ManualSyncSection'

export function ConnectedSection() {
  return (
    <>
      <StatusSection />
      <ProcessingMethodSection />
      <IterationFilesSection />
      <PathTemplateSection />
      <CommitMessageTemplateSection />
      <ManualSyncSection />
      <DangerZoneSection />
    </>
  )
}
