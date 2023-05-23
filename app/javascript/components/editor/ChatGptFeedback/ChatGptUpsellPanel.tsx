import React from 'react'
import { Tab } from '@/components/common'
import { TabsContext } from '../../Editor'

export const ChatGptUpsellPanel = (): JSX.Element => {
  return (
    <Tab.Panel id="chatgpt" context={TabsContext}>
      <section className="flex justify-center pb-16 px-24">Upsell</section>
    </Tab.Panel>
  )
}
