import React, { useEffect, useState } from 'react';
import { getAllMemberProfiles, banAccount, unbanAccount, getAllCoachesForAdmin, createCoachByAdmin } from '../api/services/userService';
import { Paper, Table, TableBody, TableCell, TableContainer, TableHead, TableRow, Avatar, CircularProgress, Typography, Chip, Box, Button, Dialog, DialogTitle, DialogActions, TextField, DialogContent, Tabs, Tab, Snackbar, Alert, MenuItem, Select, InputLabel, FormControl } from '@mui/material';
import SearchIcon from '@mui/icons-material/Search';
import type { AlertColor } from '@mui/material';

interface MemberAccount {
  id: number;
  email: string;
  name: string;
  yearbirth: number;
  gender: string;
  role: string;
  status: string;
  image: string;
  consultations: number;
  healthCheckups: number;
}

interface MemberProfile {
  memberId: number;
  account: MemberAccount;
  startDate: string;
  motivation: string;
}

const statusColor = (status: string) => {
  switch (status) {
    case 'Active': return 'success';
    case 'Inactive': return 'default';
    case 'Banned': return 'error';
    default: return 'info';
  }
};

const getRoleLabel = (role: string) => {
  if (role === 'Member') return 'Thành viên';
  return role;
};

const getStatusLabel = (status: string) => {
  if (status === 'Active') return 'Hoạt động';
  if (status === 'Ban') return 'Ban';
  if (status === 'Pending') return 'Chờ duyệt';
  return status;
};

