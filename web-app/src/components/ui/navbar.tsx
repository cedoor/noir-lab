import { ModeToggle } from "../mode-toggle"
import { SidebarTrigger } from "./sidebar"

export function Navbar() {
  return (
    <nav className="border-b bg-background/95 backdrop-blur supports-[backdrop-filter]:bg-background/60">
      <div className="max-w-4xl mx-auto px-4">
        <div className="flex h-16 items-center justify-between">
          <div className="flex items-center space-x-4">
            <SidebarTrigger />
            <h1 className="text-xl font-bold tracking-tight">Noir Lab</h1>
          </div>
          <div className="flex items-center space-x-4">
            <ModeToggle />
          </div>
        </div>
      </div>
    </nav>
  )
}
