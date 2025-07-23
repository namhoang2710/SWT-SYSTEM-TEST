import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import styles from './Leaderboard.module.css';

interface User {
  id: number;
  name: string;
  image: string;
  smokeFreeDays: number;
}

const Leaderboard: React.FC = () => {
  const [users, setUsers] = useState<User[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [searchTerm, setSearchTerm] = useState<string>('');

  useEffect(() => {
    // Simulate fetching data
    const mockUsers: User[] = [
      {
        id: 1,
        name: "Nguyễn Văn A",
        image: "https://i.pravatar.cc/150?img=6",
        smokeFreeDays: 365
      },
      {
        id: 2,
        name: "Trần Thị B",
        image: "https://i.pravatar.cc/150?img=7",
        smokeFreeDays: 240
      },
      {
        id: 3,
        name: "Lê Văn C",
        image: "https://i.pravatar.cc/150?img=8",
        smokeFreeDays: 180
      },
      {
        id: 4,
        name: "Phạm Thị D",
        image: "https://i.pravatar.cc/150?img=9",
        smokeFreeDays: 120
      },
      {
        id: 5,
        name: "Hoàng Văn E",
        image: "https://i.pravatar.cc/150?img=10",
        smokeFreeDays: 90
      },
      {
        id: 6,
        name: "Võ Thị G",
        image: "https://i.pravatar.cc/150?img=11",
        smokeFreeDays: 75
      },
      {
        id: 7,
        name: "Đặng Văn H",
        image: "https://i.pravatar.cc/150?img=12",
        smokeFreeDays: 60
      },
      {
        id: 8,
        name: "Bùi Thị I",
        image: "https://i.pravatar.cc/150?img=13",
        smokeFreeDays: 45
      },
      {
        id: 9,
        name: "Đỗ Văn K",
        image: "https://i.pravatar.cc/150?img=14",
        smokeFreeDays: 30
      },
      {
        id: 10,
        name: "Ngô Thị L",
        image: "https://i.pravatar.cc/150?img=15",
        smokeFreeDays: 15
      }
    ].sort((a, b) => b.smokeFreeDays - a.smokeFreeDays);

    setUsers(mockUsers);
    setLoading(false);
  }, []);

  const top3Users = users.slice(0, 3);
  const otherUsers = users.slice(3).filter(user =>
    user.name.toLowerCase().includes(searchTerm.toLowerCase())
  );

  if (loading) {
    return <div className={styles.loading}>Đang tải bảng xếp hạng...</div>;
  }

  if (error) {
    return <div className={styles.error}>Lỗi: {error}</div>;
  }

  return (
    <div className={styles.leaderboardContainer}>
      <div className={styles.topPlayers}>
        {top3Users.map((user, index) => (
          <div key={user.id} className={`${styles.topPlayerItem} ${styles[`rank${index + 1}`]}`}>
            {index === 0 && (
              <svg className={styles.crownIcon} xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor">
                <path fillRule="evenodd" d="M9.696 1.64A1 1 0 0111 1.077V3.5h1.25V1.077a1 1 0 011.304.563l3.25 6.75a1 1 0 01-.192 1.056l-3.25 3a1 1 0 00-.383 1.056l1.625 4.5a1 1 0 01-1.268 1.258l-4.25-1.5A1 1 0 009 18.25v-2.25a1 1 0 01-1-1v-2.25a1 1 0 00-.12-.497l-3.25-3a1 1 0 01-.192-1.056l3.25-6.75z" clipRule="evenodd" />
              </svg>
            )}
            <div className={styles.avatarWrapper}>
              <img
                src={user.image}
                alt={user.name}
                className={styles.userAvatar}
                onError={(e) => {
                  const target = e.target as HTMLImageElement;
                  target.src = 'https://via.placeholder.com/150'; // Default avatar
                }}
              />
            </div>
            <span className={styles.topPlayerName}>{user.name}</span>
            <span className={styles.topPlayerScore}>{user.smokeFreeDays} ngày</span>
          </div>
        ))}
      </div>

      <div className={styles.searchBarContainer}>
        <input
          type="text"
          placeholder="Tìm kiếm người dùng..."
          className={styles.searchInput}
          value={searchTerm}
          onChange={(e) => setSearchTerm(e.target.value)}
        />
        <button className={styles.searchButton}>
          <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor">
            <path fillRule="evenodd" d="M9 3.5a5.5 5.5 0 100 11 5.5 5.5 0 000-11zM2 9a7 7 0 1112.452 4.391l3.328 3.329a.75.75 0 11-1.06 1.06l-3.329-3.328A7 7 0 012 9z" clipRule="evenodd" />
          </svg>
        </button>
      </div>

      <div className={styles.userList}>
        {otherUsers.map((user, index) => (
          <div key={user.id} className={styles.userItem}>
            <div className={styles.rank}>{index + 4}</div> {/* Ranks from 4 onwards */}
            <img
              src={user.image}
              alt={user.name}
              className={styles.userAvatarSmall}
              onError={(e) => {
                const target = e.target as HTMLImageElement;
                target.src = 'https://via.placeholder.com/40'; // Default avatar
              }}
            />
            <div className={styles.userInfo}>
              <Link to={`/profile/${user.id}`} className={styles.userName}>
                {user.name}
              </Link>
              <div className={styles.userStats}>
                <div className={styles.statItem}>
                  <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor">
                    <path fillRule="evenodd" d="M6.75 2.25A.75.75 0 017.5 3v1.5h9V3A.75.75 0 0118 3v1.5h.75a3 3 0 013 3v11.25a3 3 0 01-3 3H5.25a3 3 0 01-3-3V7.5a3 3 0 013-3H6.75V3a.75.75 0 01.75-.75zm13.5 9a.75.75 0 00-1.5 0v2.25a.75.75 0 001.5 0v-2.25z" clipRule="evenodd" />
                  </svg>
                  {user.smokeFreeDays} ngày
                </div>
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
};

export default Leaderboard;