const AdminMemberPage: React.FC = () => {
  const [allMembers, setAllMembers] = useState<MemberProfile[]>([]);
  const [currentPage, setCurrentPage] = useState(1);
  const pageSize = 20;
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [page, setPage] = useState(0);
  const [size, setSize] = useState(10);
  const [totalPages, setTotalPages] = useState(1);
  const [banDialogOpen, setBanDialogOpen] = useState(false);
  const [banTarget, setBanTarget] = useState<MemberProfile | null>(null);
  const [unbanDialogOpen, setUnbanDialogOpen] = useState(false);
  const [unbanTarget, setUnbanTarget] = useState<MemberProfile | null>(null);
  const [searchInput, setSearchInput] = useState('');
  const [searchMode, setSearchMode] = useState(false);
  const [searchResults, setSearchResults] = useState<MemberProfile[]>([]);
  const [searchPage, setSearchPage] = useState(0);
  const searchPageSize = 20;
  const [tab, setTab] = useState<'member' | 'coach'>('member');
  const [coachList, setCoachList] = useState<any[]>([]);
  const [loadingCoach, setLoadingCoach] = useState(false);
  const [coachSearchInput, setCoachSearchInput] = useState('');
  const [coachSearchMode, setCoachSearchMode] = useState(false);
  const [coachSearchResults, setCoachSearchResults] = useState<any[]>([]);
  const [coachSearchPage, setCoachSearchPage] = useState(0);
  const coachSearchPageSize = 20;
  const [createCoachOpen, setCreateCoachOpen] = useState(false);
  const [createCoachLoading, setCreateCoachLoading] = useState(false);
  const [createCoachForm, setCreateCoachForm] = useState({ name: '', email: '', gender: '', yearbirth: '' });
  const [snackbar, setSnackbar] = useState<{ open: boolean; message: string; severity: AlertColor }>({ open: false, message: '', severity: 'success' });

  useEffect(() => {
    const fetchMembers = async () => {
      setLoading(true);
      try {

        const res = await getAllMemberProfiles(page, size);
        // Nếu backend trả về dạng { content, totalPages } hoặc { data, totalPages }
        if (Array.isArray(res.content)) {
          setAllMembers(res.content);
          setTotalPages(res.totalPages || 1);
        } else if (Array.isArray(res.data)) {
          setAllMembers(res.data);
          setTotalPages(res.totalPages || 1);
        } else if (Array.isArray(res)) {
          setAllMembers(res);
          setTotalPages(1);
        } else {
          setAllMembers([]);
          setTotalPages(1);
        }

      } catch (err: any) {
        setError('Không thể tải danh sách thành viên');
      } finally {
        setLoading(false);
      }
    };
    fetchMembers();
  }, [page, size]);

  const currentMembers = allMembers.slice((currentPage - 1) * pageSize, currentPage * pageSize);

  if (loading) return <div style={{ textAlign: 'center', marginTop: 60 }}><CircularProgress /></div>;
  if (error) return <Typography color="error" align="center" sx={{ mt: 6 }}>{error}</Typography>;

  const handleBanClick = (member: MemberProfile) => {
    setBanTarget(member);
    setBanDialogOpen(true);
  };

  const handleBanConfirm = async () => {
    if (!banTarget) return;
    try {
      await banAccount(banTarget.account.id);
      // Fetch lại danh sách từ backend
      const res = await getAllMemberProfiles(page, size);
      if (Array.isArray(res.content)) {
        setAllMembers(res.content);
        setTotalPages(res.totalPages || 1);
      } else if (Array.isArray(res.data)) {
        setAllMembers(res.data);
        setTotalPages(res.totalPages || 1);
      } else if (Array.isArray(res)) {
        setAllMembers(res);
        setTotalPages(1);
      } else {
        setAllMembers([]);
        setTotalPages(1);
      }
    } catch {
      alert('Ban thất bại!');
    } finally {
      setBanDialogOpen(false);
      setBanTarget(null);
    }
  };

  const handleBanCancel = () => {
    setBanDialogOpen(false);
    setBanTarget(null);
  };

  const handleUnbanClick = (member: MemberProfile) => {
    setUnbanTarget(member);
    setUnbanDialogOpen(true);
  };

  const handleUnbanConfirm = async () => {
    if (!unbanTarget) return;
    try {
      await unbanAccount(unbanTarget.account.id);
      setAllMembers(prev => prev.map(m => m.account.id === unbanTarget.account.id ? { ...m, account: { ...m.account, status: 'Active' } } : m));
    } catch {
      alert('Unban thất bại!');
    } finally {
      setUnbanDialogOpen(false);
      setUnbanTarget(null);
    }
  };

  const handleUnbanCancel = () => {
    setUnbanDialogOpen(false);
    setUnbanTarget(null);
  };

  const handleSearch = async () => {
    let allMembers: MemberProfile[] = [];
    let page = 0;
    let size = 100;
    let hasMore = true;
    while (hasMore && page < 10) {
      const res = await getAllMemberProfiles(page, size);
      let data: MemberProfile[] = [];
      if (Array.isArray(res.content)) data = res.content;
      else if (Array.isArray(res.data)) data = res.data;
      else if (Array.isArray(res)) data = res;
      allMembers = allMembers.concat(data);
      if (data.length < size) hasMore = false;
      else page++;
    }
    const keyword = searchInput.trim().toLowerCase();
    const filtered = allMembers.filter(m => {
      return (
        m.account.name?.toLowerCase().includes(keyword) ||
        m.account.email?.toLowerCase().includes(keyword)
      );
    });
    setSearchResults(filtered);
    setSearchMode(true);
    setSearchPage(0);
  };
  const handleClearSearch = () => {
    setSearchMode(false);
    setSearchInput('');
    setSearchResults([]);
    setSearchPage(0);
  };

  const handleShowCoaches = async () => {
    setLoadingCoach(true);
    try {
      const data = await getAllCoachesForAdmin();
      setCoachList(Array.isArray(data) ? data : (data.content || data.data || []));
    } catch {
      setCoachList([]);
    } finally {
      setLoadingCoach(false);
    }
  };

  const handleCoachSearch = () => {
    const keyword = coachSearchInput.trim().toLowerCase();
    if (!keyword) {
      setCoachSearchMode(false);
      setCoachSearchResults([]);
      setCoachSearchPage(0);
      return;
    }
    const filtered = coachList.filter(coach =>
      (coach.name?.toLowerCase().includes(keyword) || coach.email?.toLowerCase().includes(keyword))
    );
    setCoachSearchResults(filtered);
    setCoachSearchMode(true);
    setCoachSearchPage(0);
  };
  const handleCoachClearSearch = () => {
    setCoachSearchMode(false);
    setCoachSearchInput('');
    setCoachSearchResults([]);
    setCoachSearchPage(0);
  };

  const handleCreateCoach = async () => {
    setCreateCoachLoading(true);
    try {
      await createCoachByAdmin({
        name: createCoachForm.name,
        email: createCoachForm.email,
        gender: createCoachForm.gender,
        yearbirth: Number(createCoachForm.yearbirth)
      });
      setSnackbar({ open: true, message: 'Tạo coach thành công!', severity: 'success' });
      setCreateCoachOpen(false);
      setCreateCoachForm({ name: '', email: '', gender: '', yearbirth: '' });
      handleShowCoaches();
    } catch (err) {
      setSnackbar({ open: true, message: 'Tạo coach thất bại!', severity: 'error' });
    } finally {
      setCreateCoachLoading(false);
    }
  };

  return (
    <Box sx={{ maxWidth: 1300, margin: '40px auto', padding: { xs: 1, md: 4 } }}>
      <Typography variant="h4" fontWeight={900} gutterBottom textAlign="center" sx={{ mb: 4, color: '#232946' }}>
        Quản lý tài khoản
      </Typography>
      <Paper elevation={2} sx={{ mb: 3, borderRadius: 3, p: 1, bgcolor: '#fff', display: 'flex', justifyContent: 'center' }}>
        <Tabs
          value={tab}
          onChange={(_, v) => {
            setTab(v);
            if (v === 'coach' && coachList.length === 0) handleShowCoaches();
          }}
          textColor="primary"
          indicatorColor="primary"
          variant="fullWidth"
          sx={{ minHeight: 56 }}
        >
          <Tab value="member" label={<Box sx={{ fontWeight: 700, fontSize: 17 }}>Thành viên</Box>} sx={{ fontWeight: 700, fontSize: 17, minHeight: 56 }} />
          <Tab value="coach" label={<Box sx={{ fontWeight: 700, fontSize: 17 }}>Huấn luyện viên</Box>} sx={{ fontWeight: 700, fontSize: 17, minHeight: 56 }} />
        </Tabs>
      </Paper>
      {tab === 'member' && (
        <>
          <Box sx={{ mb: 2, display: 'flex', gap: 2, alignItems: 'center' }}>
            <Box sx={{
              display: 'flex', alignItems: 'center', flex: 1, bgcolor: '#fff', borderRadius: 8, boxShadow: '0 2px 8px #0001', px: 2, py: 0.5
            }}>
              <SearchIcon sx={{ color: '#6366f1', mr: 1 }} />
              <TextField
                placeholder="Tìm theo tên hoặc email..."
                value={searchInput}
                onChange={e => setSearchInput(e.target.value)}
                onKeyDown={e => { if (e.key === 'Enter') handleSearch(); }}
                size="small"
                variant="standard"
                InputProps={{ disableUnderline: true, style: { fontSize: 17, background: 'transparent' } }}
                sx={{ flex: 1, bgcolor: 'transparent', border: 'none' }}
              />
            </Box>
            <Button
              variant="contained"
              onClick={handleSearch}
              sx={{
                background: 'linear-gradient(90deg,#6366f1,#06b6d4)',
                color: '#fff',
                fontWeight: 700,
                borderRadius: 8,
                px: 3,
                boxShadow: '0 2px 8px #6366f122',
                fontSize: 16,
                '&:hover': { background: 'linear-gradient(90deg,#6366f1,#2563eb)' }
              }}
            >Tìm kiếm</Button>
            {searchMode && <Button variant="outlined" color="error" onClick={handleClearSearch} sx={{ borderRadius: 8, fontWeight: 600, fontSize: 15, px: 2, py: 0.5, minWidth: 0 }}>Xóa</Button>}
          </Box>
          <TableContainer component={Paper} sx={{ borderRadius: 4, boxShadow: 3, mt: 2, width: '100%', maxWidth: '100%', overflowX: 'hidden' }}>
            <Table sx={{ width: '100%', tableLayout: 'auto', fontSize: 16 }}>
              <TableHead>
                <TableRow sx={{ background: 'linear-gradient(90deg, #6366f1 0%, #06b6d4 100%)', borderTopLeftRadius: 16, borderTopRightRadius: 16 }}>
                  <TableCell sx={{ color: '#fff', fontWeight: 700, fontSize: 16, textAlign: 'center', borderTopLeftRadius: 16 }}>Avatar</TableCell>
                  <TableCell sx={{ color: '#fff', fontWeight: 700, fontSize: 16 }}>Họ tên</TableCell>
                  <TableCell sx={{ color: '#fff', fontWeight: 700, fontSize: 16 }}>Email</TableCell>
                  <TableCell sx={{ color: '#fff', fontWeight: 700, fontSize: 16, textAlign: 'center' }}>Năm sinh</TableCell>
                  <TableCell sx={{ color: '#fff', fontWeight: 700, fontSize: 16, textAlign: 'center' }}>Giới tính</TableCell>
                  <TableCell sx={{ color: '#fff', fontWeight: 700, fontSize: 16, textAlign: 'center' }}>Vai trò</TableCell>
                  <TableCell sx={{ color: '#fff', fontWeight: 700, fontSize: 16, textAlign: 'center' }}>Trạng thái</TableCell>
                  <TableCell sx={{ color: '#fff', fontWeight: 700, fontSize: 16, textAlign: 'center' }}>Tư vấn</TableCell>
                  <TableCell sx={{ color: '#fff', fontWeight: 700, fontSize: 16, textAlign: 'center' }}>Khám sức khỏe</TableCell>
                  <TableCell sx={{ color: '#fff', fontWeight: 700, fontSize: 16, textAlign: 'center' }}>Ngày bắt đầu</TableCell>
                  <TableCell sx={{ color: '#fff', fontWeight: 700, fontSize: 16 }}>Động lực</TableCell>
                  <TableCell sx={{ color: '#fff', fontWeight: 700, fontSize: 16, textAlign: 'center', borderTopRightRadius: 16 }}>Ban</TableCell>
                </TableRow>
              </TableHead>
              <TableBody>
                {(searchMode
                  ? searchResults.slice(searchPage * searchPageSize, (searchPage + 1) * searchPageSize)
                  : currentMembers
                ).filter(member => member.account.role !== 'Admin').map(member => (
                  <TableRow
                    key={member.memberId}
                    sx={{
                      '&:hover': { background: 'rgba(99,102,241,0.08)' },
                      transition: 'background 0.2s',
                      borderBottom: '1.5px solid #e0e7ff',
                      fontSize: 16
                    }}
                  >
                    <TableCell align="center">
                      <Avatar
                        src={member.account.image}
                        alt={member.account.name}
                        sx={{ width: 56, height: 56, margin: '0 auto', border: '2.5px solid #6366f1', fontSize: 22, bgcolor: '#f3f4f6' }}
                      />
                    </TableCell>
                    <TableCell sx={{ fontWeight: 700, color: '#232946', fontSize: 17, whiteSpace: 'normal', wordBreak: 'break-word' }}>{member.account.name}</TableCell>
                    <TableCell sx={{ fontSize: 16, whiteSpace: 'normal', wordBreak: 'break-word' }}>{member.account.email}</TableCell>
                    <TableCell align="center" sx={{ fontSize: 16 }}>{member.account.yearbirth}</TableCell>
                    <TableCell align="center" sx={{ fontSize: 16 }}>{member.account.gender}</TableCell>
                    <TableCell align="center">
                      <Chip label={getRoleLabel(member.account.role)} sx={{ fontWeight: 700, fontSize: 15, borderRadius: 2, bgcolor: '#2563eb', color: '#fff', px: 1.5 }} />
                    </TableCell>
                    <TableCell align="center">
                      <Chip
                        label={getStatusLabel(member.account.status)}
                        sx={{
                          fontWeight: 700,
                          fontSize: 15,
                          borderRadius: 2,
                          bgcolor:
                            member.account.status === 'Ban'
                              ? '#ef4444'
                              : member.account.status === 'Pending'
                              ? '#fbbf24'
                              : '#22c55e',
                          color: '#fff',
                          px: 1.5,
                        }}
                      />
                    </TableCell>
                    <TableCell align="center" sx={{ fontSize: 16 }}>{member.account.consultations}</TableCell>
                    <TableCell align="center" sx={{ fontSize: 16 }}>{member.account.healthCheckups}</TableCell>
                    <TableCell align="center" sx={{ fontSize: 16 }}>{member.startDate}</TableCell>
                    <TableCell sx={{ fontSize: 16, whiteSpace: 'normal', wordBreak: 'break-word' }}>{member.motivation}</TableCell>
                    <TableCell align="center">
                      {member.account.status === 'Ban' ? (
                        <Button
                          variant="outlined"
                          color="success"
                          size="small"
                          sx={{ borderRadius: 8, fontWeight: 700, px: 2, py: 0.5, minWidth: 0 }}
                          onClick={() => handleUnbanClick(member)}
                        >
                          Unban
                        </Button>
                      ) : (
                        <Button
                          variant="outlined"
                          color="error"
                          size="small"
                          sx={{ borderRadius: 8, fontWeight: 700, px: 2, py: 0.5, minWidth: 0 }}
                          onClick={() => handleBanClick(member)}
                          disabled={member.account.status === 'Ban'}
                        >
                          Ban
                        </Button>
                      )}
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          </TableContainer>
          <Box sx={{ display: 'flex', justifyContent: 'center', alignItems: 'center', mt: 3, gap: 2 }}>
            {searchMode ? (
              <>
                <Button variant="outlined" disabled={searchPage === 0} onClick={() => setSearchPage(searchPage - 1)}>Trang trước</Button>
                <span>Trang {searchPage + 1} / {Math.max(1, Math.ceil(searchResults.length / searchPageSize))}</span>
                <Button variant="outlined" disabled={searchPage + 1 >= Math.ceil(searchResults.length / searchPageSize)} onClick={() => setSearchPage(searchPage + 1)}>Trang sau</Button>
              </>
            ) : (
              <>
                <Button variant="outlined" disabled={page === 0} onClick={() => setPage(page - 1)}>Trang trước</Button>
                <span>Trang {page + 1} / {totalPages}</span>
                <Button variant="outlined" disabled={page + 1 >= totalPages} onClick={() => setPage(page + 1)}>Trang sau</Button>
              </>
            )}
          </Box>
        </>
      )}
      {tab === 'coach' && (
        <>
          <Box sx={{ mb: 2, display: 'flex', gap: 2, alignItems: 'center' }}>
            <Button
              variant="contained"
              color="primary"
              sx={{ fontWeight: 700, borderRadius: 3, px: 3, py: 1, background: 'linear-gradient(90deg,#6366f1,#06b6d4)', '&:hover': { background: 'linear-gradient(90deg,#6366f1,#2563eb)' } }}
              onClick={() => setCreateCoachOpen(true)}
            >
              Tạo Coach mới
            </Button>
            <Box sx={{
              display: 'flex', alignItems: 'center', flex: 1, bgcolor: '#fff', borderRadius: 8, boxShadow: '0 2px 8px #0001', px: 2, py: 0.5
            }}>
              <SearchIcon sx={{ color: '#6366f1', mr: 1 }} />
              <TextField
                placeholder="Tìm theo tên hoặc email..."
                value={coachSearchInput}
                onChange={e => setCoachSearchInput(e.target.value)}
                onKeyDown={e => { if (e.key === 'Enter') handleCoachSearch(); }}
                size="small"
                variant="standard"
                InputProps={{ disableUnderline: true, style: { fontSize: 17, background: 'transparent' } }}
                sx={{ flex: 1, bgcolor: 'transparent', border: 'none' }}
              />
            </Box>
            <Button
              variant="contained"
              onClick={handleCoachSearch}
              sx={{
                background: 'linear-gradient(90deg,#6366f1,#06b6d4)',
                color: '#fff',
                fontWeight: 700,
                borderRadius: 8,
                px: 3,
                boxShadow: '0 2px 8px #6366f122',
                fontSize: 16,
                '&:hover': { background: 'linear-gradient(90deg,#6366f1,#2563eb)' }
              }}
            >Tìm kiếm</Button>
            {coachSearchMode && <Button variant="outlined" color="error" onClick={handleCoachClearSearch} sx={{ borderRadius: 8, fontWeight: 600, fontSize: 15, px: 2, py: 0.5, minWidth: 0 }}>Xóa</Button>}
          </Box>
          {loadingCoach ? (
            <Typography align="center" sx={{ my: 4 }}>Đang tải...</Typography>
          ) : (
            <TableContainer component={Paper} sx={{ borderRadius: 4, boxShadow: 3, mt: 2, width: '100%', maxWidth: '100%', overflowX: 'hidden' }}>
              <Table sx={{ width: '100%', tableLayout: 'auto', fontSize: 16 }}>
                <TableHead>
                  <TableRow sx={{ background: 'linear-gradient(90deg, #6366f1 0%, #06b6d4 100%)', borderTopLeftRadius: 16, borderTopRightRadius: 16 }}>
                    <TableCell sx={{ color: '#fff', fontWeight: 700, fontSize: 16, textAlign: 'center', borderTopLeftRadius: 16 }}>Avatar</TableCell>
                    <TableCell sx={{ color: '#fff', fontWeight: 700, fontSize: 16 }}>Họ tên</TableCell>
                    <TableCell sx={{ color: '#fff', fontWeight: 700, fontSize: 16 }}>Email</TableCell>
                    <TableCell sx={{ color: '#fff', fontWeight: 700, fontSize: 16, textAlign: 'center' }}>Giới tính</TableCell>
                    <TableCell sx={{ color: '#fff', fontWeight: 700, fontSize: 16, textAlign: 'center' }}>Trạng thái</TableCell>
                    <TableCell sx={{ color: '#fff', fontWeight: 700, fontSize: 16, textAlign: 'center', borderTopRightRadius: 16 }}>Ban</TableCell>
                  </TableRow>
                </TableHead>
                <TableBody>
                  {(coachSearchMode
                    ? coachSearchResults.slice(coachSearchPage * coachSearchPageSize, (coachSearchPage + 1) * coachSearchPageSize)
                    : coachList
                  ).map(coach => (
                    <TableRow
                      key={coach.id}
                      sx={{
                        '&:hover': { background: 'rgba(99,102,241,0.08)' },
                        transition: 'background 0.2s',
                        borderBottom: '1.5px solid #e0e7ff',
                        fontSize: 16
                      }}
                    >
                      <TableCell align="center">
                        <Avatar
                          src={coach.image || '/images/default-avatar.png'}
                          alt={coach.name}
                          sx={{ width: 56, height: 56, margin: '0 auto', border: '2.5px solid #6366f1', fontSize: 22, bgcolor: '#f3f4f6' }}
                        />
                      </TableCell>
                      <TableCell sx={{ fontWeight: 700, color: '#232946', fontSize: 17, whiteSpace: 'normal', wordBreak: 'break-word' }}>{coach.name}</TableCell>
                      <TableCell sx={{ fontSize: 16, whiteSpace: 'normal', wordBreak: 'break-word' }}>{coach.email}</TableCell>
                      <TableCell align="center" sx={{ fontSize: 16 }}>{coach.gender}</TableCell>
                      <TableCell align="center">
                        <Chip
                          label={getStatusLabel(coach.status)}
                          sx={{
                            fontWeight: 700,
                            fontSize: 15,
                            borderRadius: 2,
                            bgcolor:
                              coach.status === 'Ban'
                                ? '#ef4444'
                                : coach.status === 'Pending'
                                ? '#fbbf24'
                                : '#22c55e',
                            color: '#fff',
                            px: 1.5,
                          }}
                        />
                      </TableCell>
                      <TableCell align="center">
                        {coach.status === 'Ban' ? (
                          <Button
                            variant="outlined"
                            color="success"
                            size="small"
                            sx={{ borderRadius: 8, fontWeight: 700, px: 2, py: 0.5, minWidth: 0 }}
                            onClick={async () => {
                              await unbanAccount(coach.id);
                              handleShowCoaches();
                            }}
                          >Unban</Button>
                        ) : (
                          <Button
                            variant="outlined"
                            color="error"
                            size="small"
                            sx={{ borderRadius: 8, fontWeight: 700, px: 2, py: 0.5, minWidth: 0 }}
                            onClick={async () => {
                              await banAccount(coach.id);
                              handleShowCoaches();
                            }}
                            disabled={coach.status === 'Ban'}
                          >Ban</Button>
                        )}
                      </TableCell>
                    </TableRow>
                  ))}
                </TableBody>
              </Table>
            </TableContainer>
          )}
          <Box sx={{ display: 'flex', justifyContent: 'center', alignItems: 'center', mt: 3, gap: 2 }}>
            {coachSearchMode ? (
              <>
                <Button variant="outlined" disabled={coachSearchPage === 0} onClick={() => setCoachSearchPage(coachSearchPage - 1)}>Trang trước</Button>
                <span>Trang {coachSearchPage + 1} / {Math.max(1, Math.ceil(coachSearchResults.length / coachSearchPageSize))}</span>
                <Button variant="outlined" disabled={coachSearchPage + 1 >= Math.ceil(coachSearchResults.length / coachSearchPageSize)} onClick={() => setCoachSearchPage(coachSearchPage + 1)}>Trang sau</Button>
              </>
            ) : null}
          </Box>
        </>
      )}
      <Dialog open={banDialogOpen} onClose={handleBanCancel}>
        <DialogTitle>Bạn có chắc chắn muốn ban tài khoản này?</DialogTitle>
        <DialogActions>
          <Button onClick={handleBanCancel}>Hủy</Button>
          <Button onClick={handleBanConfirm} color="error" variant="contained">Ban</Button>
        </DialogActions>
      </Dialog>
      <Dialog open={unbanDialogOpen} onClose={handleUnbanCancel}>
        <DialogTitle>Bạn có chắc chắn muốn mở ban tài khoản này?</DialogTitle>
        <DialogActions>
          <Button onClick={handleUnbanCancel}>Hủy</Button>
          <Button onClick={handleUnbanConfirm} color="success" variant="contained">Unban</Button>
        </DialogActions>
      </Dialog>
      <Dialog open={createCoachOpen} onClose={() => setCreateCoachOpen(false)} maxWidth="xs" fullWidth>
        <DialogTitle>Tạo Coach mới</DialogTitle>
        <DialogContent dividers>
          <Box sx={{ display: 'flex', flexDirection: 'column', gap: 2, mt: 1 }}>
            <TextField
              label="Họ tên"
              value={createCoachForm.name}
              onChange={e => setCreateCoachForm(f => ({ ...f, name: e.target.value }))}
              fullWidth
              required
            />
            <TextField
              label="Email"
              value={createCoachForm.email}
              onChange={e => setCreateCoachForm(f => ({ ...f, email: e.target.value }))}
              fullWidth
              required
              type="email"
            />
            <FormControl fullWidth required>
              <InputLabel>Giới tính</InputLabel>
              <Select
                value={createCoachForm.gender}
                label="Giới tính"
                onChange={e => setCreateCoachForm(f => ({ ...f, gender: e.target.value }))}
              >
                <MenuItem value="Nam">Nam</MenuItem>
                <MenuItem value="Nữ">Nữ</MenuItem>
                <MenuItem value="Khác">Khác</MenuItem>
              </Select>
            </FormControl>
            <TextField
              label="Năm sinh"
              value={createCoachForm.yearbirth}
              onChange={e => setCreateCoachForm(f => ({ ...f, yearbirth: e.target.value.replace(/[^0-9]/g, '') }))}
              fullWidth
              required
              inputProps={{ maxLength: 4 }}
            />
          </Box>
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setCreateCoachOpen(false)} disabled={createCoachLoading}>Hủy</Button>
          <Button onClick={handleCreateCoach} color="primary" variant="contained" disabled={createCoachLoading || !createCoachForm.name || !createCoachForm.email || !createCoachForm.gender || !createCoachForm.yearbirth}>
            {createCoachLoading ? 'Đang tạo...' : 'Tạo'}
          </Button>
        </DialogActions>
      </Dialog>
      <Snackbar open={snackbar.open} autoHideDuration={3000} onClose={() => setSnackbar(s => ({...s, open: false}))} anchorOrigin={{ vertical: 'top', horizontal: 'center' }}>
        <Alert onClose={() => setSnackbar(s => ({...s, open: false}))} severity={snackbar.severity} sx={{ width: '100%' }}>
          {snackbar.message}
        </Alert>
      </Snackbar>
    </Box>
  );
};

export default AdminMemberPage; 