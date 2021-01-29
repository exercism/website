import React from 'react'
import { usePanel } from '../../hooks/use-panel'

type MenuItem = {
  html: string
}

export const PrerenderedDropdown = ({
  menuButtonHtml,
  menuItems,
}: {
  menuButtonHtml: string
  menuItems: MenuItem[]
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
          <ul>
            {menuItems.map((item) => {
              return (
                <li
                  key={item.html}
                  dangerouslySetInnerHTML={{ __html: item.html }}
                />
              )
            })}
          </ul>
        ) : null}
      </div>
    </React.Fragment>
  )
}
