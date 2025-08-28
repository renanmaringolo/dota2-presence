import type { Metadata } from "next"
import { Inter } from "next/font/google"
import "./globals.css"
import { Providers } from "./providers"

const inter = Inter({ subsets: ["latin"] })

export const metadata: Metadata = {
  title: "Dota Evolution Presence",
  description: "Sistema de presença para partidas de Dota 2 - Dota Evolution",
  keywords: ["dota", "dota 2", "coaching", "presença", "gaming"],
  authors: [{ name: "Renan Proença (Metallica)" }],
  viewport: "width=device-width, initial-scale=1, maximum-scale=1",
  themeColor: "#111827",
  manifest: "/manifest.json",
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="pt-BR">
      <body className={inter.className}>
        <Providers>
          <div className="min-h-screen bg-gradient-to-br from-gray-900 via-blue-900 to-purple-900">
            <div className="absolute inset-0 bg-[url('/grid.svg')] opacity-10" />
            <div className="relative z-10">
              {children}
            </div>
          </div>
        </Providers>
      </body>
    </html>
  )
}