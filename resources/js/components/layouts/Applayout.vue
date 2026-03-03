<template>
  <div class="app-shell">

    <!-- ── Sidebar ───────────────────────────────────── -->
    <aside class="sidebar">

      <!-- Logo -->
      <div class="sidebar-logo">
        <img :src="`/images/holcim_logo.png`" alt="Holcim" class="logo-img" />

      </div>

      <!-- Navigation section -->
      <div class="nav-section">
        <div class="nav-section-label">NAVIGATION</div>
        <nav class="sidebar-nav">
          <router-link
            v-for="item in visibleNavItems"
            :key="item.name"
            :to="item.path"
            class="nav-item"
            :class="{ active: isActive(item) }"
          >
            <span class="nav-icon" v-html="item.icon"></span>
            <span class="nav-label">{{ item.label }}</span>
            <span class="active-dot" v-if="isActive(item)"></span>
          </router-link>
        </nav>
      </div>

      <!-- Système section -->
      <div class="nav-section">
      
        <div v-if="visibleSystemItems.length > 0">
  <div class="nav-section-label">SYSTÈME</div>

  <nav class="sidebar-nav">
    <router-link
      v-for="item in visibleSystemItems"
      :key="item.name"
      :to="item.path"
      class="nav-item"
      :class="{ active: isActive(item) }"
    >
      <span class="nav-icon" v-html="item.icon"></span>
      <span class="nav-label">{{ item.label }}</span>
      <span class="active-dot" v-if="isActive(item)"></span>
    </router-link>
  </nav>
</div>
      </div>

    </aside>

    <!-- ── Main ──────────────────────────────────────── -->
    <div class="main-wrapper">

      <!-- Top bar -->
      <header class="topbar">
        <div class="topbar-left">
          <h2 class="page-title">{{ currentPageTitle }}</h2>
        </div>
        <div class="topbar-right">

          <!-- Alerts bell -->
          <router-link to="/alerts" class="bell-btn" v-if="canSeeAlerts">
            <span v-html="icons.bell"></span>
            <span class="bell-badge" v-if="alertCount > 0">{{ alertCount }}</span>
          </router-link>

          <!-- User menu -->
          <div class="user-menu" @click="userDropdown = !userDropdown">
            <div class="user-avatar">{{ userInitial }}</div>
            <div class="user-info">
              <span class="user-name">{{ auth.user?.nom }}</span>
              <span class="user-role">{{ auth.user?.role }}</span>
            </div>
            <span v-html="icons.chevronDown"></span>

            <!-- Dropdown -->
            <div class="user-dropdown" v-if="userDropdown">
              <div class="dropdown-header">
                <div class="user-name">{{ auth.user?.nom }}</div>
                <div class="user-email">{{ auth.user?.email }}</div>
                <div class="user-service">{{ auth.user?.service }}</div>
              </div>
              <div class="dropdown-divider"></div>
              <button class="dropdown-item logout" @click="handleLogout">
                <span v-html="icons.logout"></span>
                Se déconnecter
              </button>
            </div>
          </div>

        </div>
      </header>

      <!-- Page content -->
      <main class="page-content">
        <router-view />
      </main>

    </div>

  </div>
</template>

<script setup>
import { ref, computed, onMounted, onBeforeUnmount } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import { useAuthStore } from '@/stores/auth';
import api from '@/services/api';
import '@/../css/components/layouts/Applayout.css';

const auth     = useAuthStore();
const route    = useRoute();
const router   = useRouter();

const collapsed    = ref(false);
const userDropdown = ref(false);
const alertCount   = ref(0);

