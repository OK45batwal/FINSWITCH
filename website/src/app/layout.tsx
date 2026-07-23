import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  metadataBase: new URL("https://finswitch.pages.dev"),
  title: {
    default: "FinSwitch — Real-Time Stock Market Intelligence",
    template: "%s | FinSwitch",
  },
  description:
    "AI-powered financial decision intelligence platform for Indian stock markets. Track holdings, analyze technical indicators, and get real-time market insights.",
  keywords: [
    "FinSwitch",
    "Stock Market",
    "Indian Stocks",
    "Nifty 50",
    "Sensex",
    "Portfolio Tracker",
    "AI Finance",
    "Stock Screener",
  ],
  authors: [{ name: "FinSwitch Team" }],
  icons: {
    icon: [
      { url: "/favicon.svg", type: "image/svg+xml" },
      { url: "/favicon.png", type: "image/png" },
    ],
    shortcut: "/favicon.png",
    apple: "/favicon.png",
  },
  openGraph: {
    title: "FinSwitch — Real-Time Stock Market Intelligence",
    description:
      "AI-powered financial decision intelligence platform for Indian stock markets. Track holdings, analyze technical indicators, and get real-time market insights.",
    url: "https://finswitch.pages.dev",
    siteName: "FinSwitch",
    images: [
      {
        url: "https://finswitch.pages.dev/assets/website-hero.png",
        width: 1200,
        height: 630,
        alt: "FinSwitch Dashboard Overview",
      },
    ],
    locale: "en_IN",
    type: "website",
  },
  twitter: {
    card: "summary_large_image",
    title: "FinSwitch — Real-Time Stock Market Intelligence",
    description:
      "AI-powered financial decision intelligence platform for Indian stock markets.",
    images: ["https://finswitch.pages.dev/assets/website-hero.png"],
  },
  robots: {
    index: true,
    follow: true,
  },
};

import { ThemeProvider } from "@/components/ThemeProvider";

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en" className="h-full antialiased dark">
      <body className="min-h-full flex flex-col bg-background text-foreground">
        <ThemeProvider>{children}</ThemeProvider>
      </body>
    </html>
  );
}
