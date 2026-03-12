<template>
  <div class="attribution-list">

    <!-- ── Header ─────────────────────────────────────────────────── -->
    <div class="list-header">
      <div class="header-left">
        <h1 class="page-title">Associations</h1>
        <p class="page-subtitle">Habilitations attribuées aux employés</p>
      </div>
      <button class="btn-add" @click="$router.push({ name: 'attributions.create' })">
        <span v-html="icons.plus"></span>
        Nouvelle association
      </button>
    </div>

    <!-- ── Filters bar ─────────────────────────────────────────────── -->
    <div class="filters-bar">
      <div class="search-wrap">
        <span class="search-icon" v-html="icons.search"></span>
        <input
          v-model="search"
          type="text"
          placeholder="Rechercher par employé, matricule, habilitation..."
          class="search-input"
        />
      </div>
      <div class="filter-group">
        <select v-model="filterVolet" class="filter-select">
          <option value="">Tous les volets</option>
          <option v-for="v in volets" :key="v.id" :value="v.id">{{ v.nom }}</option>
        </select>
        <select v-model="filterType" class="filter-select">
          <option value="">Tous les types</option>
          <option value="initiale">Initiale</option>
          <option value="recyclage">Recyclage</option>
        </select>
        <select v-model="filterStatut" class="filter-select">
          <option value="">Tous les statuts</option>
          <option value="valide">Valide</option>
          <option value="expire">Expiré</option>
          <option value="bientot">Expire bientôt</option>
        </select>
      </div>
    </div>

    <!-- ── Stats strip ─────────────────────────────────────────────── -->
    <div class="stats-strip" v-if="!loading">
      <div class="stat-item">
        <span class="stat-num">{{ totalCount }}</span>
        <span class="stat-label">Total</span>
      </div>
      <div class="stat-sep"></div>
      <div class="stat-item green">
        <span class="stat-num">{{ valideCount }}</span>
        <span class="stat-label">Valides</span>
      </div>
      <div class="stat-sep"></div>
      <div class="stat-item orange">
        <span class="stat-num">{{ bientotCount }}</span>
        <span class="stat-label">Expirent bientôt</span>
      </div>
      <div class="stat-sep"></div>
      <div class="stat-item red">
        <span class="stat-num">{{ expireCount }}</span>
        <span class="stat-label">Expirés</span>
      </div>
    </div>

    <!-- ── Loading ─────────────────────────────────────────────────── -->
    <div class="loading-state" v-if="loading">
      <div class="spinner"></div>
      <span>Chargement des associations...</span>
    </div>

    <!-- ── Table ───────────────────────────────────────────────────── -->
    <div class="attr-table-card" v-else>
        <table class="attr-data-table">
          <thead>
            <tr>
              <th>Employé</th>
              <th>Habilitation</th>
              <th>Volet</th>
              <th>Organisme</th>
              <th>Date obtention</th>
              <th>Date expiration</th>
              <th>Aptitude médicale</th>
              <th>Type</th>
              <th>Statut</th>
            </tr>
          </thead>
          <tbody>
            <tr v-if="filtered.length === 0">
              <td colspan="9" class="empty-row">
                <div class="empty-state">
                  <span v-html="icons.emptyBox"></span>
                  <p>Aucune association trouvée</p>
                  <button class="btn-add-inline" @click="$router.push({ name: 'attributions.create' })">
                    Créer une association
                  </button>
                </div>
              </td>
            </tr>
            <tr v-for="item in filtered" :key="item.id" class="data-row">
              <td>
                <div class="emp-cell">
                  <div class="emp-avatar">{{ initiales(item.employee) }}</div>
                  <div>
                    <div class="emp-name">{{ item.employee?.prenom }} {{ item.employee?.nom }}</div>
                    <div class="emp-mat">{{ item.employee?.matricule }}</div>
                  </div>
                </div>
              </td>
              <td class="hab-name">{{ item.habilitation?.nom }}</td>
              <td>
                <span class="volet-tag">{{ item.habilitation?.volet?.nom }}</span>
              </td>
              <td class="organisme-cell">{{ item.organisme_formation || '—' }}</td>
              <td class="date-cell">{{ formatDate(item.date_obtention) }}</td>
              <td class="date-cell">
                <span :class="['exp-date', expirationClass(item)]">
                  {{ formatDate(item.date_expiration) }}
                </span>
              </td>
              <td class="date-cell">{{ formatDate(item.date_aptitude_medicale) || '—' }}</td>
              <td>
                <span :class="['type-badge', item.type]">{{ item.type }}</span>
              </td>
              <td>
                <span :class="['statut-badge', statutClass(item)]">
                  {{ statutLabel(item) }}
                </span>
              </td>
            </tr>
          </tbody>
        </table>

      <!-- Pagination info -->
      <div class="table-footer" v-if="filtered.length > 0">
        <span class="result-count">{{ filtered.length }} résultat(s)</span>
      </div>
    </div>

  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue';
