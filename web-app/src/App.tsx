import { ThemeProvider } from './components/theme-provider';
import { Navbar } from './components/ui/navbar';
import Demo from './pages/demo';
import Layout from './layout';

function App() {
  return (
    <ThemeProvider defaultTheme="dark" storageKey="vite-ui-theme">
      <Layout>
        <div className="space-y-4">
          <Navbar />
          <div className="p-4">
            <Demo />
          </div>
        </div>
      </Layout>
    </ThemeProvider>
  )
}

export default App