// ── Icons (inline SVG) ────────────────────────────────
const icons = {
  dashboard: `<svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6"/></svg>`,
  employees: `<svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0z"/></svg>`,
  habilitations: `<svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4M7.835 4.697a3.42 3.42 0 001.946-.806 3.42 3.42 0 014.438 0 3.42 3.42 0 001.946.806 3.42 3.42 0 013.138 3.138 3.42 3.42 0 00.806 1.946 3.42 3.42 0 010 4.438 3.42 3.42 0 00-.806 1.946 3.42 3.42 0 01-3.138 3.138 3.42 3.42 0 00-1.946.806 3.42 3.42 0 01-4.438 0 3.42 3.42 0 00-1.946-.806 3.42 3.42 0 01-3.138-3.138 3.42 3.42 0 00-.806-1.946 3.42 3.42 0 010-4.438 3.42 3.42 0 00.806-1.946 3.42 3.42 0 013.138-3.138z"/></svg>`,
  volets: `<svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 11V9a2 2 0 012-2m0 0V5a2 2 0 012-2h6a2 2 0 012 2v2M7 7h10"/></svg>`,
  attributions: `<svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13.828 10.172a4 4 0 00-5.656 0l-4 4a4 4 0 105.656 5.656l1.102-1.101m-.758-4.899a4 4 0 005.656 0l4-4a4 4 0 00-5.656-5.656l-1.1 1.1"/></svg>`,
  documents: `<svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 21h10a2 2 0 002-2V9.414a1 1 0 00-.293-.707l-5.414-5.414A1 1 0 0012.586 3H7a2 2 0 00-2 2v14a2 2 0 002 2z"/></svg>`,
  alerts: `<svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9"/></svg>`,
  settings: `<svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z"/><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"/></svg>`,
  bell: `<svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9"/></svg>`,
  chevronLeft: `<svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7"/></svg>`,
  chevronRight: `<svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7"/></svg>`,
  chevronDown: `<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7"/></svg>`,
  logout: `<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1"/></svg>`,
};

// ── Navigation items ──────────────────────────────────
const navItems = [
  { name: 'dashboard',     label: 'Dashboard',      path: '/dashboard',    icon: icons.dashboard,     roles: ['RRH','RH'] },
  { name: 'employees',     label: 'Salariés',      path: '/employees',    icon: icons.employees,     roles: ['RRH','RH','Manager'] },
  { name: 'volets',        label: 'Volets',         path: '/volets',       icon: icons.volets,        roles: ['RRH','RH'] },
  { name: 'habilitations', label: 'Habilitations',  path: '/habilitations',icon: icons.habilitations, roles: ['RRH','RH'] },
  { name: 'attributions',  label: 'Associations',   path: '/attributions', icon: icons.attributions,  roles: ['RRH','RH'] },
  { name: 'documents',     label: 'Documents',      path: '/documents',    icon: icons.documents,     roles: ['RRH','RH'] },
  { name: 'alerts',        label: 'Alertes',        path: '/alerts',       icon: icons.alerts,        roles: ['RRH','RH','Manager'] },
];

// ── System items ──────────────────────────────────────
const systemItems = [
  { name: 'settings', label: 'Paramètres', path: '/settings', icon: icons.settings, roles: ['RRH'] },
];

// ── All items combined for page title lookup ──────────
const allMenuItems = [...navItems, ...systemItems];

const visibleNavItems = computed(() =>
  navItems.filter(item => item.roles.includes(auth.user?.role))
);

const visibleSystemItems = computed(() =>
  systemItems.filter(item => item.roles.includes(auth.user?.role))
);

const visibleMenuItems = computed(() =>
  allMenuItems.filter(item => item.roles.includes(auth.user?.role))
);

const canSeeAlerts = computed(() =>
  ['RRH', 'RH', 'Manager'].includes(auth.user?.role)
);

// ── Page title ────────────────────────────────────────
const currentPageTitle = computed(() => {
  const item = allMenuItems.find(i => route.path.startsWith(i.path));
  return item?.label ?? 'Dashboard';
});

// ── User ──────────────────────────────────────────────
const userInitial = computed(() =>
  auth.user?.nom?.charAt(0).toUpperCase() ?? '?'
);

// ── Active route ──────────────────────────────────────
const isActive = (item) => route.path.startsWith(item.path);

// ── Logout ────────────────────────────────────────────
const handleLogout = async () => {
  await auth.logout();
  router.push({ name: 'login' });
};

// ── Alert count ───────────────────────────────────────
const fetchAlertCount = async () => {
  try {
    const { data } = await api.get('/alerts/count');
    alertCount.value = data.total;
  } catch {}
};

// ── Close dropdown on outside click ──────────────────
const handleOutsideClick = (e) => {
  if (!e.target.closest('.user-menu')) {
    userDropdown.value = false;
  }
};

onMounted(() => {
  fetchAlertCount();
  document.addEventListener('click', handleOutsideClick);
});

onBeforeUnmount(() => {
  document.removeEventListener('click', handleOutsideClick);
});
</script>