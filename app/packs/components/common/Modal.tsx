import React, { useRef, useEffect, useState } from 'react'
import { Modal as BaseModal } from '../modals/Modal'

export const Modal = ({ html }: { html: string }): JSX.Element => {
  const contentRef = useRef<HTMLDivElement | null>(null)
  const [isMounted, setIsMounted] = useState(false)
  const [open, setOpen] = useState(true)

  const onMount = (instance: HTMLDivElement) => {
    contentRef.current = instance

    setIsMounted(true)
  }

  useEffect(() => {
    if (!isMounted || !contentRef.current) {
      return
    }

    const handleClick = () => {
      setOpen(false)
    }

    const elements = contentRef.current.querySelectorAll('[data-modal-close]')

    elements.forEach((element) => {
      element.addEventListener('click', handleClick)
    })

    return () => {
      elements.forEach((element) => {
        element.removeEventListener('click', handleClick)
      })
    }
  }, [isMounted])

  return (
    <BaseModal
      open={open}
      onClose={() => {}}
      className=""
      appElement={document.querySelector('body') as HTMLElement}
    >
      <div ref={onMount} dangerouslySetInnerHTML={{ __html: html }} />
    </BaseModal>
  )
}
