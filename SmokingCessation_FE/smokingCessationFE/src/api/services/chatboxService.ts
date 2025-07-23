import apiClient from '../apiClient';
import endpoints from '../endpoints';

export const getAllChatBoxesAdmin = async () => {
  const response = await apiClient.get(`/${endpoints.getAllChatBoxesAdmin}`);
  return response.data;
};

export const deleteChatBoxById = async (chatBoxId: number | string) => {
  const response = await apiClient.delete(`/${endpoints.deleteChatBoxById}/${chatBoxId}`);
  return response.data;
}; 