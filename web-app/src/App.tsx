import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import { ThemeProvider } from './components/theme-provider';
import { Navbar } from './components/ui/navbar';
import Layout from './layout';
import Demo from './pages/demo';
import BFVCiphertextAddition from './pages/bfv-ciphertext-addition';

function App() {
  return (
    <ThemeProvider defaultTheme="dark" storageKey="vite-ui-theme">
      <Router basename="/noir-lab">
        <Layout>
          <div className="space-y-4">
            <Navbar />
            <div className="p-4">
              <Routes>
                <Route path="/" element={<Demo />} />
                <Route path="/bfv-ciphertext-addition" element={<BFVCiphertextAddition />} />
                <Route path="*" element={<Navigate to="/" replace />} />
              </Routes>
            </div>
          </div>
        </Layout>
      </Router>
    </ThemeProvider>
  )
}

export default App
