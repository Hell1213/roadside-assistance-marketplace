import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "Roadside Assistance - Admin Panel",
  description: "Admin panel for roadside assistance marketplace",
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en">
      <body className="bg-gray-50 font-sans antialiased">
        {children}
      </body>
    </html>
  );
}