// import { useState } from 'react'
import { 
  BrowserRouter as Router,
  Routes,
  Route,
  useRoutes, } from 'react-router-dom'
import {Container} from 'react-bootstrap'
import Home from './pages/Home'
import Store from './pages/Store'
import About from './pages/About'
import Navbar from './components/Navbar'
import { ShoppingCardProvider } from './context/ShoppingCartContext'

function App() {
  return (
    <ShoppingCardProvider>
      <Container className='mb-4'>
        <Router>
          <Navbar/>
          <AppRoute/>
        </Router>
      </Container>
    </ShoppingCardProvider>
  )
}

export default App


const AppRoute = () => {
  const routes = useRoutes([
    { path: "/", element: <Home /> },
    { path: "/store", element: <Store /> },
    { path: "/about", element: <About /> },
    // ...
  ]);
  return routes;
};