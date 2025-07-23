import React from 'react';

const mockCoaches = [
  { id: 1, name: 'Nguyễn Văn A', image: '/public/images/logo.png', consultations: 120 },
  { id: 2, name: 'Trần Thị B', image: '/public/images/logo.png', consultations: 110 },
  { id: 3, name: 'Lê Văn C', image: '/public/images/logo.png', consultations: 95 },
  { id: 4, name: 'Phạm Thị D', image: '/public/images/logo.png', consultations: 80 },
  { id: 5, name: 'Hoàng Văn E', image: '/public/images/logo.png', consultations: 75 },
];

const CoachLeaderboard: React.FC = () => (
  <div className="bg-white rounded-lg shadow p-4">
    <h3 className="text-lg font-bold mb-3 text-blue-700">Bảng xếp hạng Coach</h3>
    <ul>
      {mockCoaches.map((coach, idx) => (
        <li key={coach.id} className="flex items-center gap-3 mb-2">
          <span className="font-bold text-xl text-blue-600">{idx + 1}</span>
          <img src={coach.image} alt={coach.name} className="w-8 h-8 rounded-full object-cover" />
          <span className="font-semibold">{coach.name}</span>
          <span className="ml-auto text-green-600 font-bold">{coach.consultations} buổi</span>
        </li>
      ))}
    </ul>
  </div>
);

export default CoachLeaderboard; 