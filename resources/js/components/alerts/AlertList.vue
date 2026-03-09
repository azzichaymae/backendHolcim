<template>
  <div class="alert-list">

    <!-- ── Header ──────────────────────────────────────────────────── -->
    <div class="page-header">
      <div>
        <h1 class="page-title">Alertes d'expiration</h1>
        <p class="page-subtitle">Suivi des habilitations arrivant à expiration</p>
      </div>
      <div class="header-actions">
        <button class="btn-mark-all" @click="marquerToutesVues"
          :disabled="markingAll || alertesNonVues.length === 0">
          <span v-if="markingAll" class="spinner-sm"></span>
          <span v-else v-html="icons.check"></span>
          Tout marquer comme vu
        </button>
      </div>
    </div>

    <!-- ── Summary cards ───────────────────────────────────────────── -->
    <div class="summary-grid">
      <div class="summary-card urgent">
        <div class="summary-icon" v-html="icons.fire"></div>
        <div class="summary-info">
          <div class="summary-count">{{ alertes7j.length }}</div>
          <div class="summary-label">Critiques (≤ 7 jours)</div>
        </div>
      </div>
      <div class="summary-card warning">
        <div class="summary-icon" v-html="icons.clock"></div>
        <div class="summary-info">
          <div class="summary-count">{{ alertes30j.length }}</div>
          <div class="summary-label">À surveiller (≤ 30 jours)</div>
        </div>
      </div>
      <div class="summary-card info">
        <div class="summary-icon" v-html="icons.bell"></div>
        <div class="summary-info">
          <div class="summary-count">{{ alertesNonVues.length }}</div>
          <div class="summary-label">Non traitées</div>
        </div>
      </div>
      <div class="summary-card neutral">
        <div class="summary-icon" v-html="icons.list"></div>
        <div class="summary-info">
          <div class="summary-count">{{ alertesFiltrees.length }}</div>
          <div class="summary-label">Total affiché</div>
        </div>
      </div>
    </div>

    <!-- ── Filters ─────────────────────────────────────────────────── -->
    <div class="filters-bar">
      <div class="filter-group">
        <label>Statut</label>
        <div class="filter-tabs">
          <button v-for="opt in statutOptions" :key="opt.value"
            :class="['filter-tab', { active: filters.statut === opt.value }]"
            @click="filters.statut = opt.value">
            {{ opt.label }}
            <span class="tab-count" v-if="opt.count !== null">{{ opt.count }}</span>
          </button>
        </div>
      </div>

      <div class="filter-group">
        <label>Urgence</label>
        <select v-model="filters.urgence" class="filter-select">
          <option value="">Toutes</option>
          <option value="7">≤ 7 jours</option>
          <option value="30">≤ 30 jours</option>
        </select>
      </div>

      <div class="search-box">
        <span v-html="icons.search" class="search-icon"></span>
        <input v-model="filters.search" type="text"
          placeholder="Rechercher un employé ou habilitation..." />
      </div>
    </div>

    <!-- ── Loading ─────────────────────────────────────────────────── -->
    <div class="loading-state" v-if="loading">
      <div class="loader"></div>
      <p>Chargement des alertes...</p>
    </div>

    <!-- ── Empty ───────────────────────────────────────────────────── -->
    <div class="empty-state" v-else-if="alertesFiltrees.length === 0">
      <div class="empty-icon" v-html="icons.bellOff"></div>
      <h3>Aucune alerte</h3>
      <p v-if="filters.statut !== '' || filters.urgence !== '' || filters.search">
        Aucune alerte ne correspond à vos filtres.
        <button class="link-btn" @click="resetFilters">Réinitialiser</button>
      </p>
      <p v-else>Toutes les habilitations sont à jour.</p>
    </div>

    <!-- ── Table ───────────────────────────────────────────────────── -->
    <div class="table-card" v-else>
      <div class="table-scroll">
        <table class="data-table">
          <thead>
            <tr>
              <th>Employé</th>
              <th>Habilitation</th>
              <th>Volet</th>
              <th>Date expiration</th>
              <th>Jours restants</th>
              <th>Urgence</th>
              <th>Statut alerte</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="alerte in alertesFiltrees" :key="alerte.id"
              :class="['alert-row', urgenceClass(alerte), { 'is-vue': alerte.statut === 'vue' }]">

              <!-- Employé -->
              <td>
                <div class="employee-cell">
                  <div class="employee-avatar">
                    {{ initiales(alerte.employee_habilitation?.employee) }}
                  </div>
                  <div>
                    <div class="employee-name">
                      {{ alerte.employee_habilitation?.employee?.prenom }}
                      {{ alerte.employee_habilitation?.employee?.nom }}
                    </div>
                    <div class="employee-meta">
                      {{ alerte.employee_habilitation?.employee?.matricule }}
                    </div>
                  </div>
                </div>
              </td>

              <!-- Habilitation -->
              <td>
                <span class="hab-name">
                  {{ alerte.employee_habilitation?.habilitation?.nom }}
                </span>
              </td>

              <!-- Volet -->
              <td>
                <span class="volet-badge">
                  {{ alerte.employee_habilitation?.habilitation?.volet?.nom }}
                </span>
              </td>

              <!-- Date expiration -->
              <td class="date-cell">
                {{ formatDate(alerte.employee_habilitation?.date_expiration) }}
              </td>

              <!-- Jours restants -->
              <td>
                <span :class="['jours-badge', joursClass(alerte)]">
                  {{ joursRestants(alerte.employee_habilitation?.date_expiration) }}
                </span>
              </td>

              <!-- Urgence -->
              <td>
                <span :class="['urgence-badge', urgenceClass(alerte)]">
                  {{ urgenceLabel(alerte) }}
                </span>
              </td>

              <!-- Statut alerte -->
              <td>
                <span :class="['statut-badge', alerte.statut === 'vue' ? 'vue' : 'active']">
                  {{ alerte.statut === 'vue' ? 'Vu' : 'Non traité' }}
                </span>
              </td>

              <!-- Actions -->
              <td>
                <button v-if="alerte.statut !== 'vue'"
                  class="btn-vue"
                  @click="marquerVue(alerte)"
                  :disabled="alerte._marking"
                  title="Marquer comme vu">
                  <span v-if="alerte._marking" class="spinner-sm"></span>
                  <span v-else v-html="icons.check"></span>
                </button>
                <span v-else class="already-vue" v-html="icons.checkDouble" title="Déjà traité"></span>
              </td>

            </tr>
          </tbody>
        </table>
      </div>
    </div>

  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue';
