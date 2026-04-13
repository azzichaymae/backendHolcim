<template>
  <div class="alert-list">

    <!-- Header -->
    <div class="page-header">
      <div>
        <h1 class="page-title">Alertes d'expiration</h1>
        <p class="page-subtitle">Suivi des habilitations arrivant à expiration</p>
      </div>
    </div>

    <!-- Summary cards -->
    <div class="summary-grid">
      <div class="summary-card urgent">
        <div class="summary-icon" v-html="icons.fire"></div>
        <div class="summary-info">
          <div class="summary-count">{{ expires.length }}</div>
          <div class="summary-label">Expirées</div>
        </div>
      </div>
      <div class="summary-card warning">
        <div class="summary-icon" v-html="icons.fire"></div>
        <div class="summary-info">
          <div class="summary-count">{{ critiques.length }}</div>
          <div class="summary-label">Critiques (≤ 7 jours)</div>
        </div>
      </div>
      <div class="summary-card info">
        <div class="summary-icon" v-html="icons.clock"></div>
        <div class="summary-info">
          <div class="summary-count">{{ proches.length }}</div>
          <div class="summary-label">Entre 8 et 30 jours</div>
        </div>
      </div>
    </div>

    <!-- Filters -->
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
      <div class="search-box">
        <span v-html="icons.search" class="search-icon"></span>
        <input v-model="filters.search" type="text"
          placeholder="Rechercher un employé ou habilitation..." />
      </div>
    </div>

    <!-- Loading -->
    <div class="loading-state" v-if="loading">
      <div class="loader"></div>
      <p>Chargement des alertes...</p>
    </div>

    <!-- Empty -->
    <div class="empty-state" v-else-if="filtered.length === 0">
      <div class="empty-icon" v-html="icons.bellOff"></div>
      <h3>Aucune alerte</h3>
      <p v-if="filters.urgence !== 'all' || filters.search">
        Aucune alerte ne correspond à vos filtres.
        <button class="link-btn" @click="resetFilters">Réinitialiser</button>
      </p>
      <p v-else>Toutes les habilitations sont à jour.</p>
    </div>

    <!-- Table -->
    <div class="table-card" v-else>
      <div class="table-scroll">
        <table class="data-table">
          <thead>
            <tr>
              <th>Employé</th>
              <th>Habilitation</th>
              <th>Catégorie</th>
              <th>Date expiration</th>
              <th>Jours restants</th>
              <th>Urgence</th>
              <th>Action</th>
            </tr>
          </thead>
          <tbody>
            <template v-for="group in groupedByEmployee" :key="group.employee.id">

              <!-- Employee header row -->
              <tr class="employee-group-header"
                @click="toggleEmployee(group.employee.id)"
                style="cursor:pointer">
                <td colspan="7">
                  <div class="employee-cell">
                    <span class="expand-arrow">
                      {{ expandedEmployees.has(group.employee.id) ? '▾' : '▸' }}
                    </span>
                    <div class="employee-avatar">{{ initiales(group.employee) }}</div>
                    <div>
                      <div class="employee-name">
                        {{ group.employee.prenom }} {{ group.employee.nom }}
                      </div>
                      <div class="employee-meta">
                        {{ group.employee.matricule }} —
                        {{ group.habilitations.length }} habilitation(s)
                      </div>
                    </div>
                    <span :class="['urgence-badge', worstUrgence(group.habilitations)]"
                      style="margin-left:auto">
                      {{ worstUrgenceLabel(group.habilitations) }}
                    </span>
                  </div>
                </td>
              </tr>

              <!-- Habilitation rows -->
              <template v-if="expandedEmployees.has(group.employee.id)">
                <tr
                  v-for="row in group.habilitations"
                  :key="row.id"
                  :class="['alert-row', 'is-sub-row', urgenceRowClass(row)]"
                >
                  <td></td>
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
                  <!-- Navigate to attribution to update it -->
                  <td>
                    <button
                      class="filter-tab"
                      @click="goToAttribution(row)"
                      title="Mettre à jour l'attribution">
                      <span v-html="icons.edit"></span>
                      
                    </button>
                  </td>
                </tr>
              </template>

            </template>
          </tbody>
        </table>
      </div>
    </div>

  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue';
import { useRouter } from 'vue-router';
import api from '@/services/api';
import '@/../css/components/alerts/alert-list.css';


const router = useRouter();
const rows    = ref([]);
const loading = ref(true);

const filters = reactive({
  urgence: 'all',
  search:  '',
});
const icons = {
  edit:       `<svg xmlns="http://www.w3.org/2000/svg" width="22" height="22" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"/></svg>`,
  fire:        `<svg xmlns="http://www.w3.org/2000/svg" width="22" height="22" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17.657 18.657A8 8 0 016.343 7.343S7 9 9 10c0-2 .5-5 2.986-7C14 5 16.09 5.777 17.656 7.343A7.975 7.975 0 0120 13a7.975 7.975 0 01-2.343 5.657z"/><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9.879 16.121A3 3 0 1012.015 11L11 14H9c0 .768.293 1.536.879 2.121z"/></svg>`,
  clock:       `<svg xmlns="http://www.w3.org/2000/svg" width="22" height="22" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>`,
  bell:        `<svg xmlns="http://www.w3.org/2000/svg" width="22" height="22" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9"/></svg>`,
  bellOff:     `<svg xmlns="http://www.w3.org/2000/svg" width="48" height="48" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M9.172 9.172a4 4 0 015.656 0M9.172 9.172L5 5m4.172 4.172L3 3m6.172 6.172A4 4 0 0112 8m0 0v.343M12 8a6 6 0 016 6v3l1 1M3 3l18 18M9 17v1a3 3 0 006 0v-1M4 17h16"/></svg>`,
  xCircle:     `<svg xmlns="http://www.w3.org/2000/svg" width="22" height="22" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2m7-2a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>`,
  check:       `<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M5 13l4 4L19 7"/></svg>`,
  checkDouble: `<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>`,
  search:      `<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"/></svg>`,
};
const expandedEmployees = ref(new Set());

