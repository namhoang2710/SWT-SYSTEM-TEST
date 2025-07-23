import React, { useState, useEffect } from 'react';
import styles from './Billboard.module.css';
import { useNavigate, Link } from 'react-router-dom';
import { getTopBlogs, BlogPost } from '../api/services/blogService';
import { format } from 'date-fns';
import { toast } from 'react-toastify';
import BlogImage from './BlogImage';

interface Blog extends BlogPost {}

const getImageUrl = (imagePath?: string) => {
  if (!imagePath) return '/default-blog-image.jpg';
  if (imagePath.startsWith('http')) return imagePath;
  // Extract filename from the path
  const filename = imagePath.split('/').pop();
  return `http://localhost:8080/api/images/${filename}`;
};

const Billboard: React.FC = () => {
  const navigate = useNavigate();
  const [blogs, setBlogs] = useState<Blog[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const fetchLatestBlogs = async () => {
      try {
        setLoading(true);
        const data = await getTopBlogs();
        console.log('Dữ liệu blog nhận được trong Billboard:', JSON.stringify(data, null, 2));
        // Sort blogs by date and get the latest 7
        const sortedBlogs = data.sort((a: Blog, b: Blog) => {
          const dateA = new Date(`${a.createdDate}T${a.createdTime}`);
          const dateB = new Date(`${b.createdDate}T${b.createdTime}`);
          return dateB.getTime() - dateA.getTime();
        }).slice(0, 7);
        setBlogs(sortedBlogs);
        setError(null);
      } catch (err: any) {
        console.error('Error fetching blogs:', err);
        setError('Không thể tải bài viết. Vui lòng thử lại sau.');
        toast.error('Không thể tải bài viết. Vui lòng thử lại sau.');
      } finally {
        setLoading(false);
      }
    };

    fetchLatestBlogs();
  }, []);

  if (loading) {
    return (
      <div className={styles.billboardContainer}>
        <div className={styles.loadingContainer}>
          <div className={styles.loadingSpinner}></div>
          <p>Đang tải bài viết...</p>
        </div>
      </div>
    );
  }

  if (error || blogs.length === 0) {
    return (
      <div className={styles.billboardContainer}>
        <div className={styles.errorContainer}>
          <p>{error || 'Không có bài viết nào'}</p>
        </div>
      </div>
    );
  }

  const featuredBlog = blogs[0];
  const sidebarBlogs = blogs.slice(1);

  return (
    <div className={styles.billboardContainer}>
      <div className={styles.billboardContentWrapper}>
        <div 
          className={styles.featuredArticle}
          onClick={() => navigate(`/blogs?scrollTo=${featuredBlog.blogID}`)}
        >
          <BlogImage 
            src={featuredBlog.image}
            alt={featuredBlog.title}
            className={styles.featuredArticleImage}
          />
          <div className={styles.featuredArticleOverlay}>
            <h2 className={styles.featuredArticleTitle}>{featuredBlog.title}</h2>
            <p className={styles.featuredArticleDescription}>
              {featuredBlog.content.length > 150 
                ? `${featuredBlog.content.substring(0, 150)}...` 
                : featuredBlog.content}
            </p>
            <div className={styles.featuredArticleMeta}>
              <span className={styles.featuredArticleAuthor}>
                Bởi {featuredBlog.account.name}
              </span>
              <span className={styles.featuredArticleDate}>
                {featuredBlog.createdDate && featuredBlog.createdTime 
                  ? (() => {
                      const dateTimeString = `${featuredBlog.createdDate}T${featuredBlog.createdTime}`;
                      console.log('Featured Blog DateTime String:', dateTimeString);
                      const dateObj = new Date(dateTimeString);
                      console.log('Featured Blog Date Object:', dateObj);
                      return dateObj.toLocaleDateString('vi-VN');
                    })()
                  : ''}
              </span>
            </div>
          </div>
        </div>
        <div className={styles.sidebarArticles}>
          {sidebarBlogs.map((blog) => (
            <div 
              key={blog.blogID} 
              className={styles.sidebarArticleCard} 
              onClick={() => navigate(`/blogs?scrollTo=${blog.blogID}`)}
            >
              <BlogImage 
                src={blog.image}
                alt={blog.title}
                className={styles.sidebarArticleImage}
              />
              <div className={styles.sidebarArticleInfo}>
                <h3 className={styles.sidebarArticleTitle}>{blog.title}</h3>
                <div className={styles.sidebarArticleMeta}>
                  <span className={styles.sidebarArticleAuthor}>Bởi {blog.account.name}</span>
                  <span className={styles.sidebarArticleDate}>
                    {blog.createdDate && blog.createdTime 
                      ? (() => {
                          const dateTimeString = `${blog.createdDate}T${blog.createdTime}`;
                          console.log('Sidebar Blog DateTime String:', dateTimeString);
                          const dateObj = new Date(dateTimeString);
                          console.log('Sidebar Blog Date Object:', dateObj);
                          return dateObj.toLocaleDateString('vi-VN');
                        })()
                      : ''}
                  </span>
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>
      <div className={styles.exploreLinkContainer}>
        <Link to="/blogs" className={styles.exploreLink}>Khám phá thêm</Link>
      </div>
    </div>
  );
};

export default Billboard; 