import { useState, useEffect } from 'react';

const loginImages = [
  {
    src: '/images/sign-in.jpg',
    alt: 'Sign in to your account'
  },
  {
    src: '/images/register.jpg',
    alt: 'Join our community'
  },
  {
    src: '/images/non-smoking.jpg',
    alt: 'Start your smoke-free journey'
  }
];

export function useRotatingImage() {
  const [currentImageIndex, setCurrentImageIndex] = useState(0);

  useEffect(() => {
    const interval = setInterval(() => {
      setCurrentImageIndex((prevIndex) => 
        prevIndex === loginImages.length - 1 ? 0 : prevIndex + 1
      );
    }, 5000); // Change image every 5 seconds

    return () => clearInterval(interval);
  }, []);

  return loginImages[currentImageIndex];
} 