// ── Derived ────────────────────────────────────────────────────────────────
const expires  = computed(() => rows.value.filter(r => r.jours_restants < 0));
const critiques = computed(() => rows.value.filter(r => r.jours_restants >= 0 && r.jours_restants <= 7));
const proches   = computed(() => rows.value.filter(r => r.jours_restants > 7 && r.jours_restants <= 30));

const urgenceTabs = computed(() => [
  { value: 'all',     label: 'Toutes',       cls: '',             count: rows.value.length },
  { value: 'expired', label: 'Expirées',     cls: 'tab-expired',  count: expires.value.length },
  { value: '7',       label: '≤ 7 jours',    cls: 'tab-critical', count: critiques.value.length },
  { value: '30',      label: '8 – 30 jours', cls: 'tab-warning',  count: proches.value.length },
]);

const filtered = computed(() => {
  let list = rows.value;

  if (filters.urgence === 'expired')     list = list.filter(r => r.jours_restants < 0);
  else if (filters.urgence === '7')      list = list.filter(r => r.jours_restants >= 0 && r.jours_restants <= 7);
  else if (filters.urgence === '30')     list = list.filter(r => r.jours_restants > 7 && r.jours_restants <= 30);

  if (filters.search) {
    const s = filters.search.toLowerCase();
    list = list.filter(r =>
      r.employee?.nom?.toLowerCase().includes(s) ||
      r.employee?.prenom?.toLowerCase().includes(s) ||
      r.employee?.matricule?.toString().includes(s) ||
      r.habilitation?.nom?.toLowerCase().includes(s)
    );
  }

  return [...list].sort((a, b) => a.jours_restants - b.jours_restants);
});

// Group filtered rows by employee
const groupedByEmployee = computed(() => {
  const map = new Map();
  filtered.value.forEach(row => {
    const key = row.employee.id;
    if (!map.has(key)) map.set(key, { employee: row.employee, habilitations: [] });
    map.get(key).habilitations.push(row);
  });
  return [...map.values()];
});

// ── Expand/collapse ────────────────────────────────────────────────────────
const toggleEmployee = (id) => {
  if (expandedEmployees.value.has(id)) expandedEmployees.value.delete(id);
  else expandedEmployees.value.add(id);
  // trigger reactivity
  expandedEmployees.value = new Set(expandedEmployees.value);
};

// ── Helpers ────────────────────────────────────────────────────────────────
const worstUrgence = (habilitations) => {
  const min = Math.min(...habilitations.map(r => r.jours_restants));
  if (min < 0)   return 'row-expired';
  if (min <= 7)  return 'row-critical';
  if (min <= 30) return 'row-warning';
  return '';
};

const worstUrgenceLabel = (habilitations) => {
  const min = Math.min(...habilitations.map(r => r.jours_restants));
  if (min < 0)   return 'Expiré';
  if (min <= 7)  return 'Critique';
  if (min <= 30) return 'Proche';
  return 'Normal';
};

const joursLabel    = (j) => j < 0 ? 'Expiré' : j === 0 ? "Aujourd'hui" : `${j}j`;
const joursClass    = (j) => j < 0 ? 'expired' : j <= 7 ? 'critical' : j <= 30 ? 'warning' : 'ok';
const urgenceRowClass = (row) => {
  const j = row.jours_restants;
  if (j < 0)   return 'row-expired';
  if (j <= 7)  return 'row-critical';
  if (j <= 30) return 'row-warning';
  return '';
};
const urgenceLabel  = (j) => j < 0 ? 'Expiré' : j <= 7 ? 'Critique' : j <= 30 ? 'Proche' : 'Normal';
const formatDate    = (d) => d ? new Date(d).toLocaleDateString('fr-FR') : '—';
const initiales     = (emp) => `${emp?.prenom?.[0] ?? ''}${emp?.nom?.[0] ?? ''}`.toUpperCase();
const resetFilters  = () => { filters.urgence = 'all'; filters.search = ''; };

// Navigate to the attribution update page
const goToAttribution = (row) => {
  //router.push({ name: 'employee-habilitations.edit', params: { id: row.attribution } });
};

// ── API ────────────────────────────────────────────────────────────────────
const fetchAlertes = async () => {
  loading.value = true;
  try {
    const { data } = await api.get('/employee-habilitations/alertes');
    rows.value = data;
    data.forEach(r => expandedEmployees.value.add(r.employee.id));
    expandedEmployees.value = new Set(expandedEmployees.value);
  } catch (e) {
    console.error('Erreur chargement alertes:', e);
  } finally {
    loading.value = false;
  }
};

onMounted(fetchAlertes);
</script>
