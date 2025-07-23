import React, { useEffect, useState } from 'react';
import { Table, TableBody, TableCell, TableContainer, TableHead, TableRow, Paper, Button, Dialog, DialogTitle, DialogActions, Avatar } from '@mui/material';
import DeleteIcon from '@mui/icons-material/Delete';
import { getAllChatBoxesAdmin, deleteChatBoxById } from '../api/services/chatboxService';
import { getAllCoachesForAdmin, getAllMemberProfiles } from '../api/services/userService';
import { toast } from 'react-toastify';

interface ChatBox {
  chatBoxID: number | string;
  coachID: number;
  memberID: number;
  nameChatBox: string | null;
  createdAt: string;
  [key: string]: any;
}

interface CoachInfo {
  id: number;
  name: string;
  email?: string;
  image?: string;
}

interface MemberProfile {
  memberId: number;
  account: {
    id: number;
    name: string;
    email: string;
    image?: string;
    [key: string]: any;
  };
  [key: string]: any;
}

const AdminChatBoxPage: React.FC = () => {
  const [chatBoxes, setChatBoxes] = useState<ChatBox[]>([]);
  const [loading, setLoading] = useState(true);
  const [deleteDialogOpen, setDeleteDialogOpen] = useState(false);
  const [selectedChatBoxId, setSelectedChatBoxId] = useState<number | string | null>(null);
  const [coaches, setCoaches] = useState<CoachInfo[]>([]);
  const [memberProfiles, setMemberProfiles] = useState<MemberProfile[]>([]);

  useEffect(() => {
    fetchChatBoxes();
    fetchCoaches();
    fetchAllMembers();
  }, []);

  const fetchChatBoxes = async () => {
    setLoading(true);
    try {
      const data = await getAllChatBoxesAdmin();
      setChatBoxes(data);
    } catch (err) {
      toast.error('Không thể tải danh sách Chat Box');
    } finally {
      setLoading(false);
    }
  };

  const fetchCoaches = async () => {
    try {
      const data = await getAllCoachesForAdmin();
      setCoaches(data);
    } catch (err) {
      setCoaches([]);
    }
  };

  const fetchAllMembers = async () => {
    try {
      const data = await getAllMemberProfiles();
      setMemberProfiles(data);
    } catch (err) {
      setMemberProfiles([]);
    }
  };

  const handleDelete = async () => {
    if (!selectedChatBoxId) return;
    try {
      await deleteChatBoxById(selectedChatBoxId);
      toast.success('Đã xoá Chat Box thành công!');
      setChatBoxes(prev => prev.filter(cb => cb.chatBoxID !== selectedChatBoxId));
    } catch (err) {
      toast.error('Xoá Chat Box thất bại!');
    } finally {
      setDeleteDialogOpen(false);
      setSelectedChatBoxId(null);
    }
  };

  const openDeleteDialog = (chatBoxId: number | string) => {
    setSelectedChatBoxId(chatBoxId);
    setDeleteDialogOpen(true);
  };

  const closeDeleteDialog = () => {
    setDeleteDialogOpen(false);
    setSelectedChatBoxId(null);
  };

  const getCoachInfo = (coachID: number) => {
    const coach = coaches.find(c => c.id === coachID);
    return coach;
  };

  const getMemberInfo = (memberID: number) => {
    const member = memberProfiles.find(m => m.memberId === memberID);
    return member?.account;
  };

  return (
    <div style={{ padding: 24 }}>
      <h2 style={{ fontWeight: 700, fontSize: 28, marginBottom: 16 }}>Quản lý Chat Box</h2>
      {loading ? (
        <div>Đang tải...</div>
      ) : (
        <TableContainer component={Paper} sx={{ borderRadius: 3, boxShadow: 4, mt: 2, maxWidth: '100%', overflowX: 'auto' }}>
          <Table>
            <TableHead>
              <TableRow>
                <TableCell><b>ID</b></TableCell>
                <TableCell><b>Coach</b></TableCell>
                <TableCell><b>Member</b></TableCell>
                <TableCell><b>Tên Chat Box</b></TableCell>
                <TableCell><b>Ngày tạo</b></TableCell>
                <TableCell align="center"><b>Hành động</b></TableCell>
              </TableRow>
            </TableHead>
            <TableBody>
              {chatBoxes.map((cb) => (
                <TableRow key={cb.chatBoxID} hover sx={{ transition: 'background 0.2s' }}>
                  <TableCell>{cb.chatBoxID}</TableCell>
                  <TableCell>{cb.nameCoach || cb.coachID}</TableCell>
                  <TableCell>{cb.nameMember || cb.memberID}</TableCell>
                  <TableCell>{cb.nameChatBox || 'Không có tên'}</TableCell>
                  <TableCell>{cb.createdAt ? new Date(cb.createdAt).toLocaleString() : ''}</TableCell>
                  <TableCell align="center">
                    <Button
                      color="error"
                      startIcon={<DeleteIcon />}
                      onClick={() => openDeleteDialog(cb.chatBoxID)}
                      variant="outlined"
                      sx={{ fontWeight: 600 }}
                    >
                      Xoá
                    </Button>
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </TableContainer>
      )}
      <Dialog open={deleteDialogOpen} onClose={closeDeleteDialog}>
        <DialogTitle>Bạn có chắc muốn xoá Chat Box này?</DialogTitle>
        <DialogActions>
          <Button onClick={closeDeleteDialog}>Huỷ</Button>
          <Button color="error" onClick={handleDelete}>Xoá</Button>
        </DialogActions>
      </Dialog>
    </div>
  );
};

export default AdminChatBoxPage; 