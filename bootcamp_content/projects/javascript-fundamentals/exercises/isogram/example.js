export const isIsogram = (phrase) => {
  const letters = phrase.replaceAll('-', '').replaceAll(' ', '')

  const uniqueLetters = letters
    .toLowerCase()
    .split('')
    .filter((element, index, self) => self.indexOf(element) === index)

  return letters.length === uniqueLetters.length
}

/* Or...
export const isIsogram = (phrase) => {
  const letters = phrase.replaceAll('-', '').replaceAll(' ', '').toLowerCase();
  return letters.length === new Set(letters).size
};
*/
