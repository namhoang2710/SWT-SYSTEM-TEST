import React, { useState, useMemo, CSSProperties } from 'react';

interface BlogImageProps {
  src?: string;
  alt: string;
  className?: string;
  fallbackSrc?: string;
  style?: CSSProperties;
}

const BlogImage: React.FC<BlogImageProps> = ({
  src,
  alt,
  className,
  fallbackSrc = '/default-blog-image.jpg',
  style
}) => {
  const [error, setError] = useState(false);
  
  const imageUrl = useMemo(() => {
    if (error || !src || src === 'string') return fallbackSrc;
    if (src.startsWith('http')) return src;
    const filename = src.split('/').pop();
    return `http://localhost:8080/api/images/${filename}`;
  }, [src, error, fallbackSrc]);

  return (
    <img
      src={imageUrl}
      alt={alt}
      className={className}
      style={style}
      onError={() => setError(true)}
      loading="lazy"
    />
  );
};

export default BlogImage; 