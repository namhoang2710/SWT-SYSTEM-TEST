const endpoints = {
    // Auth endpoints
    login: 'account/login',
    register: 'account/register',
    verify: 'account/verify',
    profile: 'account/profile',
    logout: 'account/logout',
    forgotPassword: 'account/forgot-password',
    resetPassword: 'account/reset-password',

    // Booking endpoints
    getAvailableSlots: 'Booking/available',
    addWeeklySlots: 'Booking/addWeeklySlots',
    deleteUnbookedSlotsForWeek: 'Booking/deleteUnbookedSlotsForWeek',
    getCoachSchedule: 'Booking/coach-schedule',

    // Blog endpoints
    getAllBlogs: 'blogs/all',
    getMyBlogs: 'blogs/my',
    updateBlog: 'blogs/update',
    getBlogByIdEndpoint: 'blogs',
    getFeaturedContent: 'blogs',

    // Coach Profile endpoints
    getAllCoachProfiles: 'coach/profile/all',
    getMyCoachProfile: 'coach/profile/me',
    updateCoachProfile: 'coach/profile/update',

    // User APIs (Member role)
    getUserCoachSlots: 'user/consultation/coach-slots',
    userBookConsultation: 'user/consultation/book',
    userBookingCount: 'user/booking-count',

    // Other endpoints
    upload: 'upload',
    listMembers: 'member',
    getAllPackages: 'admin/packages/all',
    addDailyProgress: 'progress/daily',

    // Chat Box endpoints
    getAllChatBoxesAdmin: 'chatbox/admin/all',
    deleteChatBoxById: 'chatbox/delete',

    // Medal endpoints
    getAllMedals: 'medal/all',
    createMedal: 'medal/admin/create',
    deleteMedal: 'medal/admin/delete',
    updateMedal: 'medal/admin/update',

    // Payment endpoints
    paymentMonthlyTotalByDate: '/payment/monthly-total-by-date',
    paymentDailyTotalByDate: '/payment/daily-total-by-date',
};

export type EndpointKey = keyof typeof endpoints;
export default endpoints;