import { emojis } from '../setupHelpers/emoji'
import { honorifics } from '../setupHelpers/honorifics'

export function randomEmoji() {
  return randomItem(emojis)
}
const randomItem = (list) => list[Math.floor(Math.random() * list.length)]

export const genericSetupFunctions = {
  concatenate: (...args: any[]) => args.join(''),
  randomEmoji: randomEmoji,
  randomHonorific: () => randomItem(honorifics),
}
