import { SidebarProvider } from "@/components/ui/sidebar"
import { AppSidebar } from "@/components/app-sidebar"

export default function Layout({ children }: { children: React.ReactNode }) {
  return (
    <SidebarProvider defaultOpen={false} className="h-full min-h-0">
      <AppSidebar />
      <main className="w-full h-full">
        {children}
      </main>
    </SidebarProvider>
  )
}