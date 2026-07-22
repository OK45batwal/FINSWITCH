import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "FinSwitch — Real-Time Stock Market Intelligence",
  description: "Smart stock market analysis, portfolio tracking, and AI-powered insights for Indian markets.",
  icons: { icon: "/favicon.svg" },
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en" className="h-full antialiased">
      <body className="min-h-full flex flex-col">{children}</body>
    </html>
  );
}
