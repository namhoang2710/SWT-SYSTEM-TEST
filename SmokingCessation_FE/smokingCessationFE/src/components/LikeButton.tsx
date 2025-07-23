import React from 'react';
import { motion, useAnimation } from 'framer-motion';

interface LikeButtonProps {
  liked: boolean;
  onClick: () => void;
}

const LikeButton: React.FC<LikeButtonProps> = ({ liked, onClick }) => {
  const controls = useAnimation();

  const handleClick = async () => {
    controls.start({
      scale: [1, 1.4, 0.9, 1.1, 1],
      transition: { duration: 0.4 }
    });
    onClick();
  };

  return (
    <button
      style={{
        color: liked ? '#2563eb' : '#444',
        fontSize: liked ? '1.15rem' : '1rem',
        fontWeight: liked ? 700 : 600,
        transform: liked ? 'scale(1.08)' : 'none',
        transition: 'all 0.18s cubic-bezier(.4,2,.6,1)',
        background: 'none',
        border: 'none',
        cursor: 'pointer',
        display: 'flex',
        alignItems: 'center',
        gap: '0.5rem'
      }}
      onClick={handleClick}
    >
      <motion.i
        className="fas fa-thumbs-up"
        style={{
          color: liked ? '#2563eb' : '#888',
          fontSize: liked ? '1.45rem' : '1rem',
          filter: liked ? 'drop-shadow(0 2px 6px #2563eb33)' : 'none',
          transition: 'color 0.18s, font-size 0.18s, filter 0.18s'
        }}
        animate={controls}
      ></motion.i>
      Thích
    </button>
  );
};

export default LikeButton; 