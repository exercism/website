export function onGuestList(guestList, formalName) {
  const surname = formalName.split(' ').slice(1).join(' ')

  for (const name of guestList) {
    if (name.endsWith(surname)) return true
  }

  return false
}
