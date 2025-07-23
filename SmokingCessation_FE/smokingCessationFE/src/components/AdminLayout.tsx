import React, { useState } from 'react';
import { Outlet, useLocation, useNavigate } from 'react-router-dom';
import { List, ListItem, ListItemIcon, ListItemText, Box, IconButton, Avatar } from '@mui/material';
import { Menu, ChevronLeft } from '@mui/icons-material';
import { Dashboard, Group, Forum, Article, LocalOffer, Feedback, Logout } from '@mui/icons-material';

const sidebarMenu = [
  { icon: <Dashboard />, label: 'Tổng quan', route: '/admin' },
  { icon: <Group />, label: 'Thành viên', route: '/admin/members' },
  { icon: <Forum />, label: 'Chat Box', route: '/admin/chatboxes' },
  { icon: <Article />, label: 'Blog', route: '/admin/blogs' },
  { icon: <LocalOffer />, label: 'Gói hỗ trợ', route: '/admin/packages' },
  { icon: <Feedback />, label: 'Phản hồi', route: '/admin/feedbacks' },
  { icon: <LocalOffer />, label: 'Huy chương', route: '/admin/medals' },
  { icon: <Logout />, label: 'Đăng xuất', route: '/login' },
];

export default function AdminLayout() {
  const [collapsed, setCollapsed] = useState(false);
  const location = useLocation();
  const navigate = useNavigate();

  const handleSidebarClick = (label, route) => {
    if (label === 'Đăng xuất') {
      localStorage.removeItem('authToken');
      navigate('/login');
      return;
    }
    if (label === 'Tổng quan') {
      navigate('/admin');
      return;
    }
    if (route) navigate(route);
  };

  return (
    <Box sx={{ display: 'flex', minHeight: '100vh', bgcolor: '#f4f6fb' }}>
      {/* Sidebar */}
      <Box component="aside" sx={{
        width: collapsed ? 72 : 240,
        bgcolor: '#232946',
        color: '#fff',
        minHeight: '100vh',
        display: 'flex',
        flexDirection: 'column',
        py: 3,
        px: 0,
        position: 'fixed',
        left: 0,
        top: 0,
        zIndex: 1200,
        transition: 'width 0.25s cubic-bezier(.4,0,.2,1)',
        overflowX: 'hidden'
      }}>
        <Box sx={{ display: 'flex', alignItems: 'center', justifyContent: collapsed ? 'center' : 'space-between', px: 2, mb: 2 }}>
          {!collapsed && (
            <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
              <Avatar src="/images/logo.png" sx={{ width: 40, height: 40, bgcolor: '#fff', border: '2px solid #6366f1' }} />
              <span style={{ fontWeight: 700, fontSize: 18, color: '#fff' }}>Admin</span>
            </Box>
          )}
          <IconButton onClick={() => setCollapsed(c => !c)} sx={{ color: '#fff', ml: collapsed ? 0 : 1 }}>
            {collapsed ? <Menu /> : <ChevronLeft />}
          </IconButton>
        </Box>
        <Box sx={{ overflowY: 'auto', mt: 2, overflowX: 'hidden', flex: 1 }}>
          <List>
            {sidebarMenu.map((item, idx) => {
              const isActive = item.route ? location.pathname.startsWith(item.route) : (item.label === 'Tổng quan' && location.pathname === '/admin');
              const isDashboard = item.label === 'Tổng quan' && isActive;
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
                    pl: collapsed ? 1.5 : isDashboard ? 3.5 : 2.5,
                    pr: isActive ? 4 : 2.5,
                    minHeight: isDashboard ? 64 : 56,
                    zIndex: isActive ? 2 : 1,
                    justifyContent: collapsed ? 'center' : 'flex-start',
                    '&:hover': {
                      bgcolor: '#fff',
                      color: '#232946',
                      border: item.label === 'Tổng quan' ? '2px solid #6366f1' : 'none',
                      boxShadow: item.label === 'Tổng quan'
                        ? '0 8px 32px #6366f144, 0 0 0 2px #6366f1'
                        : '0 4px 16px #6366f122',
                      pl: collapsed ? 1.5 : item.label === 'Tổng quan' ? 3.5 : 2.5,
                      minHeight: item.label === 'Tổng quan' ? 64 : 56,
                    },
                  }}
                >
                  <ListItemIcon sx={{
                    color: isActive ? '#6366f1' : '#fff',
                    minWidth: 36,
                    fontSize: isDashboard ? 32 : 26,
                    transition: 'font-size 0.2s',
                    justifyContent: 'center',
                  }}>
                    {item.icon}
                  </ListItemIcon>
                  {!collapsed && (
                    <ListItemText
                      primary={item.label}
                      sx={{
                        fontSize: isDashboard ? 20 : 18,
                        fontWeight: isActive ? 700 : 500,
                        letterSpacing: isDashboard ? 1.2 : 0
                      }}
                    />
                  )}
                  {(isActive || (item.label === 'Tổng quan' && isDashboard)) && !collapsed && (
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
      <Box sx={{ flex: 1, ml: { xs: collapsed ? 72 : 240, md: collapsed ? 72 : 240 }, transition: 'margin-left 0.25s cubic-bezier(.4,0,.2,1)' }}>
        <Outlet />
      </Box>
    </Box>
  );
} 