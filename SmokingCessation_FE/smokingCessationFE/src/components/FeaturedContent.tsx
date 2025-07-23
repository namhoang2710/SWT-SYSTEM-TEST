import React, { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import { getFeaturedContent, FeaturedContent as FeaturedContentType } from '../api/services/contentService';
import styles from './FeaturedContent.module.css';

const FeaturedContent: React.FC = () => {
  const [featuredContent, setFeaturedContent] = useState<FeaturedContentType[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const fetchFeaturedContent = async () => {
      try {
        const content = await getFeaturedContent();
        setFeaturedContent(content);
      } catch (err) {
        setError('Failed to load featured content');
        console.error('Error fetching featured content:', err);
      } finally {
        setLoading(false);
      }
    };

    fetchFeaturedContent();
  }, []);

  if (loading) {
    return (
      <div className={styles.loadingContainer}>
        <div className={styles.loadingSpinner}></div>
        <p>Loading featured content...</p>
      </div>
    );
  }

  if (error) {
    return (
      <div className={styles.errorContainer}>
        <p className={styles.errorMessage}>{error}</p>
        <button 
          className={styles.retryButton}
          onClick={() => window.location.reload()}
        >
          Retry
        </button>
      </div>
    );
  }

  return (
    <section className={styles.featuredSection}>
      <h2 className={styles.sectionTitle}>Featured Content</h2>
      <div className={styles.contentGrid}>
        {featuredContent.map((content) => (
          <Link 
            to={content.link} 
            key={content.id} 
            className={styles.contentCard}
          >
            <div className={styles.imageContainer}>
              <img 
                src={content.image} 
                alt={content.title}
                className={styles.contentImage}
              />
              <span className={`${styles.contentType} ${styles[content.type]}`}>
                {content.type.charAt(0).toUpperCase() + content.type.slice(1)}
              </span>
            </div>
            <div className={styles.contentInfo}>
              <h3 className={styles.contentTitle}>{content.title}</h3>
              <p className={styles.contentDescription}>{content.description}</p>
            </div>
          </Link>
        ))}
      </div>
    </section>
  );
};

export default FeaturedContent; 