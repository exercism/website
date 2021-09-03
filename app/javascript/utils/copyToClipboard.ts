export const copyToClipboard = async (text: string): Promise<void> => {
  try {
    await window.navigator.clipboard.writeText(text)
  } catch (error) {
    if (process.env.NODE_ENV == 'production') {
      throw error
    }
  }
}
