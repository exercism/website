import React from 'react'
import { CommitMessageTemplateSection } from './CommitMessageTemplateSection'
import { DangerZoneSection } from './DangerZoneSection'
import { FileStructureSection } from './FileStructureSection'
import { ProcessingMethodSection } from './ProcessingMethodSection'
import { IterationFilesSection } from './IterationFilesSection'
import { StatusSection } from './StatusSection'
import { ManualSyncSection } from './ManualSyncSection'
import { SyncBehaviourSection } from './SyncBehaviourSection'
import { JustConnectedModal } from './JustConnectedModal'

export function ConnectedSection() {
  return (
    <>
      <StatusSection />
      <ProcessingMethodSection />
      <SyncBehaviourSection />
      <IterationFilesSection />
      <FileStructureSection />
      <CommitMessageTemplateSection />
      <ManualSyncSection />
      <DangerZoneSection />
      <JustConnectedModal />
    </>
  )
}
