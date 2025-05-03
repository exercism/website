function strip_your_honor(name) {
  let found_space = false
  let surname = ''
  for (const letter of name) {
    if (found_space) {
      surname = surname + letter
    } else if (letter == ' ') {
      found_space = true
    }
  }
  return surname
}

export function on_guest_list(guest_list, formal_name) {
  const surname = strip_your_honor(formal_name)

  for (const name of guest_list) {
    if (name.endsWith(surname)) return true
  }

  return false
}
