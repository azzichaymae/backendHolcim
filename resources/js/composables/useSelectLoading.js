import { ref } from 'vue';

export function useSelectLoading() {
  const loadingSelects = ref(new Set());

  const isLoading = (key) => loadingSelects.value.has(key);

  const setLoading = (key, state) => {
    if (state) loadingSelects.value.add(key);
    else        loadingSelects.value.delete(key);
    // trigger reactivity
    loadingSelects.value = new Set(loadingSelects.value);
  };

  return { isLoading, setLoading };
}