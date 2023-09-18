import React from 'react'
import Tippy, { TippyProps } from '@tippyjs/react'
import { Instance } from 'tippy.js'
import { renderComponents } from '@/utils/react-bootloader'
import { mappings } from '@/packs/application'

// Export own set of props (even if they are the same for now) to enable clients to be more future-proof
export type LazyTippyProps = TippyProps & {
  renderReactComponents?: boolean
}

export const LazyTippy = (props: LazyTippyProps): JSX.Element => {
  const { renderReactComponents, ...tippyProps } = props
  const [mounted, setMounted] = React.useState(false)

  const lazyPlugin = {
    fn: () => ({
      onMount: () => setMounted(true),
      onHidden: () => setMounted(false),
      onAfterUpdate: (instance: Instance) => {
        if (renderReactComponents) {
          renderComponents(instance.popper, mappings)
        }
      },
    }),
  }

  const computedProps = { ...tippyProps }

  computedProps.plugins = [lazyPlugin, ...(tippyProps.plugins || [])]

  if (tippyProps.render) {
    const { render } = tippyProps // let TypeScript safely derive that render is not undefined
    computedProps.render = (...args) => (mounted ? render(...args) : '')
  } else {
    computedProps.content = mounted ? tippyProps.content : ''
  }

  return <Tippy {...computedProps} />
}
