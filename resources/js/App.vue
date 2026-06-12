<template>
    <router-view />
</template>
<script setup>
import { onMounted, onUnmounted } from 'vue';
import { useAuthStore } from '@/stores/auth';

const authStore = useAuthStore();

let cleanup = null;

onMounted(() => {
   cleanup = authStore.initTabExpiryCheck();
});

onUnmounted(() => {
   if (cleanup) cleanup();
});
</script>