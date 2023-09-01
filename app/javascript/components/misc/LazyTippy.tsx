import React, { useEffect, useState } from 'react'
import Tippy, { TippyProps } from '@tippyjs/react'
import { Instance } from 'tippy.js'
import { renderComponents } from '@/utils/react-bootloader'
import { mappings } from '@/packs/application'

// Export own set of props (even if they are the same for now) to enable clients to be more future-proof
export type LazyTippyProps = TippyProps & {
  renderReactComponents?: boolean
}

export const LazyTippy = (props: LazyTippyProps): JSX.Element => {
  // const { renderReactComponents, ...tippyProps } = props
  const [tippyProps, setTippyProps] = useState(props)
  const [mounted, setMounted] = React.useState(false)

  const lazyPlugin = {
    fn: () => ({
      onMount: () => setMounted(true),
      onHidden: () => setMounted(false),
      onAfterUpdate: (instance: Instance) => {
        if (tippyProps.renderReactComponents) {
          renderComponents(instance.popper, mappings)
        }
      },
    }),
  }

  // const computedProps = { ...tippyProps }

  useEffect(() => {
    if (tippyProps.render) {
      // console.log('tippyprops render')
      const { render } = tippyProps // let TypeScript safely derive that render is not undefined
      setTippyProps({
        render: (...args) => (mounted ? render(...args) : ''),
        ...tippyProps,
      })
    } else {
      setTippyProps({
        content: mounted ? tippyProps.content : '',
        ...tippyProps,
      })
    }
    setTippyProps({
      plugins: [lazyPlugin, ...(tippyProps.plugins || [])],
      ...tippyProps,
    })
  }, [])

  return <Tippy {...tippyProps} />
}
