import React from 'react';
import { Swiper, SwiperSlide } from 'swiper/react';
import { Navigation, Pagination } from 'swiper/modules';
import type { InformationPackageDTO } from '../api/services/packageService';
import 'swiper/css';
import 'swiper/css/navigation';
import 'swiper/css/pagination';

interface PackageSliderProps {
  packages: InformationPackageDTO[];
  onPurchase: (packageId: number) => void;
  onCancel: (packageId: number) => void;
  isAuthenticated: boolean;
  purchasedPackages?: number[];
}

export default function PackageSlider({ 
  packages = [],
  onPurchase, 
  onCancel, 
  isAuthenticated,
  purchasedPackages = [] 
}: PackageSliderProps) {
  const safePackages = Array.isArray(packages) ? packages : [];
  
  if (safePackages.length === 0) {
    return (
      <div className="text-center py-12">
        <p className="text-gray-500">Không có gói dịch vụ nào</p>
      </div>
    );
  }

  return (
    <div className="relative">
      <Swiper
        modules={[Navigation, Pagination]}
        spaceBetween={30}
        slidesPerView={3}
        navigation
        pagination={{ clickable: true }}
        breakpoints={{
          320: { slidesPerView: 1, spaceBetween: 20 },
          640: { slidesPerView: 2, spaceBetween: 20 },
          1024: { slidesPerView: 3, spaceBetween: 30 }
        }}
        className="py-12 px-4"
      >
        {safePackages.map((pkg) => (
          <SwiperSlide key={pkg?.id || Math.random()}>
            <div className="bg-white rounded-2xl shadow-xl overflow-hidden transform transition-all duration-300 hover:shadow-2xl hover:-translate-y-1 h-full">
              <div className="p-8">
                <div className="flex justify-between items-start mb-6">
                  <h3 className="text-2xl font-bold text-gray-900">{pkg?.name || 'Không có tên'}</h3>
                  <div className="bg-green-100 text-green-600 px-4 py-2 rounded-full text-sm font-semibold">
                    {pkg?.duration || 0} ngày
                  </div>
                </div>
                
                <div className="mb-6">
                  <span className="text-4xl font-bold text-gray-900">
                    {(pkg?.price || 0).toLocaleString('vi-VN')}đ
                  </span>
                  <span className="text-gray-500">/gói</span>
                </div>

                <p className="text-gray-600 mb-8 min-h-[80px]">
                  {pkg?.description || 'Không có mô tả'}
                </p>

                {isAuthenticated ? (
                  purchasedPackages.includes(pkg?.id || 0) ? (
                    <button
                      onClick={() => pkg?.id && onCancel(pkg.id)}
                      className="w-full py-4 bg-red-500 text-white text-lg font-semibold rounded-lg shadow-lg hover:bg-red-600 hover:shadow-xl transition-all duration-300"
                    >
                      Hủy Gói
                    </button>
                  ) : (
                    <button
                      onClick={() => pkg?.id && onPurchase(pkg.id)}
                      className="w-full py-4 bg-green-500 text-white text-lg font-semibold rounded-lg shadow-lg hover:bg-green-600 hover:shadow-xl transition-all duration-300"
                    >
                      Mua Ngay
                    </button>
                  )
                ) : (
                  <button
                    onClick={() => pkg?.id && onPurchase(pkg.id)}
                    className="w-full py-4 bg-gray-500 text-white text-lg font-semibold rounded-lg shadow-lg hover:bg-gray-600 hover:shadow-xl transition-all duration-300"
                  >
                    Đăng Nhập Để Mua
                  </button>
                )}
              </div>

              <div className="bg-gray-50 p-8 border-t border-gray-100">
                <ul className="space-y-4">
                  {(pkg?.features || []).map((feature, index) => (
                    <li key={index} className="flex items-center text-gray-600">
                      <svg className="w-5 h-5 text-green-500 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M5 13l4 4L19 7" />
                      </svg>
                      {feature}
                    </li>
                  ))}
                </ul>
              </div>
            </div>
          </SwiperSlide>
        ))}
      </Swiper>

      <style>{`
        .swiper {
          padding: 20px 0;
        }

        .swiper-slide {
          height: auto;
        }

        .swiper-pagination-bullet {
          width: 10px;
          height: 10px;
          background: #10B981;
          opacity: 0.5;
          transition: all 0.3s ease;
        }

        .swiper-pagination-bullet-active {
          opacity: 1;
          background: #059669;
          transform: scale(1.2);
        }

        .swiper-button-prev,
        .swiper-button-next {
          width: 40px !important;
          height: 40px !important;
          background: white !important;
          border-radius: 50% !important;
          box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06) !important;
          border: 1px solid #e5e7eb !important;
          transition: all 0.3s ease !important;
        }

        .swiper-button-prev:hover,
        .swiper-button-next:hover {
          background: #f0fdf4 !important;
          transform: scale(1.05) !important;
          box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05) !important;
        }

        .swiper-button-prev::after,
        .swiper-button-next::after {
          font-size: 18px !important;
          color: #4b5563 !important;
          font-weight: bold !important;
        }

        .swiper-button-prev:hover::after,
        .swiper-button-next:hover::after {
          color: #059669 !important;
        }

        .swiper-button-disabled {
          opacity: 0.5 !important;
          cursor: not-allowed !important;
          pointer-events: none !important;
        }

        .swiper-button-disabled::after {
          color: #9ca3af !important;
        }
      `}</style>
    </div>
  );
} 