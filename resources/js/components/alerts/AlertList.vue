<template>
  <div class="alert-list">

    <!-- ── Header ──────────────────────────────────────────────────── -->
    <div class="page-header">
      <div>
        <h1 class="page-title">Alertes d'expiration</h1>
        <p class="page-subtitle">Suivi des habilitations arrivant à expiration</p>
      </div>
      <div class="header-actions">
        <button class="btn-mark-all" @click="acknowledgeAll"
          :disabled="markingAll || nonAcknowledged.length === 0">
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
          <div class="summary-count">{{ critiques.length }}</div>
          <div class="summary-label">Critiques (≤ 7 jours)</div>
        </div>
      </div>
      <div class="summary-card warning">
        <div class="summary-icon" v-html="icons.clock"></div>
        <div class="summary-info">
          <div class="summary-count">{{ proches.length }}</div>
          <div class="summary-label">Proches (≤ 30 jours)</div>
        </div>
      </div>
      <div class="summary-card expired">
        <div class="summary-icon" v-html="icons.xCircle"></div>
        <div class="summary-info">
          <div class="summary-count">{{ expires.length }}</div>
          <div class="summary-label">Expirées</div>
        </div>
      </div>
      <div class="summary-card info">
        <div class="summary-icon" v-html="icons.bell"></div>
        <div class="summary-info">
          <div class="summary-count">{{ nonAcknowledged.length }}</div>
          <div class="summary-label">Non traitées</div>
        </div>
      </div>
    </div>

    <!-- ── Filters ─────────────────────────────────────────────────── -->
    <div class="filters-bar">

      <div class="filter-group">
        <label>Urgence</label>
        <div class="filter-tabs">
          <button
            v-for="tab in urgenceTabs" :key="tab.value"
            :class="['filter-tab', tab.cls, { active: filters.urgence === tab.value }]"
            @click="filters.urgence = tab.value">
            {{ tab.label }}
            <span class="tab-count">{{ tab.count }}</span>
          </button>
        </div>
      </div>

      <div class="filter-group">
        <label>Statut</label>
        <div class="filter-tabs">
          <button
            v-for="opt in statutOptions" :key="opt.value"
            :class="['filter-tab', { active: filters.statut === opt.value }]"
            @click="filters.statut = opt.value">
            {{ opt.label }}
            <span class="tab-count">{{ opt.count }}</span>
          </button>
        </div>
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
    <div class="empty-state" v-else-if="filtered.length === 0">
      <div class="empty-icon" v-html="icons.bellOff"></div>
      <h3>Aucune alerte</h3>
      <p v-if="filters.urgence !== 'all' || filters.statut !== '' || filters.search">
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
              <th>Statut</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            <tr
              v-for="row in filtered"
              :key="row.id"
              :class="['alert-row', urgenceRowClass(row), { 'is-vue': row.acknowledged }]"
            >
              <td>
                <div class="employee-cell">
                  <div class="employee-avatar">{{ initiales(row.employee) }}</div>
                  <div>
                    <div class="employee-name">
                      {{ row.employee?.prenom }} {{ row.employee?.nom }}
                    </div>
                    <div class="employee-meta">{{ row.employee?.matricule }}</div>
                  </div>
                </div>
              </td>
              <td><span class="hab-name">{{ row.habilitation?.nom }}</span></td>
              <td><span class="volet-badge">{{ row.habilitation?.volet?.nom }}</span></td>
              <td class="date-cell">{{ formatDate(row.date_expiration) }}</td>
              <td>
                <span :class="['jours-badge', joursClass(row.jours_restants)]">
                  {{ joursLabel(row.jours_restants) }}
                </span>
              </td>
              <td>
                <span :class="['urgence-badge', urgenceRowClass(row)]">
                  {{ urgenceLabel(row.jours_restants) }}
                </span>
              </td>
              <td>
                <span :class="['statut-badge', row.acknowledged ? 'vue' : 'active']">
                  {{ row.acknowledged ? 'Traité' : 'Non traité' }}
                </span>
              </td>
              <td>
                <button
                  v-if="!row.acknowledged"
                  class="btn-vue"
                  @click="acknowledgeOne(row)"
                  :disabled="row._marking"
                  title="Marquer comme traité"
                >
                  <span v-if="row._marking" class="spinner-sm"></span>
                  <span v-else v-html="icons.check"></span>
                </button>
                <span v-else class="already-vue" v-html="icons.checkDouble" title="Traité"></span>
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
const rows       = ref([]);
const loading    = ref(true);
const markingAll = ref(false);

const filters = reactive({
  urgence: 'all',   // 'all' | 'expired' | '7' | '30'
  statut:  '',      // '' | 'active' | 'acknowledged'
  search:  '',
});

// ── Icons ──────────────────────────────────────────────────────────────────
const icons = {
  fire:        `<svg xmlns="http://www.w3.org/2000/svg" width="22" height="22" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17.657 18.657A8 8 0 016.343 7.343S7 9 9 10c0-2 .5-5 2.986-7C14 5 16.09 5.777 17.656 7.343A7.975 7.975 0 0120 13a7.975 7.975 0 01-2.343 5.657z"/><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9.879 16.121A3 3 0 1012.015 11L11 14H9c0 .768.293 1.536.879 2.121z"/></svg>`,
  clock:       `<svg xmlns="http://www.w3.org/2000/svg" width="22" height="22" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>`,
  bell:        `<svg xmlns="http://www.w3.org/2000/svg" width="22" height="22" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9"/></svg>`,
  bellOff:     `<svg xmlns="http://www.w3.org/2000/svg" width="48" height="48" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M9.172 9.172a4 4 0 015.656 0M9.172 9.172L5 5m4.172 4.172L3 3m6.172 6.172A4 4 0 0112 8m0 0v.343M12 8a6 6 0 016 6v3l1 1M3 3l18 18M9 17v1a3 3 0 006 0v-1M4 17h16"/></svg>`,
  xCircle:     `<svg xmlns="http://www.w3.org/2000/svg" width="22" height="22" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2m7-2a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>`,
  check:       `<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M5 13l4 4L19 7"/></svg>`,
  checkDouble: `<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>`,
  search:      `<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"/></svg>`,
};

