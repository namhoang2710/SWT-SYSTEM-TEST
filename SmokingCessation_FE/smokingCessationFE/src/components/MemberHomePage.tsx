import React, { useCallback, useEffect, useState, useRef } from 'react';
import { useNavigate } from 'react-router-dom';
import styles from './MemberHomePage.module.css';
import { useAuth } from '../contexts/AuthContext';
import BlogList from './BlogList';
import { getUserPackages, getUserSmokingLogs } from '../api/services/packageService';
import SmokingProgressForm from './SmokingProgressForm';
import apiClient from '../api/apiClient';
import { createBlog } from '../api/services/blogService';

const getImageUrl = (imagePath?: string | null) => {
  if (!imagePath || imagePath === 'string') return '/public/images/logo.png'; 
  if (imagePath.startsWith('http')) return imagePath;
  const filename = imagePath.split('/').pop();
  return `http://localhost:8080/api/images/${filename}`;
};

const MemberHomePage: React.FC = () => {
  const { user } = useAuth();
  const navigate = useNavigate();
  const [showPackageInfo, setShowPackageInfo] = React.useState(false);
  const [userPackages, setUserPackages] = React.useState<any[]>([]);
  const [loadingPackages, setLoadingPackages] = React.useState(false);
  const [openProgressModal, setOpenProgressModal] = React.useState(false);
  const [showLogModal, setShowLogModal] = React.useState(false);
  const [logs, setLogs] = React.useState<any[]>([]);
  const [loadingLogs, setLoadingLogs] = React.useState(false);
  const [editLog, setEditLog] = React.useState<any | null>(null);
  const [showPurchasedPackages, setShowPurchasedPackages] = React.useState(false);
  const [savingMessage, setSavingMessage] = useState<string | null>(null);
  const [postContent, setPostContent] = useState('');
  const [selectedImageName, setSelectedImageName] = useState<string | null>(null);
  const [showEmojiPicker, setShowEmojiPicker] = useState(false);
  const fileInputRef = useRef<HTMLInputElement>(null);
  // State mới cho nhiều file
  const [selectedFiles, setSelectedFiles] = useState<File[]>([]);
  const [showImageModal, setShowImageModal] = useState<{ open: boolean, file?: File }>({ open: false });
  // State cho toast
  const [toast, setToast] = useState<string | null>(null);

  const handleUpdateProgress = async () => {
    // Lấy planId active
    let planId = 0;
    try {
      const plansRes = await apiClient.get('/plans/member/my-plans');
      const activePlan = Array.isArray(plansRes.data)
        ? plansRes.data.find((p: any) => p.status === 'ACTIVE')
        : null;
      if (activePlan) {
        planId = activePlan.planId;
      }
    } catch {}
    if (planId) {
      try {
        const res = await apiClient.get(`/progress/plan/${planId}`);
        if (res.data && typeof res.data === 'string') {
          setSavingMessage(res.data);
        } else if (res.data && res.data.message) {
          setSavingMessage(res.data.message);
        }
      } catch {}
    }
    setOpenProgressModal(true);
  };

  const handleCloseProgressModal = () => {
    setOpenProgressModal(false);
  };

  const handleShowLogs = async () => {
    setShowLogModal(true);
    setLoadingLogs(true);
    try {
      const data = await getUserSmokingLogs();
      setLogs(Array.isArray(data) ? data : []);
    } catch {
      setLogs([]);
    } finally {
      setLoadingLogs(false);
    }
  };

  const handleCloseLogs = () => setShowLogModal(false);

  const handleServicePackageClick = useCallback((e: React.MouseEvent) => {
    e.preventDefault();
    navigate('/packages');
  }, [navigate]);

  const handleConsultationClick = useCallback((e: React.MouseEvent) => {
    e.preventDefault();
    e.stopPropagation();
    
    try {
      navigate('/consultation');
    } catch (error) {
      console.error('❌ Error in navigate function:', error);
      window.location.href = '/consultation';
    }
  }, [navigate]);

  const handleEditLog = (log: any) => {
    setEditLog(log);
    setShowLogModal(false);
    setOpenProgressModal(true);
  };

  const handleImageChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const files = Array.from(e.target.files || []);
    setSelectedFiles(prev => [...prev, ...files]);
    // Reset input để có thể chọn lại cùng file nếu muốn
    if (fileInputRef.current) fileInputRef.current.value = '';
  };
  const handleAddEmoji = (emoji: string) => {
    setPostContent(prev => prev + emoji);
    setShowEmojiPicker(false);
  };
  const handlePostInputChange = (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>) => {
    setPostContent(e.target.value);
  };
  const handlePost = async () => {
    if (!postContent.trim()) {
      setToast('Nội dung không được để trống!');
      return;
    }
    try {
      await createBlog({
        title: '',
        content: postContent,
        accountID: user?.id,
        image: selectedFiles[0] || null,
      });
      setToast('Đăng bài thành công!');
      setPostContent('');
      setSelectedFiles([]);
    } catch (e) {
      setToast('Đăng bài thất bại!');
    }
  };

  // Lấy danh sách gói đã mua khi vào trang
  useEffect(() => {
    const fetchUserPackages = async () => {
      try {
        setLoadingPackages(true);
        const data = await getUserPackages();
        setUserPackages(Array.isArray(data) ? data : []);
      } catch {
        setUserPackages([]);
      } finally {
        setLoadingPackages(false);
      }
    };
    fetchUserPackages();
  }, []);

  useEffect(() => {
    // Giả sử bạn lấy progressId từ plan active hoặc log gần nhất
    // Ở đây ví dụ hardcode progressId = 1, bạn nên thay bằng logic thực tế
    const fetchSaving = async () => {
      try {
        const res = await apiClient.get('/api/progress/savings/daily/1');
        if (res.data && typeof res.data === 'string') {
          setSavingMessage(res.data);
        } else if (res.data && res.data.message) {
          setSavingMessage(res.data.message);
        }
      } catch {}
    };
    fetchSaving();
  }, []);

  // useEffect để tự động ẩn toast sau 2.5s
  useEffect(() => {
    if (toast) {
      const t = setTimeout(() => setToast(null), 2500);
      return () => clearTimeout(t);
    }
  }, [toast]);

  return (
    <div className={styles.container} style={{ display: 'flex', alignItems: 'flex-start' }}>
      {/* Left Column */}
      <div className={styles.leftColumn} style={{ position: 'sticky', top: 64, alignSelf: 'flex-start', zIndex: 10 }}>
        <div className={styles.profileCard}>
          <div className={styles.profileHeader}>
            <div className={styles.profileAvatar}>
              {user?.image ? (
                <img src={getImageUrl(user.image)} alt="User Avatar" className={styles.profileAvatarImage} />
              ) : (
                <span>{user?.name ? user.name.charAt(0).toUpperCase() : 'U'}</span>
              )}
            </div>
            <h2 className={styles.profileName}>{user?.name || 'Người dùng'}</h2>
            <p className={styles.profileTitle}>{'Thành viên'}</p>
            <p className={styles.profileLocation}>Thông tin cá nhân</p>
            <p className={styles.profileUniversity}></p>
          </div>
          <div className={styles.profileStats}>
            <div
              className={styles.statItem}
              onClick={() => navigate('/progress/plan')}
              style={{ cursor: 'pointer', display: 'flex', alignItems: 'center', gap: 8 }}
            >
              <span>Tiến độ cai thuốc</span>
            </div>
            
            {/* GÓI DỊCH VỤ BUTTON */}
            <div 
              className={styles.statItem}
              onClick={handleServicePackageClick}
              style={{ cursor: 'pointer', display: 'flex', alignItems: 'center', gap: 8 }}
            >
              <span>Gói dịch vụ</span>
              <span><i className="fas fa-box"></i></span>
            </div>
            {/* Nút xem gói đã mua */}
            <div
              className={styles.statItem}
              onClick={() => setShowPurchasedPackages(v => !v)}
              style={{ cursor: 'pointer', userSelect: 'none', display: 'flex', alignItems: 'center', gap: 8 }}
            >
              <span>{showPurchasedPackages ? 'Ẩn gói đã mua' : 'Xem gói đã mua'}</span>
              <span><i className="fas fa-list-alt"></i></span>
            </div>

            {/* Đã mua gói dịch vụ */}
            {showPurchasedPackages && userPackages.length > 0 && (
              <div style={{background: '#fff', borderRadius: 8, boxShadow: '0 2px 8px rgba(0,0,0,0.06)', padding: 14, margin: '10px 0', maxHeight: 260, overflowY: 'auto'}}>
                <h4 style={{fontWeight: 700, fontSize: 16, color: '#0a66c2', marginBottom: 8}}>Gói dịch vụ đã mua</h4>
                <ul style={{paddingLeft: 0, margin: 0, listStyle: 'none'}}>
                  {userPackages.map(pkg => (
                    <li key={pkg.id} style={{marginBottom: 8, borderBottom: '1px solid #e5e7eb', paddingBottom: 6}}>
                      <div><b>Tên gói:</b> {pkg.name || pkg.infoPackageName}</div>
                    </li>
                  ))}
                </ul>
              </div>
            )}

            {/* TƯ VẤN BUTTON - NEW */}
            <div 
              className={styles.statItem}
              onClick={handleConsultationClick}
              style={{ cursor: 'pointer' }}
            >
              <span>Tư vấn</span>
              <span><i className="fas fa-user-md"></i></span>
            </div>
            {/* Nút Hồ sơ sức khỏe dạng text */}
            <div
              className={styles.statItem}
              onClick={() => navigate('/profile/health-profile')}
              style={{ cursor: 'pointer', display: 'flex', alignItems: 'center', gap: 8 }}
            >
              <span>Hồ sơ sức khỏe</span>
              <span><i className="fas fa-notes-medical"></i></span>
            </div>
            {/* Nút Kế hoạch cai thuốc dạng text */}
            <div
              className={styles.statItem}
              onClick={() => navigate('/profile/my-quit-plans')}
              style={{ cursor: 'pointer', display: 'flex', alignItems: 'center', gap: 8 }}
            >
              <span>Kế hoạch cai thuốc</span>
              <span><i className="fas fa-flag-checkered"></i></span>
            </div>
            {/* Nút Tình trạng hút thuốc */}
            <div
              className={styles.statItem}
              onClick={() => navigate('/smoking-status')}
              style={{ cursor: 'pointer', display: 'flex', alignItems: 'center', gap: 8 }}
            >
              <span>Tình trạng hút thuốc</span>
              <span><i className="fas fa-smoking"></i></span>
            </div>
          </div>
          <div className={styles.premiumSection}>
            <div
              className={styles.statItem}
              onClick={handleShowLogs}
              style={{ cursor: 'pointer', userSelect: 'none', display: 'flex', alignItems: 'center', gap: 8, width: '100%' }}
            >
              <span>Xem nhật ký hút thuốc</span>
              <span><i className="fas fa-chart-line"></i></span>
            </div>
          </div>
          <div className={styles.savedItems}>
            {/* Đã xóa các mục: Bài viết đã lưu, Lịch trình, Thống kê */}
          </div>
        </div>
      </div>

      {/* Middle Column */}
      <div className={styles.middleColumn} style={{ flex: 1, minWidth: 0 }}>
        <div className={styles.progressCard}>
          <div className={styles.progressHeader}>
            <h3>Tiến độ và Mục tiêu cai thuốc</h3>
            <span className={styles.jobSearchClose}>&times;</span>
          </div>
          <p className={styles.progressText}>Ngày không hút thuốc: 0</p>
          <div className={styles.progressImage}>
            <img src="/public/images/non-smoking.jpg" alt="Progress Image" />
          </div>
          <p className={styles.progressDescription}>Theo dõi tiến độ của bạn và đặt mục tiêu để đạt được tự do khỏi thuốc lá.</p>
          <button className={styles.updateProfileButton} onClick={handleUpdateProgress}>Cập nhật tiến độ</button>
        </div>

        <div className={styles.startPostCard}>
          <div className={styles.startPostHeader}>
            <div className={styles.startPostAvatar}>
              {user?.image ? (
                <img src={getImageUrl(user.image)} alt="User Avatar" className={styles.profileAvatarImage} />
              ) : (
                <span>{user?.name ? user.name.charAt(0).toUpperCase() : 'U'}</span>
              )}
            </div>
            <textarea
              placeholder="Bạn đang nghĩ gì?"
              className={styles.startPostInput}
              value={postContent}
              onChange={e => handlePostInputChange(e as React.ChangeEvent<HTMLTextAreaElement>)}
              rows={1}
              style={{overflowY: 'auto', resize: 'none'}}
              onInput={e => {
                const textarea = e.currentTarget;
                textarea.style.height = '40px';
                textarea.style.height = Math.min(textarea.scrollHeight, 40 * 5) + 'px';
              }}
            />
          </div>
          {/* Preview nhiều ảnh/video */}
          {selectedFiles.length > 0 && (
            <div style={{ display: 'flex', flexWrap: 'wrap', gap: 12, margin: '14px 0 18px 58px', minHeight: 40 }}>
              {selectedFiles.map((file, idx) => (
                <span
                  key={file.name + file.lastModified + idx}
                  style={{
                    display: 'inline-flex', alignItems: 'center', background: '#f3f4f6', borderRadius: 20, padding: '8px 18px 8px 14px', fontSize: 15, color: '#444', boxShadow: '0 2px 8px #0001', gap: 8, border: '1px solid #e0e0e0', cursor: file.type.startsWith('image/') ? 'pointer' : 'default', maxWidth: 320, whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis', fontWeight: 500, letterSpacing: 0.2, transition: 'box-shadow 0.2s', boxSizing: 'border-box' }}
                onClick={() => {
                  if (file.type.startsWith('image/')) setShowImageModal({ open: true, file });
                }}
                title={file.name}
              >
                <i className={file.type.startsWith('image/') ? 'fas fa-image' : 'fas fa-video'} style={{ fontSize: 16, color: '#888' }}></i>
                <span style={{ overflow: 'hidden', textOverflow: 'ellipsis', maxWidth: 180 }}>{file.name}</span>
                <button
                  onClick={e => { e.stopPropagation(); setSelectedFiles(prev => prev.filter((_, i) => i !== idx)); }}
                  style={{ background: 'none', border: 'none', color: '#888', marginLeft: 8, cursor: 'pointer', fontSize: 18, lineHeight: 1, padding: 0 }}
                  title="Xóa ảnh/video"
                >×</button>
              </span>
            ))}
            </div>
          )}
          {/* Modal xem ảnh lớn */}
          {showImageModal.open && showImageModal.file && (
            <div style={{
              position: 'fixed', top: 0, left: 0, width: '100vw', height: '100vh', background: 'rgba(0,0,0,0.5)', zIndex: 9999, display: 'flex', alignItems: 'center', justifyContent: 'center'
            }} onClick={() => setShowImageModal({ open: false })}>
              <div style={{ position: 'relative', background: 'white', borderRadius: 12, boxShadow: '0 2px 16px #0004', padding: 16, maxWidth: '90vw', maxHeight: '90vh', display: 'flex', alignItems: 'center', justifyContent: 'center' }} onClick={e => e.stopPropagation()}>
                <button onClick={() => setShowImageModal({ open: false })} style={{ position: 'absolute', top: 8, right: 12, background: 'none', border: 'none', color: '#333', fontSize: 28, cursor: 'pointer', zIndex: 2 }}>×</button>
                <img src={URL.createObjectURL(showImageModal.file)} alt="Preview" style={{ maxWidth: '80vw', maxHeight: '80vh', borderRadius: 8 }} />
              </div>
            </div>
          )}
          <div className={styles.startPostActions}>
            <button className={styles.actionButton} type="button" onClick={() => fileInputRef.current?.click()}><i className="fas fa-image"></i> Ảnh/Video</button>
            <input ref={fileInputRef} type="file" accept="image/*,video/*" style={{ display: 'none' }} onChange={handleImageChange} multiple />
            <button className={styles.actionButton} type="button" onClick={() => setShowEmojiPicker(v => !v)}><i className="fas fa-smile"></i> Cảm xúc</button>
            {showEmojiPicker && (
              <div style={{ position: 'absolute', background: '#fff', border: '1px solid #eee', borderRadius: 10, boxShadow: '0 2px 8px #0001', padding: 10, zIndex: 10, display: 'flex', gap: 8, flexWrap: 'wrap', width: 220, marginTop: 36 }}>
                {["😀","😂","😍","😢","😡","👍","🙏","🎉","🥳","😎","🤔","😱","😴","🤩","😇","😅"].map(e => (
                  <span key={e} style={{ fontSize: 22, cursor: 'pointer' }} onClick={() => handleAddEmoji(e)}>{e}</span>
                ))}
              </div>
            )}
            <button className={styles.actionButton} type="button" onClick={handlePost}><i className="fas fa-pencil-alt"></i> Viết bài</button>
          </div>
        </div>

        <BlogList displayMode="memberHome"/>
      </div>

      {/* Right Column luôn hiển thị */}
      <div className={styles.rightColumn} style={{ position: 'sticky', top: 64, alignSelf: 'flex-start', zIndex: 10 }}>
        <div className={styles.addToFeedCard}>
          <div className={styles.addToFeedHeader}>
            <h3>Bài viết nổi bật</h3>
            <span><i className="fas fa-info-circle"></i></span>
          </div>
          <div className={styles.feedItem}>
            <div className={styles.feedAvatar}></div>
            <div className={styles.feedContent}>
              <h4>Chuyên gia Sức khỏe A</h4>
              <p>Tư vấn cai thuốc lá</p>
              <button className={styles.followButton}>+ Theo dõi</button>
            </div>
          </div>
          <div className={styles.feedItem}>
            <div className={styles.feedAvatar}></div>
            <div className={styles.feedContent}>
              <h4>Bài viết mới nhất</h4>
              <p>Mẹo để vượt qua cơn thèm thuốc</p>
              <button className={styles.followButton}>+ Xem</button>
            </div>
          </div>
          <a href="#" className={styles.viewRecommendations}>Xem thêm bài viết &rarr;</a>
        </div>

        <div className={styles.quickLinksCard}>
          <div className={styles.quickLinksIcon}>💡</div>
          <p>Mẹo cai thuốc hàng ngày</p>
        </div>
      </div>

      {openProgressModal && (
        <div className="modal-overlay" onClick={handleCloseProgressModal}>
          <div className="modal-content" onClick={e => e.stopPropagation()}>
            <button onClick={handleCloseProgressModal} style={{ float: 'right', fontSize: 18, background: 'none', border: 'none', cursor: 'pointer' }}>×</button>
            <SmokingProgressForm log={editLog} onClose={() => { setEditLog(null); setOpenProgressModal(false); }} />
          </div>
        </div>
      )}

      {showLogModal && (
        <div className="modal-overlay" onClick={handleCloseLogs}>
          <div className="modal-content" onClick={e => e.stopPropagation()} style={{ maxWidth: 900, width: '100%' }}>
            <button onClick={handleCloseLogs} style={{ float: 'right', fontSize: 18, background: 'none', border: 'none', cursor: 'pointer' }}>×</button>
            <h3 style={{ 
              textAlign: 'center', 
              marginBottom: 20, 
              fontSize: '2rem', 
              fontWeight: 800, 
              color: '#1976d2', 
              letterSpacing: 0.5, 
              borderBottom: '2px solid #e3eafc',
              paddingBottom: 10
            }}>
              Nhật ký hút thuốc của bạn
            </h3>
            {loadingLogs ? (
              <div style={{ textAlign: 'center', margin: 16 }}>Đang tải...</div>
            ) : logs.length === 0 ? (
              <div style={{ textAlign: 'center', margin: 16 }}>Không có dữ liệu log.</div>
            ) : (
              <div style={{ maxHeight: 500, overflowY: 'auto', overflowX: 'auto' }}>
                <table style={{ minWidth: 850, width: '100%', borderCollapse: 'collapse', fontSize: '1.08rem' }}>
                  <thead>
                    <tr style={{ background: '#f0f4f8' }}>
                      <th style={{ padding: '14px 12px', border: '1px solid #eee' }}>Ngày</th>
                      <th style={{ padding: '14px 12px', border: '1px solid #eee' }}>Số điếu</th>
                      <th style={{ padding: '14px 12px', border: '1px solid #eee' }}>Chi phí</th>
                      <th style={{ padding: '14px 12px', border: '1px solid #eee' }}>Sức khỏe</th>
                      <th style={{ padding: '14px 12px', border: '1px solid #eee' }}>Thèm thuốc</th>
                      <th style={{ padding: '14px 12px', border: '1px solid #eee' }}>Ghi chú</th>
                      <th style={{ padding: '14px 12px', border: '1px solid #eee' }}>Hành động</th>
                    </tr>
                  </thead>
                  <tbody>
                    {logs.map((log, idx) => (
                      <tr key={log.id || idx}>
                        <td style={{ padding: '12px 10px', border: '1px solid #eee' }}>{log.date || ''}</td>
                        <td style={{ padding: '12px 10px', border: '1px solid #eee' }}>{log.cigarettes}</td>
                        <td style={{ padding: '12px 10px', border: '1px solid #eee' }}>{log.cost}</td>
                        <td style={{ padding: '12px 10px', border: '1px solid #eee' }}>{log.healthStatus}</td>
                        <td style={{ padding: '12px 10px', border: '1px solid #eee' }}>{log.cravingLevel}</td>
                        <td style={{ padding: '12px 10px', border: '1px solid #eee' }}>{log.notes}</td>
                        <td style={{ padding: '12px 10px', border: '1px solid #eee' }}>
                          <button onClick={() => handleEditLog(log)} style={{ padding: '6px 18px', background: '#1976d2', color: '#fff', border: 'none', borderRadius: 4, cursor: 'pointer', fontWeight: 500, fontSize: '1rem' }}>
                            Cập nhật
                          </button>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            )}
          </div>
        </div>
      )}

      {savingMessage && (
        <div style={{
          background: 'linear-gradient(90deg, #4ade80 60%, #22d3ee 100%)',
          color: '#134e4a',
          fontWeight: 600,
          fontSize: 18,
          padding: '16px 24px',
          borderRadius: 12,
          margin: '24px auto',
          maxWidth: 600,
          textAlign: 'center',
          boxShadow: '0 2px 8px rgba(34,211,238,0.08)'
        }}>
          {savingMessage}
        </div>
      )}
      {/* Toast/snackbar */}
      {toast && (
        <div style={{
          position: 'fixed', top: 24, right: 32, zIndex: 9999,
          background: 'linear-gradient(90deg, #4ade80 60%, #22d3ee 100%)',
          color: '#134e4a', fontWeight: 600, fontSize: 16, padding: '14px 28px', borderRadius: 12,
          boxShadow: '0 2px 12px rgba(34,211,238,0.13)', minWidth: 180, textAlign: 'center', letterSpacing: 0.2
        }}>
          {toast}
        </div>
      )}
    </div>
  );
};

export default MemberHomePage;