import api from '@/services/api';
import '@/../css/components/alerts/alert-list.css';


// ── State ──────────────────────────────────────────────────────────────────
const alertes  = ref([]);
const loading  = ref(true);
const markingAll = ref(false);

const filters = reactive({
  statut:  '',
  urgence: '',
  search:  '',
});

// ── Icons ──────────────────────────────────────────────────────────────────
const icons = {
  fire:    `<svg xmlns="http://www.w3.org/2000/svg" width="22" height="22" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17.657 18.657A8 8 0 016.343 7.343S7 9 9 10c0-2 .5-5 2.986-7C14 5 16.09 5.777 17.656 7.343A7.975 7.975 0 0120 13a7.975 7.975 0 01-2.343 5.657z"/><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9.879 16.121A3 3 0 1012.015 11L11 14H9c0 .768.293 1.536.879 2.121z"/></svg>`,
  clock:   `<svg xmlns="http://www.w3.org/2000/svg" width="22" height="22" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>`,
  bell:    `<svg xmlns="http://www.w3.org/2000/svg" width="22" height="22" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9"/></svg>`,
  bellOff: `<svg xmlns="http://www.w3.org/2000/svg" width="48" height="48" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M9.172 9.172a4 4 0 015.656 0M9.172 9.172L5 5m4.172 4.172L3 3m6.172 6.172A4 4 0 0112 8m0 0v.343M12 8a6 6 0 016 6v3l1 1M3 3l18 18M9 17v1a3 3 0 006 0v-1M4 17h16"/></svg>`,
  list:    `<svg xmlns="http://www.w3.org/2000/svg" width="22" height="22" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 10h16M4 14h16M4 18h16"/></svg>`,
  check:   `<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M5 13l4 4L19 7"/></svg>`,
  checkDouble: `<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>`,
  search:  `<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"/></svg>`,
};

// ── Computed ───────────────────────────────────────────────────────────────
const alertesNonVues = computed(() =>
  alertes.value.filter(a => a.statut !== 'vue')
);

const alertes7j = computed(() =>
  alertes.value.filter(a => {
    const j = joursRestantsNum(a.employee_habilitation?.date_expiration);
    return j !== null && j <= 7;
  })
);

const alertes30j = computed(() =>
  alertes.value.filter(a => {
    const j = joursRestantsNum(a.employee_habilitation?.date_expiration);
    return j !== null && j <= 30;
  })
);