import api from '@/services/api';
import '@/../css/components/attributions/attributions.css';

// ── State ──────────────────────────────────────────────────────────────────
const attributions = ref([]);
const volets       = ref([]);
const loading      = ref(true);

const search       = ref('');
const filterVolet  = ref('');
const filterType   = ref('');
const filterStatut = ref('');

// ── Icons ──────────────────────────────────────────────────────────────────
const icons = {
  plus:     `<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"/></svg>`,
  search:   `<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"/></svg>`,
  emptyBox: `<svg xmlns="http://www.w3.org/2000/svg" width="40" height="40" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4"/></svg>`,
};

// ── Helpers ────────────────────────────────────────────────────────────────
const initiales = (emp) => {
  if (!emp) return '?';
  return `${emp.prenom?.[0] ?? ''}${emp.nom?.[0] ?? ''}`.toUpperCase();
};

const formatDate = (d) => {
  if (!d) return null;
  return new Date(d).toLocaleDateString('fr-FR');
};

const joursRestants = (item) => {
  if (!item.date_expiration) return null;
  const diff = new Date(item.date_expiration) - new Date();
  return Math.ceil(diff / (1000 * 60 * 60 * 24));
};

const statutClass = (item) => {
  const j = joursRestants(item);
  if (j === null) return '';
  if (j < 0)   return 'expire';
  if (j <= 30) return 'bientot';
  return 'valide';
};

const statutLabel = (item) => {
  const j = joursRestants(item);
  if (j === null) return '—';
  if (j < 0)   return 'Expiré';
  if (j <= 30) return `${j}j restants`;
  return 'Valide';
};

const expirationClass = (item) => {
  const j = joursRestants(item);
  if (j === null) return '';
  if (j < 0)   return 'text-red';
  if (j <= 30) return 'text-orange';
  return '';
};

// ── Computed filters ───────────────────────────────────────────────────────
const filtered = computed(() => {
  let list = attributions.value;

  if (search.value) {
    const s = search.value.toLowerCase();
    list = list.filter(a =>
      `${a.employee?.prenom} ${a.employee?.nom}`.toLowerCase().includes(s) ||
      a.employee?.matricule?.toString().includes(s) ||
      a.habilitation?.nom?.toLowerCase().includes(s) ||
      a.organisme_formation?.toLowerCase().includes(s)
    );
  }

  if (filterVolet.value) {
    list = list.filter(a => a.habilitation?.volet?.id === filterVolet.value);
  }

  if (filterType.value) {
    list = list.filter(a => a.type === filterType.value);
  }

  if (filterStatut.value) {
    list = list.filter(a => statutClass(a) === filterStatut.value);
  }
console.log('Filtered list:', list);
  return list;
});

// ── Stats ──────────────────────────────────────────────────────────────────
const totalCount  = computed(() => filtered.value.length);
const valideCount = computed(() => filtered.value.filter(a => statutClass(a) === 'valide').length);
const bientotCount= computed(() => filtered.value.filter(a => statutClass(a) === 'bientot').length);
const expireCount = computed(() => filtered.value.filter(a => statutClass(a) === 'expire').length);

// ── Data fetching ──────────────────────────────────────────────────────────
const fetchData = async () => {
  loading.value = true;
  try {
    const [attribRes, voletRes] = await Promise.all([
      api.get('/employee-habilitations'),
      api.get('/volets'),
    ]);
    attributions.value = attribRes.data;
    volets.value       = voletRes.data;
  } finally {
    loading.value = false;
  }
};

onMounted(fetchData);
</script>