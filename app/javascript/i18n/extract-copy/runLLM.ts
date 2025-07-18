import { GoogleGenAI } from '@google/genai'

export async function runLLM(prompt: string): Promise<string | undefined> {
  const ai = new GoogleGenAI({
    apiKey: '[censored]',
  })

  const response = await ai.models.generateContent({
    model: 'gemini-2.0-flash',
    contents: prompt,
    config: {},
  })

  return response.text
}
