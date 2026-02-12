import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import ChangePasswordForm from './components/ChangePasswordForm';
import ResetPassword from './components/ResetPassword';

function App() {
  return (
    <Router>
      <div className="App">
        <h1>Certification Exam App</h1>
        <Routes>
          <Route path="/change-password" element={<ChangePasswordForm />} />
          <Route path="/reset-password" element={<ResetPassword />} />
          {/* Add more routes here, e.g., <Route path="/" element={<Home />} /> */}
        </Routes>
      </div>
    </Router>
  );
}

export default App;
