import React, { useEffect, useState } from 'react';
import {
  Table, TableBody, TableCell, TableContainer, TableHead, TableRow, Paper, Button, Dialog, DialogTitle, DialogContent, DialogActions, TextField, IconButton
} from '@mui/material';
import { Delete, Edit, Add, Visibility } from '@mui/icons-material';
import apiClient from '../api/apiClient';
import { toast } from 'react-toastify';
import { updatePackageAdmin } from '../api/services/packageService';
import { getAllBlogsForAdmin, deleteBlog } from '../api/services/blogService';

interface Package {
  id: number;
  name: string;
  description: string;
  price: number;
  duration?: number;
  numberOfConsultations?: number;
  numberOfHealthCheckups?: number;
  // Thêm các trường khác nếu cần
}

const AdminPackagePage: React.FC = () => {
  const [packages, setPackages] = useState<Package[]>([]);
  const [loading, setLoading] = useState(false);
  const [openDialog, setOpenDialog] = useState(false);
  const [editingPackage, setEditingPackage] = useState<Package | null>(null);
  const [form, setForm] = useState({ name: '', description: '', price: '', duration: '', numberOfConsultations: '', numberOfHealthCheckups: '' });
  const [deleteId, setDeleteId] = useState<number | null>(null);
  const [deleteDialog, setDeleteDialog] = useState(false);
  const [blogs, setBlogs] = useState<any[]>([]);

  // Fetch all packages
  const fetchPackages = async () => {
    setLoading(true);
    try {
      const res = await apiClient.get('/admin/packages/all');
      setPackages(res.data);
    } catch (err) {
      toast.error('Không thể tải danh sách gói!');
    } finally {
      setLoading(false);
    }
  };

  const fetchBlogs = async () => {
    setLoading(true);
    try {
      const res = await getAllBlogsForAdmin();
      setBlogs(res);
    } catch (err) {
      toast.error('Không thể tải danh sách blog!');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchPackages();
    // fetchBlogs(); // Đã loại bỏ, không gọi khi vào trang
  }, []);

  // Open dialog for add or edit
  const handleOpenDialog = (pkg?: Package) => {
    if (pkg) {
      setEditingPackage(pkg);
      setForm({
        name: pkg.name,
        description: pkg.description,
        price: String(pkg.price),
        duration: pkg.duration ? String(pkg.duration) : '',
        numberOfConsultations: pkg.numberOfConsultations ? String(pkg.numberOfConsultations) : '',
        numberOfHealthCheckups: pkg.numberOfHealthCheckups ? String(pkg.numberOfHealthCheckups) : '',
      });
    } else {
      setEditingPackage(null);
      setForm({ name: '', description: '', price: '', duration: '', numberOfConsultations: '', numberOfHealthCheckups: '' });
    }
    setOpenDialog(true);
  };

  // Handle add or update
  const handleSave = async () => {
    if (!form.name.trim() || !form.price.trim()) {
      toast.error('Tên và giá gói là bắt buộc!');
      return;
    }
    try {
      const durationValue = Number(form.duration) || 30;
      if (editingPackage) {
        await updatePackageAdmin(editingPackage.id, {
          name: form.name,
          description: form.description,
          price: Number(form.price),
          duration: durationValue,
          numberOfConsultations: Number(form.numberOfConsultations) || 0,
          numberOfHealthCheckups: Number(form.numberOfHealthCheckups) || 0,
        });
        toast.success('Cập nhật gói thành công!');
      } else {
        await apiClient.post('/admin/packages/create', {
          name: form.name,
          description: form.description,
          price: Number(form.price),
          duration: durationValue,
          numberOfConsultations: Number(form.numberOfConsultations) || 0,
          numberOfHealthCheckups: Number(form.numberOfHealthCheckups) || 0,
        });
        toast.success('Tạo mới gói thành công!');
      }
      setOpenDialog(false);
      fetchPackages();
    } catch (err) {
      toast.error('Lưu gói thất bại!');
    }
  };

  // Handle delete
  const handleDelete = async () => {
    if (!deleteId) return;
    try {
      await apiClient.delete(`/admin/packages/${deleteId}`);
      toast.success('Xóa gói thành công!');
      setDeleteDialog(false);
      fetchPackages();
    } catch (err) {
      toast.error('Xóa gói thất bại!');
    }
  };

  return (
    <div style={{ maxWidth: 1000, margin: '40px auto', background: 'linear-gradient(135deg, #f8fafc 60%, #e0e7ff 100%)', borderRadius: 24, boxShadow: '0 8px 32px #b6c7e633', padding: '32px 0 48px 0', position: 'relative' }}>
      <h2 style={{ fontSize: 32, fontWeight: 900, marginBottom: 28, color: '#232946', textAlign: 'center', letterSpacing: 1.2, textShadow: '0 2px 12px #b6c7e6' }}>
        Quản lý Gói hỗ trợ
      </h2>
      <div style={{ display: 'flex', justifyContent: 'flex-end', maxWidth: 900, margin: '0 auto 18px auto' }}>
        <Button variant="contained" color="primary" startIcon={<Add />} onClick={() => handleOpenDialog()} sx={{ fontWeight: 700, fontSize: 17, borderRadius: 3, px: 3, py: 1, boxShadow: '0 2px 8px #6366f122', background: 'linear-gradient(90deg,#6366f1,#06b6d4)', '&:hover': { background: 'linear-gradient(90deg,#6366f1,#2563eb)' } }}>
          Thêm mới
        </Button>
      </div>
      <TableContainer component={Paper} sx={{ maxWidth: 900, margin: '0 auto', borderRadius: 4, boxShadow: '0 4px 24px #6366f122', overflow: 'hidden' }}>
        <Table>
          <TableHead>
            <TableRow sx={{ background: 'linear-gradient(90deg,#6366f1 0%,#06b6d4 100%)' }}>
              <TableCell sx={{ color: '#fff', fontWeight: 700, fontSize: 18 }}>ID</TableCell>
              <TableCell sx={{ color: '#fff', fontWeight: 700, fontSize: 18 }}>Tên gói</TableCell>
              <TableCell sx={{ color: '#fff', fontWeight: 700, fontSize: 18 }}>Mô tả</TableCell>
              <TableCell sx={{ color: '#fff', fontWeight: 700, fontSize: 18 }}>Giá</TableCell>
              <TableCell align="right" sx={{ color: '#fff', fontWeight: 700, fontSize: 18 }}>Hành động</TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {packages.map((pkg) => (
              <TableRow key={pkg.id} hover sx={{ transition: 'background 0.2s', '&:hover': { background: '#f1f5fd' } }}>
                <TableCell sx={{ fontWeight: 600, fontSize: 16 }}>{pkg.id}</TableCell>
                <TableCell sx={{ fontWeight: 700, color: '#2563eb', fontSize: 17 }}>{pkg.name}</TableCell>
                <TableCell sx={{ fontSize: 15, color: '#64748b', maxWidth: 220, whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>{pkg.description}</TableCell>
                <TableCell sx={{ fontWeight: 700, color: '#06b6d4', fontSize: 17 }}>{pkg.price.toLocaleString('vi-VN', { style: 'currency', currency: 'VND' })}</TableCell>
                <TableCell align="right">
                  <IconButton color="primary" onClick={() => handleOpenDialog(pkg)} sx={{ mr: 1 }}><Edit /></IconButton>
                  <IconButton color="error" onClick={() => { setDeleteId(pkg.id); setDeleteDialog(true); }}><Delete /></IconButton>
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </TableContainer>

      {/* Dialog Thêm/Sửa */}
      <Dialog open={openDialog} onClose={() => setOpenDialog(false)} PaperProps={{ sx: { borderRadius: 6, p: 2, minWidth: 400 } }}>
        <DialogTitle sx={{ fontWeight: 900, fontSize: 24, color: '#2563eb', textAlign: 'center', letterSpacing: 1 }}>{editingPackage ? 'Cập nhật gói' : 'Thêm mới gói'}</DialogTitle>
        <DialogContent sx={{ p: 3 }}>
          <TextField
            label="Tên gói"
            value={form.name}
            onChange={e => setForm(f => ({ ...f, name: e.target.value }))}
            fullWidth
            margin="normal"
            sx={{ borderRadius: 3, background: '#f8fafc' }}
          />
          <TextField
            label="Mô tả"
            value={form.description}
            onChange={e => setForm(f => ({ ...f, description: e.target.value }))}
            fullWidth
            margin="normal"
            sx={{ borderRadius: 3, background: '#f8fafc' }}
          />
          <TextField
            label="Giá"
            type="number"
            value={form.price}
            onChange={e => setForm(f => ({ ...f, price: e.target.value }))}
            fullWidth
            margin="normal"
            sx={{ borderRadius: 3, background: '#f8fafc' }}
          />
          <TextField
            label="Thời hạn (ngày)"
            type="number"
            value={form.duration}
            onChange={e => setForm(f => ({ ...f, duration: e.target.value }))}
            fullWidth
            margin="normal"
            sx={{ borderRadius: 3, background: '#f8fafc' }}
          />
          <TextField
            label="Số lần tư vấn"
            type="number"
            value={form.numberOfConsultations}
            onChange={e => setForm(f => ({ ...f, numberOfConsultations: e.target.value }))}
            fullWidth
            margin="normal"
            sx={{ borderRadius: 3, background: '#f8fafc' }}
          />
          <TextField
            label="Số lần khám sức khỏe"
            type="number"
            value={form.numberOfHealthCheckups}
            onChange={e => setForm(f => ({ ...f, numberOfHealthCheckups: e.target.value }))}
            fullWidth
            margin="normal"
            sx={{ borderRadius: 3, background: '#f8fafc' }}
          />
        </DialogContent>
        <DialogActions sx={{ justifyContent: 'center', pb: 2 }}>
          <Button onClick={() => setOpenDialog(false)} variant="outlined" sx={{ borderRadius: 3, fontWeight: 700, fontSize: 16 }}>Hủy</Button>
          <Button onClick={handleSave} variant="contained" sx={{ borderRadius: 3, fontWeight: 700, fontSize: 16, background: 'linear-gradient(90deg,#6366f1,#06b6d4)', '&:hover': { background: 'linear-gradient(90deg,#6366f1,#2563eb)' } }}>{editingPackage ? 'Cập nhật' : 'Thêm mới'}</Button>
        </DialogActions>
      </Dialog>

      {/* Dialog xác nhận xóa */}
      <Dialog open={deleteDialog} onClose={() => setDeleteDialog(false)} PaperProps={{ sx: { borderRadius: 6 } }}>
        <DialogTitle sx={{ fontWeight: 900, fontSize: 22, color: '#ef4444', textAlign: 'center' }}>Xác nhận xóa gói?</DialogTitle>
        <DialogActions sx={{ justifyContent: 'center', pb: 2 }}>
          <Button onClick={() => setDeleteDialog(false)} variant="outlined" sx={{ borderRadius: 3, fontWeight: 700, fontSize: 16 }}>Hủy</Button>
          <Button onClick={handleDelete} variant="contained" color="error" sx={{ borderRadius: 3, fontWeight: 700, fontSize: 16 }}>Xóa</Button>
        </DialogActions>
      </Dialog>
    </div>
  );
};

export default AdminPackagePage; 