const statutOptions = computed(() => [
  { value: '',       label: 'Toutes',       count: alertes.value.length },
  { value: 'active', label: 'Non traitées', count: alertesNonVues.value.length },
  { value: 'vue',    label: 'Vues',         count: alertes.value.filter(a => a.statut === 'vue').length },
]);

const alertesFiltrees = computed(() => {
  let list = alertes.value;

  if (filters.statut) {
    list = list.filter(a => a.statut === filters.statut);
  }

  if (filters.urgence) {
    const max = parseInt(filters.urgence);
    list = list.filter(a => {
      const j = joursRestantsNum(a.employee_habilitation?.date_expiration);
      return j !== null && j <= max;
    });
  }

  if (filters.search) {
    const s = filters.search.toLowerCase();
    list = list.filter(a => {
      const emp = a.employee_habilitation?.employee;
      const hab = a.employee_habilitation?.habilitation;
      return (
        emp?.nom?.toLowerCase().includes(s) ||
        emp?.prenom?.toLowerCase().includes(s) ||
        emp?.matricule?.toLowerCase().includes(s) ||
        hab?.nom?.toLowerCase().includes(s)
      );
    });
  }

  // Sort: non-vues first, then by jours restants ascending
  return list.sort((a, b) => {
    if (a.statut !== b.statut) {
      return a.statut === 'vue' ? 1 : -1;
    }
    const ja = joursRestantsNum(a.employee_habilitation?.date_expiration) ?? 9999;
    const jb = joursRestantsNum(b.employee_habilitation?.date_expiration) ?? 9999;
    return ja - jb;
  });
});

// ── Helpers ────────────────────────────────────────────────────────────────
const joursRestantsNum = (dateExp) => {
  if (!dateExp) return null;
  const diff = Math.ceil(
    (new Date(dateExp) - new Date()) / (1000 * 60 * 60 * 24)
  );
  return diff;
};

const joursRestants = (dateExp) => {
  const j = joursRestantsNum(dateExp);
  if (j === null) return '—';
  if (j < 0)  return 'Expiré';
  if (j === 0) return 'Aujourd\'hui';
  return `${j}j`;
};

const joursClass = (alerte) => {
  const j = joursRestantsNum(alerte.employee_habilitation?.date_expiration);
  if (j === null) return '';
  if (j <= 0)  return 'expired';
  if (j <= 7)  return 'critical';
  if (j <= 30) return 'warning';
  return 'ok';
};

const urgenceClass = (alerte) => {
  const j = joursRestantsNum(alerte.employee_habilitation?.date_expiration);
  if (j === null) return '';
  if (j <= 0)  return 'row-expired';
  if (j <= 7)  return 'row-critical';
  if (j <= 30) return 'row-warning';
  return '';
};

const urgenceLabel = (alerte) => {
  const j = joursRestantsNum(alerte.employee_habilitation?.date_expiration);
  if (j === null) return '—';
  if (j <= 0)  return 'Expiré';
  if (j <= 7)  return 'Critique';
  if (j <= 30) return 'Proche';
  return 'Normal';
};

const formatDate = (date) => {
  if (!date) return '—';
  return new Date(date).toLocaleDateString('fr-FR');
};

const initiales = (emp) => {
  if (!emp) return '?';
  return `${(emp.prenom?.[0] ?? '')}${(emp.nom?.[0] ?? '')}`.toUpperCase();
};

const resetFilters = () => {
  filters.statut  = '';
  filters.urgence = '';
  filters.search  = '';
};

// ── API calls ──────────────────────────────────────────────────────────────
const fetchAlertes = async () => {
  loading.value = true;
  try {
    const { data } = await api.get('/alerts');
    alertes.value = data.map(a => ({ ...a, _marking: false }));
  } catch (e) {
    console.error('Erreur chargement alertes:', e);
  } finally {
    loading.value = false;
  }
};

const marquerVue = async (alerte) => {
  alerte._marking = true;
  try {
    await api.patch(`/alerts/${alerte.id}/vue`);
    alerte.statut = 'vue';
  } catch (e) {
    console.error('Erreur marquer vue:', e);
  } finally {
    alerte._marking = false;
  }
};

const marquerToutesVues = async () => {
  const nonVues = alertesNonVues.value;
  if (nonVues.length === 0) return;
  markingAll.value = true;
  try {
    await Promise.all(nonVues.map(a => api.patch(`/alerts/${a.id}/vue`)));
    nonVues.forEach(a => { a.statut = 'vue'; });
  } catch (e) {
    console.error('Erreur marquer toutes:', e);
  } finally {
    markingAll.value = false;
  }
};

onMounted(fetchAlertes);
</script>