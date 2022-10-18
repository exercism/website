import React from 'react'
import Tippy, { TippyProps } from '@tippyjs/react'
import { Instance } from 'tippy.js'
import { renderComponents } from '@/utils/react-bootloader'
import { mappings } from '@/packs/application'

// Export own set of props (even if they are the same for now) to enable clients to be more future-proof
export type LazyTippyProps = TippyProps & {
  renderReactComponents: boolean
}

export const LazyTippy = (props: LazyTippyProps) => {
  const [mounted, setMounted] = React.useState(false)

  const lazyPlugin = {
    fn: () => ({
      onMount: () => setMounted(true),
      onHidden: () => setMounted(false),
      onShown: (instance: Instance) => {
        if (props.renderReactComponents) {
          renderComponents(instance.popper, mappings)
        }
      },
    }),
  }

  const computedProps = { ...props }

  computedProps.plugins = [lazyPlugin, ...(props.plugins || [])]

  if (props.render) {
    const { render } = props // let TypeScript safely derive that render is not undefined
    computedProps.render = (...args) => (mounted ? render(...args) : '')
  } else {
    computedProps.content = mounted ? props.content : ''
  }

  console.log(computedProps)

  return <Tippy {...computedProps} />
}