// ── Derived sets ───────────────────────────────────────────────────────────
const critiques       = computed(() => rows.value.filter(r => r.jours_restants >= 0 && r.jours_restants <= 7));
const proches         = computed(() => rows.value.filter(r => r.jours_restants > 7 && r.jours_restants <= 30));
const expires         = computed(() => rows.value.filter(r => r.jours_restants < 0));
const nonAcknowledged = computed(() => rows.value.filter(r => !r.acknowledged));

// ── Tab definitions ────────────────────────────────────────────────────────
const urgenceTabs = computed(() => [
  { value: 'all',     label: 'Toutes',     cls: '',             count: rows.value.length },
  { value: 'expired', label: 'Expirées',   cls: 'tab-expired',  count: expires.value.length },
  { value: '7',       label: '≤ 7 jours',  cls: 'tab-critical', count: critiques.value.length },
  { value: '30',      label: '≤ 30 jours', cls: 'tab-warning',  count: proches.value.length },
]);

const statutOptions = computed(() => [
  { value: '',             label: 'Toutes',       count: rows.value.length },
  { value: 'active',       label: 'Non traitées', count: nonAcknowledged.value.length },
  { value: 'acknowledged', label: 'Traitées',     count: rows.value.filter(r => r.acknowledged).length },
]);

// ── Filtered & sorted list ─────────────────────────────────────────────────
const filtered = computed(() => {
  let list = rows.value;

  if (filters.urgence === 'expired') {
    list = list.filter(r => r.jours_restants < 0);
  } else if (filters.urgence === '7') {
    list = list.filter(r => r.jours_restants >= 0 && r.jours_restants <= 7);
  } else if (filters.urgence === '30') {
    list = list.filter(r => r.jours_restants > 7 && r.jours_restants <= 30);
  }

  if (filters.statut === 'active') {
    list = list.filter(r => !r.acknowledged);
  } else if (filters.statut === 'acknowledged') {
    list = list.filter(r => r.acknowledged);
  }

  if (filters.search) {
    const s = filters.search.toLowerCase();
    list = list.filter(r =>
      r.employee?.nom?.toLowerCase().includes(s) ||
      r.employee?.prenom?.toLowerCase().includes(s) ||
      r.employee?.matricule?.toString().includes(s) ||
      r.habilitation?.nom?.toLowerCase().includes(s)
    );
  }

  // Non-acknowledged first, then by jours_restants ascending
  return [...list].sort((a, b) => {
    if (a.acknowledged !== b.acknowledged) return a.acknowledged ? 1 : -1;
    return a.jours_restants - b.jours_restants;
  });
});

// ── Helpers ────────────────────────────────────────────────────────────────
const joursLabel = (j) => {
  if (j < 0)   return 'Expiré';
  if (j === 0) return "Aujourd'hui";
  return `${j}j`;
};

const joursClass = (j) => {
  if (j < 0)   return 'expired';
  if (j <= 7)  return 'critical';
  if (j <= 30) return 'warning';
  return 'ok';
};

const urgenceRowClass = (row) => {
  const j = row.jours_restants;
  if (j < 0)   return 'row-expired';
  if (j <= 7)  return 'row-critical';
  if (j <= 30) return 'row-warning';
  return '';
};

const urgenceLabel = (j) => {
  if (j < 0)   return 'Expiré';
  if (j <= 7)  return 'Critique';
  if (j <= 30) return 'Proche';
  return 'Normal';
};

const formatDate = (d) =>
  d ? new Date(d).toLocaleDateString('fr-FR') : '—';

const initiales = (emp) => {
  if (!emp) return '?';
  return `${emp.prenom?.[0] ?? ''}${emp.nom?.[0] ?? ''}`.toUpperCase();
};

const resetFilters = () => {
  filters.urgence = 'all';
  filters.statut  = '';
  filters.search  = '';
};

// ── API ────────────────────────────────────────────────────────────────────
const fetchAlertes = async () => {
  loading.value = true;
  try {
    const { data } = await api.get('/employee-habilitations/alertes');
    rows.value = data.map(r => ({ ...r, _marking: false }));
  } catch (e) {
    console.error('Erreur chargement alertes:', e);
  } finally {
    loading.value = false;
  }
};

const acknowledgeOne = async (row) => {
  row._marking = true;
  try {
    await api.patch(`/employee-habilitations/${row.id}/acknowledge`);
    row.acknowledged = true;
  } catch (e) {
    console.error('Erreur acknowledge:', e);
  } finally {
    row._marking = false;
  }
};

const acknowledgeAll = async () => {
  if (nonAcknowledged.value.length === 0) return;
  markingAll.value = true;
  try {
    const ids = nonAcknowledged.value.map(r => r.id);
    await api.post('/employee-habilitations/acknowledge-bulk', { ids });
    rows.value.forEach(r => { r.acknowledged = true; });
  } catch (e) {
    console.error('Erreur acknowledge bulk:', e);
  } finally {
    markingAll.value = false;
  }
};

onMounted(fetchAlertes);
</script>