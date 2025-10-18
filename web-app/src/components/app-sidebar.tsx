import { Play } from "lucide-react"

import {
  Sidebar,
  SidebarContent,
  SidebarHeader,
  SidebarMenu,
  SidebarMenuButton,
  SidebarMenuItem,
} from "@/components/ui/sidebar"

export function AppSidebar() {
  return (
    <Sidebar>
      <SidebarHeader className="h-16 flex items-center justify-center px-4 border-b">
        <h2 className="text-lg font-semibold">Circuits</h2>
      </SidebarHeader>
      <SidebarContent>
        <SidebarMenu>
          <SidebarMenuItem>
            <SidebarMenuButton asChild className="px-6 py-6">
              <a href="#" className="flex items-center gap-2">
                <Play className="h-4 w-4" />
                <span>Demo</span>
              </a>
            </SidebarMenuButton>
          </SidebarMenuItem>
        </SidebarMenu>
      </SidebarContent>
    </Sidebar>
  )
}