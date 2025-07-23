import React, { useEffect, useState } from 'react';
import { Table, TableBody, TableCell, TableContainer, TableHead, TableRow, Paper, Button, Dialog, DialogTitle, DialogActions, DialogContent, TextField, Avatar, IconButton, Box } from '@mui/material';
import { getAllUserMedalsAdmin, getAllMedals, createMedal, updateMedal, deleteMedal } from '../api/services/medalService';
import { toast } from 'react-toastify';
import DeleteIcon from '@mui/icons-material/Delete';
import EditIcon from '@mui/icons-material/Edit';
import EmojiEventsIcon from '@mui/icons-material/EmojiEvents';

interface Medal {
  id: number;
  name: string;
  description: string;
  image?: string;
}

const AdminMedalPage: React.FC = () => {
  const [userMedals, setUserMedals] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [openDialog, setOpenDialog] = useState(false);
  const [editingMedal, setEditingMedal] = useState<Medal | null>(null);
  const [form, setForm] = useState({ name: '', description: '', type: '', image: '' });
  const [imageFile, setImageFile] = useState<File | null>(null);
  const [deleteId, setDeleteId] = useState<number | null>(null);
  const [deleteDialog, setDeleteDialog] = useState(false);
  const [medalTypes, setMedalTypes] = useState<any[]>([]);
  // 1. Thêm state lưu id huy chương cần xóa
  const [deleteMedalId, setDeleteMedalId] = useState<number | null>(null);
  const [deleteDialogOpen, setDeleteDialogOpen] = useState(false);

  useEffect(() => {
    const fetchUserMedals = async () => {
      setLoading(true);
      try {
        const data = await getAllUserMedalsAdmin();
        setUserMedals(data);
      } catch (err) {
        toast.error('Không thể tải danh sách huy chương!');
      } finally {
        setLoading(false);
      }
    };
    fetchUserMedals();
    // Lấy tất cả loại medal
    getAllMedals().then(setMedalTypes).catch(() => setMedalTypes([]));
  }, []);

  const handleOpenDialog = (medal?: Medal) => {
    if (medal) {
      setEditingMedal(medal);
      setForm({
        name: medal.name,
        description: medal.description,
        type: (medal as any).type || '',
        image: medal.image || '',
      });
    } else {
      setEditingMedal(null);
      setForm({ name: '', description: '', type: '', image: '' });
    }
    setOpenDialog(true);
  };

  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (file) {
      setImageFile(file);
      setForm(f => ({ ...f, image: URL.createObjectURL(file) }));
    }
  };

  // 1. Sửa handleSave để phân biệt tạo mới và chỉnh sửa
  const handleSave = async () => {
    try {
      const formData = new FormData();
      formData.append('name', form.name);
      formData.append('description', form.description);
      formData.append('type', form.type);
      if (imageFile) {
        formData.append('image', imageFile);
      }
      if (editingMedal) {
        await updateMedal(editingMedal.id || editingMedal.medalID, formData);
        toast.success('Cập nhật huy chương thành công!');
        // Cập nhật lại danh sách
        const data = await getAllMedals();
        setMedalTypes(data);
      } else {
        await createMedal(formData);
        toast.success('Tạo huy chương mới thành công!');
        const data = await getAllMedals();
        setMedalTypes(data);
      }
      setOpenDialog(false);
      setImageFile(null);
    } catch (err) {
      toast.error('Lưu huy chương thất bại!');
    }
  };

  const handleDelete = async () => {
    if (!deleteId) return;
    try {
      // await deleteMedal(deleteId); // This line was removed as per the new_code
      toast.success('Xóa huy chương thành công!');
      setDeleteDialog(false);
      // fetchMedals(); // This line was removed as per the new_code
    } catch (err) {
      toast.error('Xóa huy chương thất bại!');
    }
  };

  // 2. Hàm mở dialog xóa
  const handleOpenDeleteDialog = (id: number) => {
    setDeleteMedalId(id);
    setDeleteDialogOpen(true);
  };
  // 3. Hàm xác nhận xóa
  const handleConfirmDelete = async () => {
    if (!deleteMedalId) return;
    try {
      const res = await deleteMedal(deleteMedalId);
      console.log('Medal deleted successfully:', res);
      toast.success('Xóa huy chương thành công!');
      const data = await getAllMedals();
      setMedalTypes(data);
    } catch (err) {
      console.error('Delete medal failed in component:', err);
      toast.error('Xóa huy chương thất bại!');
    } finally {
      setDeleteDialogOpen(false);
      setDeleteMedalId(null);
      // Đảm bảo focus không nằm trong dialog đã đóng
      setTimeout(() => {
        const btn = document.querySelector('button[aria-label="+ Tạo loại huy chương mới"]') as HTMLButtonElement;
        if (btn) btn.focus();
      }, 0);
    }
  };
  // 4. Hàm đóng dialog
  const handleCloseDeleteDialog = () => {
    setDeleteDialogOpen(false);
    setDeleteMedalId(null);
  };

  return (
    <div style={{
      maxWidth: 1500,
      margin: '40px auto',
      background: 'linear-gradient(135deg, #f8fafb 60%, #e0e7ff 100%)',
      minHeight: '100vh',
      padding: '40px 0',
      borderRadius: 32,
      boxShadow: '0 8px 32px #b6c7e633',
      position: 'relative',
      fontFamily: 'Segoe UI, Arial, sans-serif',
    }}>
      <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', width: '100%', marginBottom: 32 }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 16, marginBottom: 8 }}>
          <EmojiEventsIcon sx={{ fontSize: 54, color: '#4f8cff', filter: 'drop-shadow(0 2px 8px #b6c7e6)' }} />
          <h2
            style={{
              fontSize: 44,
              fontWeight: 900,
              margin: 0,
              color: 'transparent',
              background: 'linear-gradient(90deg, #4f8cff 0%, #a259d9 100%)',
              WebkitBackgroundClip: 'text',
              backgroundClip: 'text',
              textAlign: 'center',
              letterSpacing: 1.5,
              lineHeight: 1.1,
              textShadow: '0 2px 12px #b6c7e6',
              display: 'inline-block',
            }}
          >
            Quản lý Huy chương
          </h2>
        </div>
        <Button
          variant="contained"
          color="primary"
          style={{
            margin: '0 auto',
            height: 50,
            minWidth: 240,
            fontWeight: 800,
            fontSize: 18,
            borderRadius: 99,
            boxShadow: '0 2px 12px #b6c7e6',
            background: 'linear-gradient(90deg, #4f8cff 0%, #a259d9 100%)',
            textTransform: 'uppercase',
            letterSpacing: 1,
            transition: 'all 0.2s',
          }}
          onMouseOver={e => (e.currentTarget.style.background = 'linear-gradient(90deg, #a259d9 0%, #4f8cff 100%)')}
          onMouseOut={e => (e.currentTarget.style.background = 'linear-gradient(90deg, #4f8cff 0%, #a259d9 100%)')}
          onClick={() => handleOpenDialog()}
        >
          + Tạo loại huy chương mới
        </Button>
      </div>
      {/* Hiển thị các loại huy chương */}
      <div style={{ maxWidth: 1350, margin: '0 auto 48px auto', padding: '32px 0' }}>
        <h3 style={{
          fontSize: 30,
          fontWeight: 900,
          color: 'transparent',
          background: 'linear-gradient(90deg, #4f8cff 0%, #a259d9 100%)',
          WebkitBackgroundClip: 'text',
          backgroundClip: 'text',
          marginBottom: 32,
          textAlign: 'center',
          letterSpacing: 1.5,
          textShadow: '0 2px 8px #b6c7e6',
        }}>Các loại huy chương</h3>
        <div style={{
          display: 'grid',
          gridTemplateColumns: 'repeat(auto-fit, minmax(340px, 1fr))',
          gap: 44,
          justifyItems: 'center',
          alignItems: 'stretch',
        }}>
          {medalTypes.map((medal: any, idx: number) => {
            let typeColor = '#4f8cff';
            if (medal.type?.toLowerCase().includes('vàng')) typeColor = '#FFD700';
            else if (medal.type?.toLowerCase().includes('bạc')) typeColor = '#B0C4DE';
            else if (medal.type?.toLowerCase().includes('đồng')) typeColor = '#CD7F32';
            return (
              <div
                key={medal.medalID || medal.id}
                style={{
                  background: '#fff',
                  borderRadius: 28,
                  boxShadow: '0 2px 16px #b6c7e655',
                  padding: 38,
                  display: 'flex',
                  flexDirection: 'column',
                  alignItems: 'center',
                  minHeight: 320,
                  width: 340,
                  transition: 'transform 0.16s cubic-bezier(.4,2,.6,1), box-shadow 0.16s, border 0.16s',
                  border: '2.5px solid #e3eafc',
                  cursor: 'pointer',
                  animation: `fadeInUp 0.38s ${0.04 * idx}s both`,
                }}
                onMouseOver={e => {
                  (e.currentTarget as HTMLDivElement).style.transform = 'scale(1.035)';
                  (e.currentTarget as HTMLDivElement).style.boxShadow = '0 8px 32px #4f8cff55';
                  (e.currentTarget as HTMLDivElement).style.border = '2.5px solid #4f8cff';
                }}
                onMouseOut={e => {
                  (e.currentTarget as HTMLDivElement).style.transform = 'scale(1)';
                  (e.currentTarget as HTMLDivElement).style.boxShadow = '0 2px 16px #b6c7e655';
                  (e.currentTarget as HTMLDivElement).style.border = '2.5px solid #e3eafc';
                }}
              >
                <img src={medal.image} alt={medal.name} style={{ width: 100, height: 100, objectFit: 'cover', borderRadius: 20, marginBottom: 18, border: '3px solid #e3eafc', background: '#f3f4f6', boxShadow: '0 2px 8px #b6c7e6' }} />
                <div style={{ fontWeight: 900, fontSize: 24, color: '#232946', marginBottom: 7, textAlign: 'center', letterSpacing: 0.5 }}>{medal.name}</div>
                <div style={{ color: typeColor, fontWeight: 800, fontSize: 17, marginBottom: 10, textAlign: 'center', letterSpacing: 0.5 }}>{medal.type}</div>
                <div style={{ color: '#64748b', fontSize: 15, textAlign: 'center', minHeight: 32, fontWeight: 500 }}>{medal.description}</div>
                <Button
                  variant="outlined"
                  color="primary"
                  startIcon={<EditIcon />}
                  style={{ marginTop: 16, borderRadius: 8, fontWeight: 700, fontSize: 16, marginRight: 12 }}
                  onClick={() => handleOpenDialog(medal)}
                >
                  Chỉnh sửa
                </Button>
                <Button
                  variant="contained"
                  color="error"
                  startIcon={<DeleteIcon />}
                  style={{ marginTop: 16, borderRadius: 8, fontWeight: 700, fontSize: 16 }}
                  onClick={() => handleOpenDeleteDialog(medal.medalID || medal.id)}
                  onMouseOver={e => (e.currentTarget.style.background = '#d32f2f')}
                  onMouseOut={e => (e.currentTarget.style.background = '')}
                >
                  Xóa
                </Button>
              </div>
            );
          })}
        </div>
        <style>{`
          @keyframes fadeInUp {
            from { opacity: 0; transform: translateY(32px) scale(0.98); }
            to { opacity: 1; transform: none; }
          }
        `}</style>
      </div>
      <TableContainer component={Paper} sx={{ maxWidth: 1350, margin: '0 auto' }}>
        <Table sx={{ width: '100%', tableLayout: 'fixed' }}>
          <TableHead>
            <TableRow sx={{ background: 'linear-gradient(90deg, #f3e8ff 0%, #f8fafc 100%)' }}>
              <TableCell style={{ fontWeight: 800, fontSize: 18 }}>STT</TableCell>
              <TableCell style={{ fontWeight: 800, fontSize: 18 }}>Hình huy chương</TableCell>
              <TableCell style={{ fontWeight: 800, fontSize: 18 }}>Tên huy chương</TableCell>
              <TableCell style={{ fontWeight: 800, fontSize: 18 }}>Loại</TableCell>
              <TableCell style={{ fontWeight: 800, fontSize: 18 }}>Mô tả</TableCell>
              <TableCell style={{ fontWeight: 800, fontSize: 18 }}>Ngày nhận</TableCell>
              <TableCell style={{ fontWeight: 800, fontSize: 18, minWidth: 160 }}>Thông tin user</TableCell>
              <TableCell style={{ fontWeight: 800, fontSize: 18, minWidth: 180 }}>Email</TableCell>
              <TableCell style={{ fontWeight: 800, fontSize: 18 }}>Mô tả nhận</TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {userMedals.map((item, idx) => (
              <TableRow key={item.userMedalID || idx}>
                <TableCell>{idx + 1}</TableCell>
                <TableCell>
                  <Avatar src={item.medal?.image} alt={item.medal?.name} sx={{ width: 54, height: 54, border: '2.5px solid #e0e0e0', boxShadow: '0 2px 8px rgba(44,62,80,0.10)' }} />
                </TableCell>
                <TableCell sx={{ fontWeight: 700, fontSize: 18, color: '#232946' }}>{item.medal?.name}</TableCell>
                <TableCell>{item.medal?.type}</TableCell>
                <TableCell>{item.medal?.description}</TableCell>
                <TableCell>{item.createdDate}</TableCell>
                <TableCell sx={{ minWidth: 160 }}>
                  <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                    <Avatar src={item.account?.image} alt={item.account?.name} sx={{ width: 36, height: 36 }} />
                    <span style={{ fontWeight: 600 }}>{item.account?.name}</span>
                  </Box>
                </TableCell>
                <TableCell sx={{ minWidth: 180, maxWidth: 180, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>
                  <span style={{ display: 'inline-block', maxWidth: 170, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap', verticalAlign: 'bottom' }} title={item.account?.email}>
                    {item.account?.email}
                  </span>
                </TableCell>
                <TableCell>{item.medalInfo}</TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </TableContainer>

      {/* Dialog Thêm/Sửa */}
      <Dialog open={openDialog} onClose={() => setOpenDialog(false)} PaperProps={{ sx: { borderRadius: 6, minWidth: 400, p: 2 } }}>
        <DialogTitle sx={{ fontWeight: 800, fontSize: 26, color: '#232946', textAlign: 'center', pb: 0 }}>{editingMedal ? 'Chỉnh sửa huy chương' : 'Thêm huy chương mới'}</DialogTitle>
        <DialogContent sx={{ display: 'flex', flexDirection: 'column', gap: 2, minWidth: 350, mt: 1 }}>
          <TextField
            label="Tên huy chương"
            value={form.name}
            onChange={e => setForm(f => ({ ...f, name: e.target.value }))}
            fullWidth
            margin="dense"
            sx={{ borderRadius: 3, background: '#f8fafc' }}
          />
          <TextField
            label="Mô tả"
            value={form.description}
            onChange={e => setForm(f => ({ ...f, description: e.target.value }))}
            fullWidth
            margin="dense"
            sx={{ borderRadius: 3, background: '#f8fafc' }}
          />
          <TextField
            label="Loại huy chương (type)"
            value={form.type}
            onChange={e => setForm(f => ({ ...f, type: e.target.value }))}
            fullWidth
            margin="dense"
            sx={{ borderRadius: 3, background: '#f8fafc' }}
          />
          <Button
            variant="outlined"
            component="label"
            sx={{ mt: 1, borderRadius: 3, fontWeight: 600 }}
          >
            Chọn ảnh huy chương
            <input
              type="file"
              accept="image/*"
              hidden
              onChange={handleFileChange}
            />
          </Button>
          {(form.image || imageFile) && (
            <Box sx={{ display: 'flex', justifyContent: 'center', mt: 2 }}>
              <Avatar src={form.image} alt="Preview" sx={{ width: 80, height: 80, border: '2.5px solid #a259d9', boxShadow: '0 2px 12px rgba(44,62,80,0.13)' }} />
            </Box>
          )}
        </DialogContent>
        <DialogActions sx={{ justifyContent: 'center', pb: 2 }}>
          <Button onClick={() => setOpenDialog(false)} sx={{ fontWeight: 700, borderRadius: 99, px: 4 }}>Hủy</Button>
          <Button onClick={handleSave} variant="contained" color="primary" sx={{ fontWeight: 700, borderRadius: 99, px: 4 }}>Lưu</Button>
        </DialogActions>
      </Dialog>

      {/* Dialog xác nhận xóa */}
      <Dialog open={deleteDialogOpen} onClose={handleCloseDeleteDialog} PaperProps={{ sx: { borderRadius: 4 } }}>
        <DialogTitle sx={{ fontWeight: 900, fontSize: 22, color: '#d32f2f' }}>Xác nhận xóa huy chương?</DialogTitle>
        <DialogActions sx={{ pb: 2, pr: 3 }}>
          <Button onClick={handleCloseDeleteDialog} variant="outlined" sx={{ borderRadius: 3, fontWeight: 700 }}>Hủy</Button>
          <Button onClick={handleConfirmDelete} color="error" variant="contained" sx={{ borderRadius: 3, fontWeight: 700 }}>Xóa</Button>
        </DialogActions>
      </Dialog>
    </div>
  );
};

export default AdminMedalPage; 