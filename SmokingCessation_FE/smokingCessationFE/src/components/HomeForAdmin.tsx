import React, { useState, useEffect } from 'react';
import {
  Drawer, List, ListItem, ListItemIcon, ListItemText, Box, Grid, Card, CardContent, Avatar, Button, Dialog, DialogTitle, DialogContent, DialogActions, TableContainer, Paper, Table, TableHead, TableRow, TableCell, TableBody, Snackbar, Alert
} from '@mui/material';
import { Dashboard, Group, Forum, Article, LocalOffer, BarChart, Feedback, Logout } from '@mui/icons-material';
import AdminPackagePage from './AdminPackagePage';
import Navbar from './Navbar';
import Typography from '@mui/material/Typography';
import { useAuth } from '../contexts/AuthContext';
import { useNavigate, useLocation } from 'react-router-dom';
import { getAllCoachesForAdmin, deleteCoachByAdmin, createCoachByAdmin, getAllMemberProfiles, getTodayRegisteredMembersCount, getMembersByDate } from '../api/services/userService';
import { getMonthlyPaymentTotal, getDailyPaymentTotal } from '../api/services/paymentService';
import ReactDatePicker from 'react-datepicker';
import 'react-datepicker/dist/react-datepicker.css';
import { Bar } from 'react-chartjs-2';
import {
  Chart as ChartJS,
  CategoryScale,
  LinearScale,
  BarElement,
  LineElement,
  PointElement,
  Title,
  Tooltip,
  Legend
} from 'chart.js';
ChartJS.register(CategoryScale, LinearScale, BarElement, LineElement, PointElement, Title, Tooltip, Legend);
import { DatePicker } from '@mui/x-date-pickers/DatePicker';
import { AdapterDayjs } from '@mui/x-date-pickers/AdapterDayjs';
import { LocalizationProvider } from '@mui/x-date-pickers/LocalizationProvider';
import dayjs from 'dayjs';
import { Line } from 'react-chartjs-2';
import { getTodayCommentCount, getCommentCountByDate } from '../api/services/commentService';
import { getTodayBlogCount, getBlogCountByDate } from '../api/services/blogService';
import { getFeedbackCommentCountByDate, getFeedbackCoachCountByDate, getFeedbackBlogCountByDate } from '../api/services/feedbackService';
import apiClient from '../api/apiClient';

const drawerWidth = 220;

const stats = [
  { icon: <Group fontSize="large" color="primary" />, label: 'Thành viên mới', value: 120, color: '#7c3aed' },
  { icon: <Forum fontSize="large" color="primary" />, label: 'Lượt tư vấn', value: 340, color: '#06b6d4' },
  { icon: <Article fontSize="large" color="primary" />, label: 'Bài viết Blog', value: 58, color: '#6366f1' },
  { icon: <Feedback fontSize="large" color="primary" />, label: 'Phản hồi', value: 210, color: '#f59e42' },
];

const sidebarMenu = [
  { icon: <Dashboard />, label: 'Tổng quan' },
  { icon: <Group />, label: 'Thành viên' },
  { icon: <Forum />, label: 'Chat Box', route: '/admin/chatboxes' },
  { icon: <Article />, label: 'Blog' },
  { icon: <Feedback />, label: 'Phản hồi' },
  { icon: <LocalOffer />, label: 'Huy chương', route: '/admin/medals' },
  { icon: <Logout />, label: 'Đăng xuất' },
];

