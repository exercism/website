import React from 'react'
import { usePanel } from '../../hooks/use-panel'

export const PrerenderedDropdown = ({
  menuButtonHtml,
  menuItemsHtml,
}: {
  menuButtonHtml: string
  menuItemsHtml: string
}): JSX.Element => {
  const { open, setOpen, buttonRef, panelRef, styles, attributes } = usePanel()

  return (
    <React.Fragment>
      <button
        dangerouslySetInnerHTML={{ __html: menuButtonHtml }}
        ref={buttonRef}
        onClick={() => {
          setOpen(!open)
        }}
      />
      <div ref={panelRef} style={styles.popper} {...attributes.popper}>
        {open ? (
          <div dangerouslySetInnerHTML={{ __html: menuItemsHtml }} />
        ) : null}
      </div>
    </React.Fragment>
  )
}
