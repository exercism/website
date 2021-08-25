import React, { createContext, useState } from 'react'
import { Modal, ModalProps } from '../../modals/Modal'
import { Track } from '../../types'
import { LeaveTrackForm } from './leave-track-modal/LeaveTrackForm'
import { LeaveResetTrackForm } from './leave-track-modal/LeaveResetTrackForm'
import { Tab, TabContext } from '../../common/Tab'

const TabsContext = createContext<TabContext>({
  current: 'leave',
  switchToTab: () => {},
})

export type UserTrack = {
  links: {
    self: string
  }
}

type TabIndex = 'leave' | 'reset'

export const LeaveTrackModal = ({
  endpoint,
  onClose,
  track,
  ...props
}: Omit<ModalProps, 'className'> & {
  endpoint: string
  track: Track
}): JSX.Element => {
  const [tab, setTab] = useState<TabIndex>('leave')

  return (
    <Modal
      className="m-leave-track m-generic-destructive"
      onClose={onClose}
      {...props}
    >
      <div className="info">
        <h2>You’re about to leave the {track.title} track.</h2>
        <p className="large">
          No longer interested in learning {track.title}? No problem!
        </p>
      </div>

      <TabsContext.Provider
        value={{
          current: tab,
          switchToTab: (id: string) => setTab(id as TabIndex),
        }}
      >
        <div className="tabs">
          <Tab context={TabsContext} id="leave">
            Leave
          </Tab>
          <Tab context={TabsContext} id="reset">
            Leave + Reset
          </Tab>
        </div>
        <Tab.Panel context={TabsContext} id="leave">
          <LeaveTrackForm
            endpoint={endpoint}
            track={track}
            onCancel={onClose}
          />
        </Tab.Panel>
        <Tab.Panel context={TabsContext} id="reset">
          <LeaveResetTrackForm
            endpoint={endpoint}
            track={track}
            onCancel={onClose}
          />
        </Tab.Panel>
      </TabsContext.Provider>
    </Modal>
  )
}
