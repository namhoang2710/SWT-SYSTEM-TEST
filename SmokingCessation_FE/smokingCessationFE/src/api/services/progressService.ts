import { callApi } from '../apiHelper';

export async function addDailyProgress({
  planId,
  date,
  cigarettesSmoked,
  cravingLevel,
  moodLevel,
  exerciseMinutes,
  notes
}: {
  planId: number;
  date: string;
  cigarettesSmoked: number;
  cravingLevel?: number;
  moodLevel?: number;
  exerciseMinutes?: number;
  notes?: string;
}) {
  // Chỉ truyền các trường có giá trị
  const queryParams: Record<string, any> = {
    planId,
    date,
    cigarettesSmoked,
  };
  if (cravingLevel !== undefined) queryParams.cravingLevel = cravingLevel;
  if (moodLevel !== undefined) queryParams.moodLevel = moodLevel;
  if (exerciseMinutes !== undefined) queryParams.exerciseMinutes = exerciseMinutes;
  if (notes !== undefined && notes !== null && notes !== '') queryParams.notes = notes;

  return await callApi('addDailyProgress', 'post', {
    queryParams
  });
} 