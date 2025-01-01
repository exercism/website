import React from 'react'

import { useEffect, useRef } from 'react'
import lottie, { type AnimationItem } from 'lottie-web'

type LottieAnimationProps = {
  animationData: object
  loop?: boolean
} & React.HTMLAttributes<HTMLDivElement>

function LottieAnimation({ animationData, ...props }: LottieAnimationProps) {
  const animationContainer = useRef<HTMLDivElement>(null)
  const animationInstance = useRef<AnimationItem | null>(null)

  useEffect(() => {
    if (animationContainer.current) {
      animationInstance.current = lottie.loadAnimation({
        container: animationContainer.current,
        renderer: 'svg',
        loop: props.loop === undefined ? true : props.loop,
        autoplay: true,
        animationData: animationData,
      })
    }

    return () => animationInstance.current?.destroy()
  }, [animationData])

  return <div ref={animationContainer} {...props} />
}

export default LottieAnimation
