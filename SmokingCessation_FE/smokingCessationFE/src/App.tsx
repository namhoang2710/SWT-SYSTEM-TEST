import React from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate, useLocation } from 'react-router-dom';
import { AuthProvider, useAuth } from './contexts/AuthContext';
import LoginPage from './components/LoginPage';
import RegisterPage from './components/RegisterPage';
import HomePage from './components/HomePage';
import ProfilePage from './components/ProfilePage';
import BlogList from './components/BlogList';
import CreatePostPage from './components/CreatePostPage';
import MyBlogList from './components/MyBlogList';
import Navbar from './components/Navbar';
import HomeForCoach from './components/HomeForCoach';
import HomeForAdmin from './components/HomeForAdmin';
import MemberHomePage from './components/MemberHomePage';
import EditBlogPage from './components/EditBlogPage';
import PackagesPage from './components/PackagesPage';
import VerifyPage from './components/VerifyPage';
import SmokingProgressForm from './components/SmokingProgressForm';
import ConsultationPage from './components/ConsultationPage';
import CoachSchedulePage from './components/CoachSchedulePage';
import PaymentPage from './components/PaymentPage';
import CoachSchedulePageForCoach from './components/CoachSchedulePageForCoach';
import CoachMemberDetailPage from './components/CoachMemberDetailPage';
import AdminFeedbackPage from './components/AdminFeedbackPage';
import CreatePlanPage from './components/CreatePlanPage';
import CreateHealthProfilePage from './components/CreateHealthProfilePage';
import MemberHealthProfilePage from './components/MemberHealthProfilePage';
import MyQuitPlansPage from './components/MyQuitPlansPage';
import SmokingStatusPage from './components/SmokingStatusPage';
import ProgressPlanPage from './components/ProgressPlanPage';
import AdminBlogPage from './components/AdminBlogPage';
import AdminChatBoxPage from './components/AdminChatBoxPage';
import AdminMedalPage from './components/AdminMedalPage';
import AdminMemberPage from './components/AdminMemberPage';
import ConsultationHistoryPage from './components/ConsultationHistoryPage';
import { ToastContainer } from 'react-toastify';
import 'react-toastify/dist/ReactToastify.css';

// Protected Route component
function ProtectedRoute({ children }: { children: React.ReactNode }) {
  const { isAuthenticated } = useAuth();
  const location = useLocation();
  
  if (!isAuthenticated) {
    return <Navigate to="/login" state={{ from: location }} replace />;
  }

  return <React.Fragment>{children}</React.Fragment>;
}

// ✨ THÊM: Admin Protected Route component
function AdminProtectedRoute({ children }: { children: React.ReactNode }) {
  const { isAuthenticated, user } = useAuth();
  const location = useLocation();
  
  if (!isAuthenticated) {
    return <Navigate to="/login" state={{ from: location }} replace />;
  }

  if (user?.role !== 'Admin') {
    return <Navigate to="/" replace />;
  }

  return <React.Fragment>{children}</React.Fragment>;
}

// Home Route component based on user role
function HomeRoute() {
  const { user, isAuthenticated } = useAuth();

  if (!isAuthenticated) {
    return <HomePage />;
  }

  switch (user?.role) {
    case 'Member':
      return <MemberHomePage />;
    case 'Coach':
      return <HomeForCoach />;
    case 'Admin':
      return <HomeForAdmin />;
    default:
      return <HomePage />;
  }
}

function App() {
  return (
    <AuthProvider>
      <Router>
        <Navbar />
        <Routes>
          <Route path="/" element={<HomeRoute />} />
          <Route path="/login" element={<LoginPage />} />
          <Route path="/register" element={<RegisterPage />} />
          <Route path="/verify" element={<VerifyPage />} />
          <Route path="/home" element={<HomeRoute />} />
          <Route
            path="/profile"
            element={
              <ProtectedRoute>
                <ProfilePage />
              </ProtectedRoute>
            }
          />
          <Route path="/packages" element={<PackagesPage />} />
          
          {/* CONSULTATION ROUTES */}
          <Route 
            path="/consultation" 
            element={
              <ProtectedRoute>
                <ConsultationPage />
              </ProtectedRoute>
            } 
          />
          <Route 
            path="/consultation/schedule/:coachId" 
            element={
              <ProtectedRoute>
                <CoachSchedulePage />
              </ProtectedRoute>
            } 
          />
          <Route path="/consultation-history" element={<ConsultationHistoryPage />} />
          
          {/* BLOG ROUTES */}
          <Route path="/blogs" element={<BlogList />} />
          <Route
            path="/create-post"
            element={
              <ProtectedRoute>
                <CreatePostPage />
              </ProtectedRoute>
            }
          />
          <Route
            path="/my-blogs"
            element={
              <ProtectedRoute>
                <MyBlogList />
              </ProtectedRoute>
            }
          />
          <Route
            path="/my-blogs/edit/:blogId"
            element={<EditBlogPage />}
          />

          {/* COACH ROUTES */}
          <Route 
            path="/coach-schedule" 
            element={
              <ProtectedRoute>
                <CoachSchedulePageForCoach />
              </ProtectedRoute>
            } 
          />
          <Route 
            path="/coach/member/:memberId/create-plan" 
            element={
              <ProtectedRoute>
                <CreatePlanPage />
              </ProtectedRoute>
            } 
          />
          <Route 
            path="/coach/member/:memberId/create-health-profile" 
            element={
              <ProtectedRoute>
                <CreateHealthProfilePage />
              </ProtectedRoute>
            } 
          />
          <Route 
            path="/coach/member/:memberId" 
            element={
              <ProtectedRoute>
                <CoachMemberDetailPage />
              </ProtectedRoute>
            } 
          />
          <Route path="/payment" element={<PaymentPage />} />

          {/* ✨ THÊM: ADMIN ROUTES */}
          <Route 
            path="/admin/feedbacks" 
            element={
              <AdminProtectedRoute>
                <AdminFeedbackPage />
              </AdminProtectedRoute>
            } 
          />
          <Route 
            path="/admin/blogs" 
            element={
              <AdminProtectedRoute>
                <AdminBlogPage />
              </AdminProtectedRoute>
            } 
          />
          <Route 
            path="/admin/chatboxes" 
            element={
              <AdminProtectedRoute>
                <AdminChatBoxPage />
              </AdminProtectedRoute>
            } 
          />
          <Route 
            path="/admin/medals" 
            element={
              <AdminProtectedRoute>
                <AdminMedalPage />
              </AdminProtectedRoute>
            } 
          />
          <Route 
            path="/admin/members" 
            element={
              <AdminProtectedRoute>
                <AdminMemberPage />
              </AdminProtectedRoute>
            } 
          />

          {/* OTHER ROUTES */}
          <Route path="/cap-nhat-tien-do" element={<SmokingProgressForm />} />
          {/* Member health profile route */}
          <Route 
            path="/profile/health-profile" 
            element={
              <ProtectedRoute>
                <MemberHealthProfilePage />
              </ProtectedRoute>
            } 
          />
          <Route path="/profile/my-quit-plans" element={<MyQuitPlansPage />} />
          <Route 
            path="/smoking-status" 
            element={
              <ProtectedRoute>
                <SmokingStatusPage />
              </ProtectedRoute>
            } 
          />
          <Route path="/progress/plan" element={<ProgressPlanPage />} />
          
          {/* FALLBACK */}
          <Route path="*" element={<Navigate to="/" replace />} />
        </Routes>
      </Router>
      <ToastContainer position="top-center" autoClose={2500} />
    </AuthProvider>
  );
}

export default App;