const HomeForAdmin: React.FC = () => {
  const { logout } = useAuth();
  const navigate = useNavigate();
  const location = useLocation();
  const [coaches, setCoaches] = useState<any[]>([]);
  const [loadingCoaches, setLoadingCoaches] = useState(false);
  const [newCoachId, setNewCoachId] = useState('');
  const [memberDialogOpen, setMemberDialogOpen] = useState(false);
  const [memberList, setMemberList] = useState<any[]>([]);
  const [selectedMember, setSelectedMember] = useState<any>(null);
  const [memberPage, setMemberPage] = useState(0);
  const [memberTotalPages, setMemberTotalPages] = useState(1);
  const memberPageSize = 10;
  const [confirmCreateOpen, setConfirmCreateOpen] = useState(false);
  const [confirmDeleteOpen, setConfirmDeleteOpen] = useState(false);
  const [deleteCoachId, setDeleteCoachId] = useState<number|null>(null);
  const [snackbar, setSnackbar] = useState({ open: false, message: '', severity: 'success' as 'success'|'error' });
  const [searchMember, setSearchMember] = useState('');
  const [searchInput, setSearchInput] = useState('');
  const [searchMode, setSearchMode] = useState(false);
  const [searchResults, setSearchResults] = useState<any[]>([]);
  const [searchPage, setSearchPage] = useState(0);
  const searchPageSize = 10;
  const [monthlyRevenue, setMonthlyRevenue] = useState<number|null>(null);
  const [dailyRevenue, setDailyRevenue] = useState<number|null>(null);
  const [revenueLoading, setRevenueLoading] = useState(false);
  const [barData, setBarData] = useState<any>(null);
  const [barLoading, setBarLoading] = useState(false);
  const [selectedMonth, setSelectedMonth] = useState(new Date());
  const [selectedDate, setSelectedDate] = useState(new Date());
  const [barDataMonth, setBarDataMonth] = useState<any>(null);
  const [barLoadingMonth, setBarLoadingMonth] = useState(false);
  const [selectedYear, setSelectedYear] = useState(new Date());
  const [todayMemberCount, setTodayMemberCount] = useState<number|null>(null);
  const [loadingTodayMember, setLoadingTodayMember] = useState(false);
  const [selectedStatDate, setSelectedStatDate] = useState<Date | null>(new Date());
  const [membersByDate, setMembersByDate] = useState<any[]>([]);
  const [loadingMembersByDate, setLoadingMembersByDate] = useState(false);
  const [openMembersDialog, setOpenMembersDialog] = useState(false);
  const [lineData, setLineData] = useState<any>(null);
  const [lineLoading, setLineLoading] = useState(false);
  const [todayCommentCount, setTodayCommentCount] = useState<number>(0);
  const [loadingTodayComment, setLoadingTodayComment] = useState(false);
  const [commentLineData, setCommentLineData] = useState<any>(null);
  const [commentLineLoading, setCommentLineLoading] = useState(false);
  const [todayBlogCount, setTodayBlogCount] = useState<number>(0);
  const [loadingTodayBlog, setLoadingTodayBlog] = useState(false);
  const [blogLineData, setBlogLineData] = useState<number[]>([]);
  const [feedbackLineData, setFeedbackLineData] = useState<any>(null);
  const [feedbackLineLoading, setFeedbackLineLoading] = useState(false);
  const [todayFeedbackCount, setTodayFeedbackCount] = useState<number>(0);
  const [loadingTodayFeedback, setLoadingTodayFeedback] = useState(false);

  const handleSidebarClick = (label: string, route?: string) => {
    if (label === 'Đăng xuất') {
      logout();
      navigate('/login');
    }
    if (label === 'Phản hồi') {
      navigate('/admin/feedbacks');
    }
    if (label === 'Blog') {
      navigate('/admin/blogs');
    }
    if (label === 'Thành viên') {
      navigate('/admin/members');
    }
    if (label === 'Tổng quan') {
      navigate('/admin');
      return;
    }
    if (route) {
      navigate(route);
    }
    // Có thể xử lý các label khác nếu muốn chuyển trang
  };

  const handleSearch = async () => {
    // Lấy toàn bộ member (tối đa 1000)
    let allMembers: any[] = [];
    let page = 0;
    let size = 100;
    let hasMore = true;
    while (hasMore && page < 10) { // tối đa 1000 user
      const res = await getAllMemberProfiles(page, size);
      let data: any[] = [];
      if (Array.isArray(res.content)) data = res.content;
      else if (Array.isArray(res.data)) data = res.data;
      else if (Array.isArray(res)) data = res;
      allMembers = allMembers.concat(data);
      if (data.length < size) hasMore = false;
      else page++;
    }
    // Lọc
    const keyword = searchInput.trim().toLowerCase();
    const filtered = allMembers.filter(m => {
      if (m.account?.role !== 'Member') return false;
      return (
        m.account.name?.toLowerCase().includes(keyword) ||
        m.account.email?.toLowerCase().includes(keyword)
      );
    });
    setSearchResults(filtered);
    setSearchMode(true);
    setSearchMember(searchInput);
    setSearchPage(0);
  };
  const handleClearSearch = () => {
    setSearchMode(false);
    setSearchInput('');
    setSearchMember('');
    setSearchResults([]);
    setSearchPage(0);
  };

  // Thêm hàm lấy danh sách member (có thể phân trang nếu muốn)
  const fetchMembers = async (page = 0, size = memberPageSize) => {
    try {
      const res = await getAllMemberProfiles(page, size);
      if (Array.isArray(res.content)) {
        setMemberList(res.content);
        setMemberTotalPages(res.totalPages || 1);
      } else if (Array.isArray(res.data)) {
        setMemberList(res.data);
        setMemberTotalPages(res.totalPages || 1);
      } else if (Array.isArray(res)) {
        setMemberList(res);
        setMemberTotalPages(1);
      } else {
        setMemberList([]);
        setMemberTotalPages(1);
      }
    } catch {
      setMemberList([]);
      setMemberTotalPages(1);
    }
  };

  const fetchMonthlyRevenue = async () => {
    setRevenueLoading(true);
    try {
      const year = selectedMonth.getFullYear();
      const month = selectedMonth.getMonth() + 1;
      const res = await getMonthlyPaymentTotal(year, month);
      setMonthlyRevenue(res);
    } catch {
      setMonthlyRevenue(null);
    } finally {
      setRevenueLoading(false);
    }
  };
  const fetchDailyRevenue = async () => {
    setRevenueLoading(true);
    try {
      const date = selectedDate.toISOString().slice(0, 10);
      const res = await getDailyPaymentTotal(date);
      setDailyRevenue(res);
    } catch {
      setDailyRevenue(null);
    } finally {
      setRevenueLoading(false);
    }
  };

  const fetchMonthlyBarData = async () => {
    setBarLoading(true);
    try {
      const year = selectedMonth.getFullYear();
      const month = selectedMonth.getMonth() + 1;
      // Tính số ngày trong tháng
      const daysInMonth = new Date(year, month, 0).getDate();
      const labels = Array.from({ length: daysInMonth }, (_, i) => `${i + 1}`);
      const promises = labels.map(day => {
        const date = `${year}-${String(month).padStart(2, '0')}-${String(day).padStart(2, '0')}`;
        return getDailyPaymentTotal(date).catch(() => 0);
      });
      const values = await Promise.all(promises);
      setBarData({
        labels,
        datasets: [
          {
            label: 'Doanh thu (VNĐ)',
            data: values,
            backgroundColor: 'rgba(99,102,241,0.7)',
            borderRadius: 6,
          }
        ]
      });
    } catch {
      setBarData(null);
    } finally {
      setBarLoading(false);
    }
  };

  const fetchYearlyBarData = async () => {
    setBarLoadingMonth(true);
    try {
      const year = selectedYear.getFullYear();
      const labels = Array.from({ length: 12 }, (_, i) => `Tháng ${i + 1}`);
      const promises = labels.map((_, i) => getMonthlyPaymentTotal(year, i + 1).catch(() => 0));
      const values = await Promise.all(promises);
      setBarDataMonth({
        labels,
        datasets: [
          {
            label: 'Doanh thu (VNĐ)',
            data: values,
            backgroundColor: 'rgba(16,185,129,0.7)',
            borderRadius: 6,
          }
        ]
      });
    } catch {
      setBarDataMonth(null);
    } finally {
      setBarLoadingMonth(false);
    }
  };

  const handleFetchMembersByDate = async (date: Date | null) => {
    if (!date) return;
    setLoadingMembersByDate(true);
    try {
      const day = date.getDate();
      const month = date.getMonth() + 1;
      const year = date.getFullYear();
      const data = await getMembersByDate(day, month, year);
      setMembersByDate(Array.isArray(data) ? data : (data.content || data.data || []));
      setOpenMembersDialog(true);
    } catch {
      setMembersByDate([]);
      setOpenMembersDialog(true);
    } finally {
      setLoadingMembersByDate(false);
    }
  };

  // Lấy dữ liệu số lượng thành viên đăng ký từng ngày trong tháng này
  useEffect(() => {
    const fetchLineData = async () => {
      setLineLoading(true);
      try {
        const today = new Date();
        const days = [];
        for (let i = 29; i >= 0; i--) {
          const d = new Date(today);
          d.setDate(today.getDate() - i);
          days.push(d);
        }
        const labels = days.map(d => `${d.getDate().toString().padStart(2, '0')}/${(d.getMonth() + 1).toString().padStart(2, '0')}`);
        const promises = days.map(d => getMembersByDate(d.getDate(), d.getMonth() + 1, d.getFullYear()).then(data => Array.isArray(data) ? data.length : (data.content?.length || data.data?.length || 0)).catch(() => 0));
        const values = await Promise.all(promises);
        setLineData({
          labels,
          datasets: [
            {
              label: 'Số thành viên đăng ký',
              data: values,
              borderColor: '#6366f1',
              backgroundColor: 'rgba(99,102,241,0.15)',
              fill: true,
              tension: 0.3,
              pointRadius: 4,
              pointBackgroundColor: '#6366f1',
              pointBorderColor: '#fff',
              pointHoverRadius: 6,
              borderWidth: 3
            }
          ]
        });
      } catch {
        setLineData(null);
      } finally {
        setLineLoading(false);
      }
    };
    fetchLineData();
  }, []);

  useEffect(() => {
    fetchMonthlyBarData();
    // eslint-disable-next-line
  }, [selectedMonth]);
  useEffect(() => {
    fetchYearlyBarData();
    // eslint-disable-next-line
  }, [selectedYear]);

  useEffect(() => {
    setLoadingTodayMember(true);
    getTodayRegisteredMembersCount()
      .then(count => setTodayMemberCount(count))
      .catch(() => setTodayMemberCount(null))
      .finally(() => setLoadingTodayMember(false));
  }, []);

  // Lấy số bình luận hôm nay
  useEffect(() => {
    setLoadingTodayComment(true);
    getTodayCommentCount()
      .then(count => setTodayCommentCount(typeof count === 'number' ? count : (count.count || 0)))
      .catch(() => setTodayCommentCount(0))
      .finally(() => setLoadingTodayComment(false));
  }, []);

  // Lấy dữ liệu số bình luận từng ngày trong 30 ngày gần nhất
  useEffect(() => {
    const fetchCommentLineData = async () => {
      setCommentLineLoading(true);
      try {
        const today = new Date();
        const days = [];
        for (let i = 29; i >= 0; i--) {
          const d = new Date(today);
          d.setDate(today.getDate() - i);
          days.push(d);
        }
        const labels = days.map(d => `${d.getDate().toString().padStart(2, '0')}/${(d.getMonth() + 1).toString().padStart(2, '0')}`);
        const promises = days.map(d => getCommentCountByDate(d.getDate(), d.getMonth() + 1, d.getFullYear()).then(res => typeof res === 'number' ? res : (res.count || 0)).catch(() => 0));
        const values = await Promise.all(promises);
        setCommentLineData({
          labels,
          datasets: [
            {
              label: 'Số bình luận',
              data: values,
              borderColor: '#f59e42',
              backgroundColor: 'rgba(245,158,66,0.15)',
              fill: true,
              tension: 0.5,
              pointRadius: 0,
              pointHoverRadius: 0,
              borderWidth: 3
            }
          ]
        });
      } catch {
        setCommentLineData(null);
      } finally {
        setCommentLineLoading(false);
      }
    };
    fetchCommentLineData();
  }, []);

  // Lấy số blog hôm nay
  useEffect(() => {
    setLoadingTodayBlog(true);
    getTodayBlogCount()
      .then(count => setTodayBlogCount(typeof count === 'number' ? count : (count.count || 0)))
      .catch(() => setTodayBlogCount(0))
      .finally(() => setLoadingTodayBlog(false));
  }, []);

  // Lấy dữ liệu số blog từng ngày trong 30 ngày gần nhất (song song với comment)
  useEffect(() => {
    const fetchBlogLineData = async () => {
      try {
        const today = new Date();
        const days = [];
        for (let i = 29; i >= 0; i--) {
          const d = new Date(today);
          d.setDate(today.getDate() - i);
          days.push(d);
        }
        const promises = days.map(d => getBlogCountByDate(d.getDate(), d.getMonth() + 1, d.getFullYear()).then(res => typeof res === 'number' ? res : (res.count || 0)).catch(() => 0));
        const values = await Promise.all(promises);
        setBlogLineData(values);
      } catch {
        setBlogLineData([]);
      }
    };
    fetchBlogLineData();
  }, []);

  // Lấy dữ liệu số feedbacks từng ngày trong 30 ngày gần nhất
  useEffect(() => {
    const fetchFeedbackLineData = async () => {
      setFeedbackLineLoading(true);
      try {
        const today = new Date();
        const days = [];
        for (let i = 29; i >= 0; i--) {
          const d = new Date(today);
          d.setDate(today.getDate() - i);
          days.push(d);
        }
        const labels = days.map(d => `${d.getDate().toString().padStart(2, '0')}/${(d.getMonth() + 1).toString().padStart(2, '0')}`);
        const commentPromises = days.map(d => getFeedbackCommentCountByDate(d.getDate(), d.getMonth() + 1, d.getFullYear()).then(res => typeof res === 'number' ? res : (res.count || 0)).catch(() => 0));
        const coachPromises = days.map(d => getFeedbackCoachCountByDate(d.getDate(), d.getMonth() + 1, d.getFullYear()).then(res => typeof res === 'number' ? res : (res.count || 0)).catch(() => 0));
        const blogPromises = days.map(d => getFeedbackBlogCountByDate(d.getDate(), d.getMonth() + 1, d.getFullYear()).then(res => typeof res === 'number' ? res : (res.count || 0)).catch(() => 0));
        const [commentData, coachData, blogData] = await Promise.all([
          Promise.all(commentPromises),
          Promise.all(coachPromises),
          Promise.all(blogPromises)
        ]);
        setFeedbackLineData({
          labels,
          datasets: [
            {
              label: 'Feedback bình luận',
              data: commentData,
              borderColor: '#06b6d4',
              backgroundColor: 'rgba(6,182,212,0.10)',
              fill: false,
              tension: 0,
              pointRadius: 0,
              pointHoverRadius: 0,
              borderWidth: 3
            },
            {
              label: 'Feedback coach',
              data: coachData,
              borderColor: '#22c55e',
              backgroundColor: 'rgba(34,197,94,0.10)',
              fill: false,
              tension: 0,
              pointRadius: 0,
              pointHoverRadius: 0,
              borderWidth: 3
            },
            {
              label: 'Feedback blog',
              data: blogData,
              borderColor: '#a259d9',
              backgroundColor: 'rgba(162,89,217,0.10)',
              fill: false,
              tension: 0,
              pointRadius: 0,
              pointHoverRadius: 0,
              borderWidth: 3
            }
          ]
        });
      } catch {
        setFeedbackLineData(null);
      } finally {
        setFeedbackLineLoading(false);
      }
    };
    fetchFeedbackLineData();
  }, []);

  // Lấy tổng số feedbacks hôm nay (comment + coach + blog)
  useEffect(() => {
    const fetchTodayFeedback = async () => {
      setLoadingTodayFeedback(true);
      try {
        const token = localStorage.getItem('authToken') || localStorage.getItem('token');
        const [cmt, coach, blog] = await Promise.all([
          apiClient.get('/feedbacks-comment/count/today', { headers: token ? { Authorization: `Bearer ${token}` } : {} }),
          apiClient.get('/feedbacks-coach/coach/count/today', { headers: token ? { Authorization: `Bearer ${token}` } : {} }),
          apiClient.get('/feedbacks-blog/blog/count/today', { headers: token ? { Authorization: `Bearer ${token}` } : {} })
        ]);
        const sum = (typeof cmt.data === 'number' ? cmt.data : (cmt.data.count || 0)) +
                    (typeof coach.data === 'number' ? coach.data : (coach.data.count || 0)) +
                    (typeof blog.data === 'number' ? blog.data : (blog.data.count || 0));
        setTodayFeedbackCount(sum);
      } catch {
        setTodayFeedbackCount(0);
      } finally {
        setLoadingTodayFeedback(false);
      }
    };
    fetchTodayFeedback();
  }, []);

  return (
    <Box sx={{ display: 'flex', minHeight: '100vh', bgcolor: '#f4f6fb' }}>
      {/* Navbar overlay */}
      <Box sx={{
        position: 'fixed',
        top: 0,
        left: 0,
        width: '100vw',
        zIndex: 1300,
        boxShadow: 2,
        background: '#fff',
        height: 64
      }}>
        <Navbar />
      </Box>
      {/* Sidebar */}
      <Box component="aside" sx={{
        width: 240,
        bgcolor: '#232946',
        color: '#fff',
        minHeight: '100vh',
        display: 'flex',
        flexDirection: 'column',
        py: 4,
        px: 0,
        position: 'fixed',
        left: 0,
        top: 0,
        zIndex: 1200,
        overflowX: 'hidden' // Ẩn scroll ngang
      }}>
        <Box sx={{ height: 64 }} />
        <Box sx={{ overflowY: 'auto', mt: 2, overflowX: 'hidden' }}>
          <List>
            {sidebarMenu.map((item, idx) => {
              const isActive = item.route ? location.pathname.startsWith(item.route) : (item.label === 'Tổng quan' && location.pathname === '/admin');
              const isDashboard = item.label === 'Tổng quan' && (isActive);
              return (
              <ListItem
                button
                key={item.label}
                onClick={() => handleSidebarClick(item.label, item.route)}
                  sx={{
                    borderRadius: isDashboard ? '32px' : '24px',
                    mb: 1.5,
                    mx: 2,
                    position: 'relative',
                    bgcolor: isActive ? '#fff' : 'transparent',
                    color: isActive ? '#232946' : '#fff',
                    fontWeight: isActive ? 700 : 500,
                    boxShadow: isDashboard
                      ? '0 6px 24px #6366f144, 0 0 0 2px #6366f1'
                      : isActive
                        ? '0 4px 16px #6366f122'
                        : 'none',
                    border: isDashboard ? '2px solid #6366f1' : 'none',
                    transition: 'all 0.25s cubic-bezier(.4,0,.2,1)',
                    pl: isDashboard ? 3.5 : 2.5,
                    pr: isActive ? 4 : 2.5,
                    minHeight: isDashboard ? 64 : 56,
                    zIndex: isActive ? 2 : 1,
                    '&:hover': {
                      bgcolor: '#fff',
                      color: '#232946',
                      border: item.label === 'Tổng quan' ? '2px solid #6366f1' : 'none',
                      boxShadow: item.label === 'Tổng quan'
                        ? '0 8px 32px #6366f144, 0 0 0 2px #6366f1'
                        : '0 4px 16px #6366f122',
                      pl: item.label === 'Tổng quan' ? 3.5 : 2.5,
                      minHeight: item.label === 'Tổng quan' ? 64 : 56,
                    },
                  }}
                >
                  <ListItemIcon sx={{
                    color: isActive ? '#6366f1' : '#fff',
                    minWidth: 36,
                    fontSize: isDashboard ? 32 : 26,
                    transition: 'font-size 0.2s'
                  }}>
                    {item.icon}
                  </ListItemIcon>
                  <ListItemText
                    primary={item.label}
                    sx={{
                      fontSize: isDashboard ? 20 : 18,
                      fontWeight: isActive ? 700 : 500,
                      letterSpacing: isDashboard ? 1.2 : 0
                    }}
                  />
                  {(isActive || (item.label === 'Tổng quan' && isDashboard)) && (
                    <Box
                      sx={{
                        position: 'absolute',
                        right: -18,
                        top: '50%',
                        transform: 'translateY(-50%)',
                        width: 18,
                        height: isDashboard ? 56 : 48,
                        bgcolor: '#fff',
                        borderTopRightRadius: isDashboard ? 28 : 24,
                        borderBottomRightRadius: isDashboard ? 28 : 24,
                        boxShadow: '0 2px 8px #6366f122',
                        zIndex: 1,
                      }}
                    />
                  )}
              </ListItem>
              );
            })}
          </List>
        </Box>
      </Box>

      {/* Main content */}
      <Box component="main" sx={{
        flex: 1,
        ml: { xs: 0, md: '240px' },
        width: '100%',
        minHeight: '100vh',
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        bgcolor: '#f4f6fb',
        py: 5,
        px: { xs: 1, sm: 3 },
        pt: 10 // padding top để tránh bị Navbar overlay che
      }}>
        <Box sx={{
          width: '100%',
          maxWidth: 1200,
          mx: 'auto',
          display: 'flex',
          flexDirection: 'column',
          alignItems: 'stretch',
          minHeight: '100vh',
        }}>
        {/* Header */}
          <Box sx={{ width: '100%', mb: 4, display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
            <Typography variant="h4" fontWeight={900} sx={{ color: '#232946', letterSpacing: 1, fontSize: 36 }}>
            Trang quản trị hệ thống
          </Typography>
          <Box sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
            <Avatar src="/images/logo.png" sx={{ width: 48, height: 48, bgcolor: '#fff', border: '2px solid #6366f1' }} />
              <Typography variant="h6" fontWeight={700} sx={{ color: '#6366f1', fontSize: 20 }}>Xin chào, Admin!</Typography>
          </Box>
        </Box>

          {/* Dashboard cards */}
          <Box sx={{
            display: 'grid',
            gridTemplateColumns: { xs: '1fr', sm: '1fr 1fr', md: 'repeat(4, 1fr)' },
            gap: 3,
            mb: 5
          }}>
            {/* Card: Thành viên đăng ký hôm nay */}
            <Card sx={{
              borderRadius: 4,
              boxShadow: 4,
              bgcolor: '#fff',
              color: '#06b6d4',
              display: 'flex',
              flexDirection: 'column',
              alignItems: 'center',
              justifyContent: 'center',
              minHeight: 160,
              p: 3
            }}>
              <Box sx={{ mb: 1, display: 'flex', alignItems: 'center', justifyContent: 'center', width: 56, height: 56, borderRadius: '50%', background: '#e0f7fa' }}>
                <Group sx={{ fontSize: 32, color: '#06b6d4' }} />
              </Box>
              <Typography variant="h3" fontWeight={900} sx={{ color: '#06b6d4', fontSize: 36, mb: 1 }}>
                {loadingTodayMember ? '...' : (typeof todayMemberCount === 'number' ? todayMemberCount : 0)}
              </Typography>
              <Typography variant="subtitle1" sx={{ color: '#232946', fontWeight: 700, fontSize: 16, textAlign: 'center' }}>
                Thành viên đăng ký hôm nay
              </Typography>
            </Card>
            {/* Card: Số bình luận hôm nay */}
            <Card sx={{
              borderRadius: 4,
              boxShadow: 4,
              bgcolor: '#fff',
              color: '#f59e42',
                display: 'flex',
              flexDirection: 'column',
                alignItems: 'center',
                justifyContent: 'center',
              minHeight: 160,
              p: 3
            }}>
              <Box sx={{ mb: 1, display: 'flex', alignItems: 'center', justifyContent: 'center', width: 56, height: 56, borderRadius: '50%', background: '#fff7ed' }}>
                <Forum sx={{ fontSize: 32, color: '#f59e42' }} />
              </Box>
              <Typography variant="h3" fontWeight={900} sx={{ color: '#f59e42', fontSize: 36, mb: 1 }}>
                {loadingTodayComment ? '...' : todayCommentCount}
              </Typography>
              <Typography variant="subtitle1" sx={{ color: '#232946', fontWeight: 700, fontSize: 16, textAlign: 'center' }}>
                Bình luận hôm nay
              </Typography>
            </Card>
            {/* Card: Số blog hôm nay */}
            <Card sx={{
              borderRadius: 4,
              boxShadow: 4,
              bgcolor: '#fff',
              color: '#6366f1',
              display: 'flex',
              flexDirection: 'column',
              alignItems: 'center',
              justifyContent: 'center',
              minHeight: 160,
              p: 3
            }}>
              <Box sx={{ mb: 1, display: 'flex', alignItems: 'center', justifyContent: 'center', width: 56, height: 56, borderRadius: '50%', background: '#eef2ff' }}>
                <Article sx={{ fontSize: 32, color: '#6366f1' }} />
              </Box>
              <Typography variant="h3" fontWeight={900} sx={{ color: '#6366f1', fontSize: 36, mb: 1 }}>
                {loadingTodayBlog ? '...' : todayBlogCount}
              </Typography>
              <Typography variant="subtitle1" sx={{ color: '#232946', fontWeight: 700, fontSize: 16, textAlign: 'center' }}>
                Blog hôm nay
              </Typography>
            </Card>
            {/* Card: Phản hồi hôm nay */}
            <Card sx={{
              borderRadius: 4,
              boxShadow: 4,
              bgcolor: '#fff',
              color: '#f59e42',
              display: 'flex',
              flexDirection: 'column',
              alignItems: 'center',
              justifyContent: 'center',
              minHeight: 160,
              p: 3
            }}>
              <Box sx={{ mb: 1, display: 'flex', alignItems: 'center', justifyContent: 'center', width: 56, height: 56, borderRadius: '50%', background: '#fff7ed' }}>
                <Feedback sx={{ fontSize: 32, color: '#f59e42' }} />
              </Box>
              <Typography variant="h3" fontWeight={900} sx={{ color: '#f59e42', fontSize: 36, mb: 1 }}>
                {loadingTodayFeedback ? '...' : todayFeedbackCount}
              </Typography>
              <Typography variant="subtitle1" sx={{ color: '#232946', fontWeight: 700, fontSize: 16, textAlign: 'center' }}>
                Phản hồi hôm nay
              </Typography>
            </Card>
          </Box>

          {/* Charts */}
          <Box sx={{
            display: 'grid',
            gridTemplateColumns: { xs: '1fr', md: '1fr 1fr' },
            gap: 3,
            mb: 5
          }}>
            <Card sx={{ p: 4, borderRadius: 4, boxShadow: 3, bgcolor: '#fff', minHeight: 400 }}>
              <Box sx={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', mb: 2 }}>
                <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                  <BarChart sx={{ color: '#6366f1', fontSize: 28, mr: 1 }} />
                  <Typography variant="h6" fontWeight={900} sx={{ color: '#6366f1', fontSize: 22 }}>
                    Doanh thu theo ngày trong tháng
                  </Typography>
                </Box>
                <ReactDatePicker
                  selected={selectedMonth}
                  onChange={date => date && setSelectedMonth(date)}
                  dateFormat="MM/yyyy"
                  showMonthYearPicker
                  className="custom-datepicker"
                  wrapperClassName="custom-datepicker-wrapper"
                  placeholderText="Chọn tháng/năm"
                />
              </Box>
              <Box sx={{ minHeight: 300, width: '100%', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                {barLoading ? (
                  <Typography sx={{ color: '#6366f1', fontWeight: 700, fontSize: 18, textAlign: 'center', mt: 4 }}>Đang tải dữ liệu...</Typography>
                ) : barData ? (
                  <Bar
                    data={barData}
                    options={{
                      responsive: true,
                      plugins: {
                        legend: { display: false },
                        title: { display: false },
                        tooltip: {
                          enabled: true,
                          callbacks: {
                            label: ctx => `${ctx.parsed.y.toLocaleString()} VNĐ`
                          },
                          bodyFont: { size: 16, weight: 'bold' },
                          backgroundColor: '#6366f1',
                          titleColor: '#fff',
                          bodyColor: '#fff',
                          cornerRadius: 8,
                          padding: 10
                        }
                      },
                      scales: {
                        x: {
                          title: { display: true, text: 'Ngày', font: { size: 16, weight: 'bold' } },
                          grid: { display: false },
                          ticks: { font: { size: 14 } }
                        },
                        y: {
                          title: { display: true, text: 'Doanh thu (VNĐ)', font: { size: 16, weight: 'bold' } },
                          beginAtZero: true,
                          ticks: { callback: v => v.toLocaleString(), font: { size: 14 } },
                          grid: { color: '#f3f4f6' }
                        }
                      }
                    }}
                    height={300}
                    style={{ background: 'transparent' }}
                    datasetIdKey="id"
                    updateMode="resize"
                    redraw
                  />
                ) : (
                  <Typography sx={{ color: '#888', fontWeight: 600, textAlign: 'center', mt: 4 }}>Chọn tháng để xem thống kê</Typography>
                )}
              </Box>
            </Card>
            <Card sx={{ p: 4, borderRadius: 4, boxShadow: 3, bgcolor: '#fff', minHeight: 400 }}>
              <Box sx={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', mb: 2 }}>
                <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                  <BarChart sx={{ color: '#10b981', fontSize: 28, mr: 1 }} />
                  <Typography variant="h6" fontWeight={900} sx={{ color: '#10b981', fontSize: 22 }}>
                    Doanh thu theo tháng trong năm
                  </Typography>
                </Box>
                <ReactDatePicker
                  selected={selectedYear}
                  onChange={date => date && setSelectedYear(date)}
                  dateFormat="yyyy"
                  showYearPicker
                  className="custom-datepicker"
                  wrapperClassName="custom-datepicker-wrapper"
                  placeholderText="Chọn năm"
                />
              </Box>
              <Box sx={{ minHeight: 300, width: '100%', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                {barLoadingMonth ? (
                  <Typography sx={{ color: '#10b981', fontWeight: 700, fontSize: 18, textAlign: 'center', mt: 4 }}>Đang tải dữ liệu...</Typography>
                ) : barDataMonth ? (
                  <Bar
                    data={barDataMonth}
                    options={{
                      responsive: true,
                      plugins: {
                        legend: { display: false },
                        title: { display: false },
                        tooltip: {
                          enabled: true,
                          callbacks: {
                            label: ctx => `${ctx.parsed.y.toLocaleString()} VNĐ`
                          },
                          bodyFont: { size: 16, weight: 'bold' },
                          backgroundColor: '#10b981',
                          titleColor: '#fff',
                          bodyColor: '#fff',
                          cornerRadius: 8,
                          padding: 10
                        }
                      },
                      scales: {
                        x: {
                          title: { display: true, text: 'Tháng', font: { size: 16, weight: 'bold' } },
                          grid: { display: false },
                          ticks: { font: { size: 14 } }
                        },
                        y: {
                          title: { display: true, text: 'Doanh thu (VNĐ)', font: { size: 16, weight: 'bold' } },
                          beginAtZero: true,
                          ticks: { callback: v => v.toLocaleString(), font: { size: 14 } },
                          grid: { color: '#f3f4f6' }
                        }
                      }
                    }}
                    height={300}
                    style={{ background: 'transparent' }}
                    datasetIdKey="id"
                    updateMode="resize"
                    redraw
                  />
                ) : (
                  <Typography sx={{ color: '#888', fontWeight: 600, textAlign: 'center', mt: 4 }}>Chọn năm để xem thống kê</Typography>
                )}
              </Box>
            </Card>
          </Box>
          {/* Biểu đồ đường số lượng thành viên đăng ký trong tháng này */}
          <Card sx={{ p: 4, borderRadius: 4, boxShadow: 3, bgcolor: '#fff', minHeight: 400, mb: 5 }}>
            <Box sx={{ display: 'flex', alignItems: 'center', gap: 1, mb: 2 }}>
              <BarChart sx={{ color: '#6366f1', fontSize: 28, mr: 1 }} />
              <Typography variant="h6" fontWeight={900} sx={{ color: '#6366f1', fontSize: 22 }}>
                Biểu đồ thành viên đăng ký mới trong 30 ngày gần nhất
          </Typography>
              </Box>
            <Box sx={{ minHeight: 300, width: '100%', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
              {lineLoading ? (
                <Typography sx={{ color: '#6366f1', fontWeight: 700, fontSize: 18, textAlign: 'center', mt: 4 }}>Đang tải dữ liệu...</Typography>
              ) : lineData ? (
                <Line
                  data={lineData}
                  options={{
                    responsive: true,
                    plugins: {
                      legend: { display: false },
                      title: { display: false },
                      tooltip: {
                        enabled: true,
                        callbacks: {
                          label: ctx => `${ctx.parsed.y} thành viên`
                        },
                        bodyFont: { size: 16, weight: 'bold' },
                        backgroundColor: '#6366f1',
                        titleColor: '#fff',
                        bodyColor: '#fff',
                        cornerRadius: 8,
                        padding: 10
                      }
                    },
                    scales: {
                      x: {
                        title: { display: true, text: 'Ngày', font: { size: 16, weight: 'bold' } },
                        grid: { display: false },
                        ticks: { font: { size: 14 } }
                      },
                      y: {
                        title: { display: true, text: 'Số thành viên', font: { size: 16, weight: 'bold' } },
                        beginAtZero: true,
                        ticks: { font: { size: 14 } },
                        grid: { color: '#f3f4f6' }
                      }
                    }
                  }}
                  height={300}
                  style={{ background: 'transparent' }}
                />
              ) : (
                <Typography sx={{ color: '#888', fontWeight: 600, textAlign: 'center', mt: 4 }}>Không có dữ liệu</Typography>
              )}
          </Box>
          </Card>
          {/* Biểu đồ số bình luận & blog và feedbacks chia đôi màn hình */}
          <Box sx={{
            display: 'grid',
            gridTemplateColumns: { xs: '1fr', md: '1fr 1fr' },
            gap: 4,
            mb: 5
          }}>
            {/* Biểu đồ đường số lượng bình luận và blog trong 30 ngày gần nhất (multi-line) */}
            <Card sx={{ p: 4, borderRadius: 4, boxShadow: 3, bgcolor: '#fff', minHeight: 400 }}>
              <Box sx={{ display: 'flex', alignItems: 'center', gap: 1, mb: 2 }}>
                <Forum sx={{ color: '#f59e42', fontSize: 28, mr: 1 }} />
                <Article sx={{ color: '#6366f1', fontSize: 28, mr: 1 }} />
                <Typography variant="h6" fontWeight={900} sx={{ color: '#232946', fontSize: 22 }}>
                  Biểu đồ số bình luận & blog trong 30 ngày gần nhất
                </Typography>
              </Box>
              <Box sx={{ minHeight: 300, width: '100%', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                {commentLineLoading ? (
                  <Typography sx={{ color: '#f59e42', fontWeight: 700, fontSize: 18, textAlign: 'center', mt: 4 }}>Đang tải dữ liệu...</Typography>
                ) : commentLineData && blogLineData.length > 0 ? (
                  <Line
                    data={{
                      labels: commentLineData.labels,
                      datasets: [
                        {
                          label: 'Số bình luận',
                          data: commentLineData.datasets[0].data,
                          borderColor: '#f59e42',
                          backgroundColor: 'rgba(245,158,66,0.10)',
                          fill: false,
                          tension: 0,
                          pointRadius: 0,
                          pointHoverRadius: 0,
                          borderWidth: 3
                        },
                        {
                          label: 'Số blog',
                          data: blogLineData,
                          borderColor: '#6366f1',
                          backgroundColor: 'rgba(99,102,241,0.10)',
                          fill: false,
                          tension: 0,
                          pointRadius: 0,
                          pointHoverRadius: 0,
                          borderWidth: 3
                        }
                      ]
                    }}
                    options={{
                      responsive: true,
                      plugins: {
                        legend: { display: true, position: 'top', labels: { font: { size: 16, weight: 'bold' } } },
                        title: { display: false },
                        tooltip: {
                          enabled: true,
                          callbacks: {
                            label: ctx => `${ctx.dataset.label}: ${ctx.parsed.y}`
                          },
                          bodyFont: { size: 16, weight: 'bold' },
                          backgroundColor: '#232946',
                          titleColor: '#fff',
                          bodyColor: '#fff',
                          cornerRadius: 8,
                          padding: 10
                        }
                      },
                      scales: {
                        x: {
                          title: { display: true, text: 'Ngày', font: { size: 16, weight: 'bold' } },
                          grid: { display: false },
                          ticks: { font: { size: 14 } }
                        },
                        y: {
                          title: { display: true, text: 'Số lượng', font: { size: 16, weight: 'bold' } },
                          beginAtZero: true,
                          ticks: { font: { size: 14 } },
                          grid: { color: '#f3f4f6' }
                        }
                      }
                    }}
                    height={300}
                    style={{ background: 'transparent' }}
                  />
                ) : (
                  <Typography sx={{ color: '#888', fontWeight: 600, textAlign: 'center', mt: 4 }}>Không có dữ liệu</Typography>
                )}
                    </Box>
                  </Card>
            {/* Biểu đồ line multi-line feedbacks 30 ngày gần nhất */}
            <Card sx={{ p: 4, borderRadius: 4, boxShadow: 3, bgcolor: '#fff', minHeight: 400 }}>
              <Box sx={{ display: 'flex', alignItems: 'center', gap: 1, mb: 2 }}>
                <Typography variant="h6" fontWeight={900} sx={{ color: '#232946', fontSize: 22 }}>
                  Biểu đồ feedbacks (bình luận, coach, blog) trong 30 ngày gần nhất
                </Typography>
              </Box>
              <Box sx={{ minHeight: 300, width: '100%', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                {feedbackLineLoading ? (
                  <Typography sx={{ color: '#06b6d4', fontWeight: 700, fontSize: 18, textAlign: 'center', mt: 4 }}>Đang tải dữ liệu...</Typography>
                ) : feedbackLineData ? (
                  <Line
                    data={feedbackLineData}
                    options={{
                      responsive: true,
                      plugins: {
                        legend: { display: true, position: 'top', labels: { font: { size: 16, weight: 'bold' } } },
                        title: { display: false },
                        tooltip: {
                          enabled: true,
                          callbacks: {
                            label: ctx => `${ctx.dataset.label}: ${ctx.parsed.y}`
                          },
                          bodyFont: { size: 16, weight: 'bold' },
                          backgroundColor: '#232946',
                          titleColor: '#fff',
                          bodyColor: '#fff',
                          cornerRadius: 8,
                          padding: 10
                        }
                      },
                      scales: {
                        x: {
                          title: { display: true, text: 'Ngày', font: { size: 16, weight: 'bold' } },
                          grid: { display: false },
                          ticks: { font: { size: 14 } }
                        },
                        y: {
                          title: { display: true, text: 'Số feedbacks', font: { size: 16, weight: 'bold' } },
                          beginAtZero: true,
                          ticks: { font: { size: 14 } },
                          grid: { color: '#f3f4f6' }
                        }
                      }
                    }}
                    height={300}
                    style={{ background: 'transparent' }}
                  />
                ) : (
                  <Typography sx={{ color: '#888', fontWeight: 600, textAlign: 'center', mt: 4 }}>Không có dữ liệu</Typography>
                )}
              </Box>
        </Card>
          </Box>

          {/* Quản lý gói hỗ trợ */}
        <Card sx={{ width: '100%', mb: 4, p: 4, borderRadius: 4, boxShadow: 2, bgcolor: '#fff' }}>
          <Typography variant="h5" fontWeight={900} sx={{ color: '#232946', mb: 3, letterSpacing: 1, fontSize: 26 }}>
            Quản lý gói hỗ trợ
          </Typography>
          <AdminPackagePage />
        </Card>
          {/* Dialog và Snackbar */}
        <Box sx={{ width: '100%', mt: 4 }}>
          {/* Dialog xác nhận tạo coach */}
          <Dialog open={confirmCreateOpen} onClose={() => setConfirmCreateOpen(false)}>
            <DialogTitle>Xác nhận tạo coach mới?</DialogTitle>
            <DialogActions>
              <Button onClick={() => setConfirmCreateOpen(false)}>Hủy</Button>
              <Button
                onClick={async () => {
                  setConfirmCreateOpen(false);
                  if (!selectedMember) return;
                  try {
                    await createCoachByAdmin(selectedMember.id);
                    setSnackbar({ open: true, message: 'Tạo coach thành công!', severity: 'success' });
                    setSelectedMember(null);
                    setLoadingCoaches(true);
                    const data = await getAllCoachesForAdmin();
                    setCoaches(data);
                    setLoadingCoaches(false);
                  } catch (err) {
                    setSnackbar({ open: true, message: 'Tạo coach thất bại!', severity: 'error' });
                  }
                }}
                color="primary"
                variant="contained"
              >Xác nhận</Button>
            </DialogActions>
          </Dialog>
          {/* Dialog xác nhận xóa coach */}
          <Dialog open={confirmDeleteOpen} onClose={() => setConfirmDeleteOpen(false)}>
            <DialogTitle>Bạn có chắc chắn muốn xoá coach này?</DialogTitle>
            <DialogActions>
              <Button onClick={() => setConfirmDeleteOpen(false)}>Hủy</Button>
              <Button
                onClick={async () => {
                  setConfirmDeleteOpen(false);
                  if (!deleteCoachId) return;
                  try {
                    await deleteCoachByAdmin(deleteCoachId);
                    setSnackbar({ open: true, message: 'Xoá coach thành công!', severity: 'success' });
                    setLoadingCoaches(true);
                    const data = await getAllCoachesForAdmin();
                    setCoaches(data);
                    setLoadingCoaches(false);
                  } catch (err) {
                    setSnackbar({ open: true, message: 'Xoá coach thất bại!', severity: 'error' });
                  }
                }}
                color="error"
                variant="contained"
              >Xác nhận</Button>
            </DialogActions>
          </Dialog>
          <Snackbar open={snackbar.open} autoHideDuration={3000} onClose={() => setSnackbar(s => ({...s, open: false}))} anchorOrigin={{ vertical: 'top', horizontal: 'center' }}>
            <Alert onClose={() => setSnackbar(s => ({...s, open: false}))} severity={snackbar.severity} sx={{ width: '100%' }}>
              {snackbar.message}
            </Alert>
          </Snackbar>
          </Box>
        </Box>
      </Box>
    </Box>
  );
};

export default HomeForAdmin; 