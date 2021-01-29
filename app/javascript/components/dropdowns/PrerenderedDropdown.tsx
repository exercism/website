import React from 'react'
import { usePanel } from '../../hooks/use-panel'

type MenuButton = {
  label: string
  id: string
  html: string
}

type MenuItem = {
  html: string
}

export const PrerenderedDropdown = ({
  menuButton,
  menuItems,
}: {
  menuButton: MenuButton
  menuItems: MenuItem[]
}): JSX.Element => {
  const { open, setOpen, buttonRef, panelRef, styles, attributes } = usePanel()

  return (
    <React.Fragment>
      <button
        aria-controls={`${menuButton.id}-dropdown`}
        aria-haspopup
        aria-label={menuButton.label}
        aria-expanded={open ? true : undefined}
        dangerouslySetInnerHTML={{ __html: menuButton.html }}
        ref={buttonRef}
        onClick={() => {
          setOpen(!open)
        }}
      />
      <div ref={panelRef} style={styles.popper} {...attributes.popper}>
        {open ? (
          <ul id={`${menuButton.id}-dropdown`} role="menu">
            {menuItems.map((item) => {
              return (
                <li
                  key={item.html}
                  dangerouslySetInnerHTML={{ __html: item.html }}
                  tabIndex={-1}
                  role="menuitem"
                />
              )
            })}
          </ul>
        ) : null}
      </div>
    </React.Fragment>
  )
}
