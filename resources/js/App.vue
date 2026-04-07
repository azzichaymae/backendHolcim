<template>
    <router-view />
</template>
<script setup>
import { onMounted, onUnmounted } from 'vue';
import { useAuthStore } from '@/stores/auth';

const authStore = useAuthStore();

let cleanup = null;

onMounted(() => {
  // Initialize the tab expiry check
  cleanup = authStore.initTabExpiryCheck();
});

onUnmounted(() => {
  // Clean up event listener when app unmounts
  if (cleanup) cleanup();
});
</script>