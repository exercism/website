import { emojis } from '../setupHeleprs/emoji'
import { honorifics } from '../setupHeleprs/honorifics'

export const genericSetupFunctions = {
  join: (...args: any[]) => args.join(''),
  randomEmoji: () => randomItem(emojis),
  randomHonorific: () => randomItem(honorifics),
}

const randomItem = (list) => list[Math.floor(Math.random() * list.length)]
