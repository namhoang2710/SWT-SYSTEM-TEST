import React from 'react';
import styles from './BlogLeaderboard.module.css';
import { Link } from 'react-router-dom';

const BlogLeaderboard: React.FC = () => {
  // Static data for the blog leaderboard
  const staticBlogs = [
    {
      id: 1,
      title: "Lợi ích của việc bỏ thuốc lá",
      author: "Nguyễn Văn A",
      authorImage: "/src/assets/default-avatar.png",
      likes: 150,
      views: 1200,
      createdAt: "2024-03-15"
    },
    {
      id: 2,
      title: "Các phương pháp cai thuốc lá hiệu quả",
      author: "Trần Thị B",
      authorImage: "/src/assets/default-avatar.png",
      likes: 120,
      views: 1000,
      createdAt: "2024-03-14"
    },
    {
      id: 3,
      title: "Hành trình cai thuốc lá của tôi",
      author: "Lê Văn C",
      authorImage: "/src/assets/default-avatar.png",
      likes: 100,
      views: 800,
      createdAt: "2024-03-13"
    },
    {
      id: 4,
      title: "Tác hại của thuốc lá đối với sức khỏe",
      author: "Phạm Thị D",
      authorImage: "/src/assets/default-avatar.png",
      likes: 80,
      views: 600,
      createdAt: "2024-03-12"
    },
    {
      id: 5,
      title: "Cách vượt qua cơn thèm thuốc",
      author: "Hoàng Văn E",
      authorImage: "/src/assets/default-avatar.png",
      likes: 60,
      views: 500,
      createdAt: "2024-03-11"
    }
  ];

  return (
    <div className={styles.blogLeaderboardCard}>
      <h2 className={styles.title}>Bài Viết Nổi Bật</h2>
      <div className={styles.blogList}>
        {staticBlogs.map((blog) => (
          <Link 
            to={`/blogs/${blog.id}`} 
            key={blog.id} 
            className={styles.blogItem}
          >
            <div className={styles.blogHeader}>
              <img 
                src={blog.authorImage} 
                alt={blog.author} 
                className={styles.authorAvatar}
              />
              <div className={styles.blogInfo}>
                <h3 className={styles.blogTitle}>{blog.title}</h3>
                <span className={styles.authorName}>{blog.author}</span>
              </div>
            </div>
            <div className={styles.blogStats}>
              <span className={styles.stat}>
                <i className="fas fa-heart"></i> {blog.likes}
              </span>
              <span className={styles.stat}>
                <i className="fas fa-eye"></i> {blog.views}
              </span>
              <span className={styles.date}>
                {new Date(blog.createdAt).toLocaleDateString('vi-VN')}
              </span>
            </div>
          </Link>
        ))}
      </div>
    </div>
  );
};

export default BlogLeaderboard; 