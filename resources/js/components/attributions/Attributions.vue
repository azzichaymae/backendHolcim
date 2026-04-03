<template>
  <div class="attribution-list">

    <!-- ── Header ─────────────────────────────────────────────────── -->
    <div class="list-header">
      <div class="header-left">
        <h1 class="page-title">Associations</h1>
        <p class="page-subtitle">Habilitations attribuées aux employés</p>
      </div>
      <button class="btn-add" v-if="!isManager" @click="$router.push({ name: 'attributions.create' })">
        <span v-html="icons.plus"></span>
        Nouvelle association
      </button>
    </div>

    <!-- ── Manager tabs ────────────────────────────────────────────── -->
    <div class="mgr-tabs" v-if="isManager">
      <button class="mgr-tab" :class="{ active: mgrTab === 'equipe' }" @click="switchMgrTab('equipe')">
        <span v-html="icons.users"></span>
        Mon équipe
      </button>
      <button class="mgr-tab" :class="{ active: mgrTab === 'recherche' }" @click="switchMgrTab('recherche')">
        <span v-html="icons.search"></span>
        Recherche globale
      </button>
    </div>

    <!-- ══════════════════════════════════════════════════════════════ -->
    <!-- MANAGER — Mon équipe tab                                      -->
    <!-- ══════════════════════════════════════════════════════════════ -->
    <template v-if="isManager && mgrTab === 'equipe'">
      <div class="loading-state" v-if="loadingEquipe">
        <div class="spinner"></div>
        <span>Chargement de votre équipe...</span>
      </div>
      <div class="empty-state" v-else-if="equipe.length === 0">
        <p>Aucun employé dans votre service.</p>
      </div>
      <div class="cards-container" v-else>
        <div v-for="emp in equipe" :key="emp.id" class="employee-card">

          <!-- Header -->
          <div class="card-header" @click="toggleEquipe(emp.id)">
            <div class="emp-info">
              <div>
                <div class="emp-name">{{ emp.prenom }} {{ emp.nom }}</div>
                <div class="emp-mat">Matricule: {{ emp.matricule ?? 'ST' }}</div>
              </div>
            </div>
            <div class="card-actions">
              <div class="mgr-emp-stats">
                <span class="mgr-stat green">{{ mgrValidCount(emp) }} valides</span>
                <span class="mgr-stat red" v-if="mgrExpiredCount(emp)">{{ mgrExpiredCount(emp) }} expirées</span>
                <span class="mgr-stat orange" v-if="mgrSoonCount(emp)">{{ mgrSoonCount(emp) }} bientôt</span>
              </div>
              <span class="hab-count">{{ emp.employee_habilitations?.length ?? 0 }} habilitation(s)</span>
              <span :class="['arrow', openEquipe[emp.id] ? 'open' : '']">▼</span>
            </div>
          </div>

          <!-- Body -->
          <transition name="collapse">
            <div v-if="openEquipe[emp.id]" class="card-body">
              <div class="mgr-no-hab" v-if="!emp.employee_habilitations?.length">
                Aucune habilitation.
              </div>
              <table class="attr-data-table" v-else>
                <thead>
                  <tr>
                    <th>Habilitation</th>
                    <th>Volet</th>
                    <th>Organisme</th>
                    <th>Date obtention</th>
                    <th>Date expiration</th>
                    <th>Type</th>
                    <th>Statut</th>
                    <th>Validation</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="eh in emp.employee_habilitations" :key="eh.id" class="data-row">
                    <td class="hab-name">{{ eh.habilitation?.nom }}</td>
                    <td><span class="volet-tag">{{ eh.habilitation?.volet?.nom }}</span></td>
                    <td class="organisme-cell">{{ eh.organisme_formation || '—' }}</td>
                    <td class="date-cell">{{ formatDate(eh.date_obtention) }}</td>
                    <td class="date-cell">
                      <span :class="['exp-date', expirationClass(eh)]">{{ formatDate(eh.date_expiration) }}</span>
                    </td>
                    <td><span :class="['type-badge', eh.type]">{{ eh.type }}</span></td>
                    <td><span :class="['statut-badge', statutClass(eh)]">{{ statutLabel(eh) }}</span></td>
                    <td>
                      <span v-if="eh.validation_statut === 'non_soumis'" class="valid-badge non-soumis">Non soumis</span>
                      <span v-else-if="eh.validation_statut === 'en_cours'" class="valid-badge en-cours">⏳ En cours</span>
                      <span v-else-if="eh.validation_statut === 'valide'" class="valid-badge valide">✓ Validé</span>
                      <span v-else-if="eh.validation_statut === 'refuse'" class="valid-badge refuse">✗ Refusé</span>
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>
          </transition>

        </div>
      </div>
    </template>

    <!-- ══════════════════════════════════════════════════════════════ -->
    <!-- MANAGER — Recherche globale tab                               -->
    <!-- ══════════════════════════════════════════════════════════════ -->
   <template v-if="isManager && mgrTab === 'recherche'">
  <div class="mgr-cascade">

    <!-- Step 1: Volet -->
    <div class="mgr-cascade-row">
      <div class="mgr-cascade-step">
        <label class="mgr-step-label">
          <span class="mgr-step-num">1</span>
          Catégorie (Volet)
        </label>
        <select v-model="cascadeVolet" @change="onCascadeVoletChange" class="filter-select mgr-select">
          <option value="">Sélectionner une catégorie...</option>
          <option v-for="v in mgrVolets" :key="v.id" :value="v.id">{{ v.nom }}</option>
        </select>
      </div>

      <!-- Step 2: Habilitation -->
      <div class="mgr-cascade-step">
        <label class="mgr-step-label">
          <span class="mgr-step-num">2</span>
          Habilitation
        </label>
        <select v-model="cascadeHab" @change="onCascadeHabChange"
          class="filter-select mgr-select"
          :disabled="!cascadeVolet">
          <option value="">{{ cascadeVolet ? 'Sélectionner une habilitation...' : '— Sélectionnez d\'abord un volet —' }}</option>
          <option v-for="h in cascadeHabilitations" :key="h.id" :value="h.id">{{ h.nom }}</option>
        </select>
      </div>
    </div>

    <!-- Loading -->
    <div class="loading-state" v-if="loadingMgrSearch">
      <div class="spinner"></div>
      <span>Chargement...</span>
    </div>

    <!-- Results -->
    <div v-else-if="cascadeResults.length" class="employee-card" style="margin-top:16px">
      <div class="mgr-result-header">
        <span class="mgr-result-title">{{ cascadeResults.length }} employé(s) habilité(s)</span>
        <div class="mgr-result-stats">
          <span class="mgr-stat green">{{ cascadeResults.filter(e => e.statut === 'valide').length }} valides</span>
          <span class="mgr-stat red">{{ cascadeResults.filter(e => e.statut === 'expirée').length }} expirés</span>
        </div>
      </div>
      <div class="mgr-result-list">
        <div v-for="emp in cascadeResults" :key="emp.matricule" class="mgr-result-row">
          <div class="emp-avatar-circle" style="width:32px;height:32px;font-size:0.72rem">
            {{ emp.nom_complet.split(' ').map(w => w[0]).slice(0,2).join('') }}
          </div>
          <div class="mgr-result-emp">
            <span class="emp-name">{{ emp.nom_complet }}</span>
            <span class="mgr-result-service">· {{ emp.service }}</span>
          </div>
          <span class="emp-mat">Mat. {{ emp.matricule ?? 'ST' }}</span>
          <span :class="['statut-badge', emp.statut === 'valide' ? 'valide' : 'expire']">
            {{ emp.statut }}
          </span>
        </div>
      </div>
    </div>

    <!-- Empty -->
    <div class="empty-state" v-else-if="cascadeHab && !loadingMgrSearch">
      <p>Aucun employé trouvé pour cette habilitation.</p>
    </div>

    <!-- Hint -->
    <div class="mgr-search-hint" v-else-if="!cascadeHab">
      <span v-html="icons.search"></span>
      Sélectionnez un volet puis une habilitation pour voir les employés.
    </div>

  </div>
</template>

    <!-- ══════════════════════════════════════════════════════════════ -->
    <!-- RRH / RH — normal view                                        -->
    <!-- ══════════════════════════════════════════════════════════════ -->
    <template v-if="!isManager">

      <!-- Filters bar -->
      <div class="filters-bar">
        <div class="search-wrap">
          <span class="search-icon" v-html="icons.search"></span>
          <input v-model="search" type="text" placeholder="Rechercher par employé, matricule, habilitation..."
            class="search-input" />
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

      <!-- Stats strip -->
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

      <!-- Loading -->
      <div class="loading-state" v-if="loading">
        <div class="spinner"></div>
        <span>Chargement des associations...</span>
      </div>

      <!-- Grouped cards -->
      <div class="cards-container" v-if="groupedEmployees.length">
        <div v-for="emp in groupedEmployees" :key="emp.employee.id" class="employee-card">

          <div class="card-header" @click="toggle(emp.employee.id)">
            <div class="emp-info">
              <div>
                <div class="emp-name">{{ emp.employee.prenom }} {{ emp.employee.nom }}</div>
                <div class="emp-mat">Matricule: {{ emp.employee.matricule }}</div>
              </div>
            </div>
            <div class="card-actions">
              <span class="hab-count">{{ emp.habilitations.length }} habilitation(s)</span>
              <span :class="['arrow', openEmployees[emp.employee.id] ? 'open' : '']">▼</span>
            </div>
          </div>

          <transition name="collapse">
            <div v-if="openEmployees[emp.employee.id]" class="card-body">
              <table class="attr-data-table">
                <thead>
                  <tr>
                    <th>Habilitation</th>
                    <th>Organisme</th>
                    <th>Date obtention</th>
                    <th>Date expiration</th>
                    <th>Type</th>
                    <th>Statut</th>
                    <th>Validation</th>
                    <th>Actions</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="item in emp.habilitations" :key="item.id" class="data-row">
                    <td class="hab-name">{{ item.habilitation?.nom }}</td>
                    <td class="organisme-cell">{{ item.organisme_formation || '—' }}</td>
                    <td class="date-cell">{{ formatDate(item.date_obtention) }}</td>
                    <td class="date-cell">
                      <span :class="['exp-date', expirationClass(item)]">{{ formatDate(item.date_expiration) }}</span>
                    </td>
                    <td><span :class="['type-badge', item.type]">{{ item.type }}</span></td>
                    <td><span :class="['statut-badge', statutClass(item)]">{{ statutLabel(item) }}</span></td>
                    <td>
                      <span v-if="item.validation_statut === 'non_soumis'" class="valid-badge non-soumis">Non soumis</span>
                      <span v-else-if="item.validation_statut === 'en_cours'" class="valid-badge en-cours">⏳ En cours</span>
                      <span v-else-if="item.validation_statut === 'valide'" class="valid-badge valide">✓ Validé</span>
                      <span v-else-if="item.validation_statut === 'refuse'" class="valid-badge refuse">✗ Refusé</span>
                    </td>
                    <td>
                      <div class="actions">
                        <button class="action-btn pdf" @click="docGen(item.id)" title="Générer PDF">
                          <span v-html="icons.pdf"></span>
                        </button>
                        <button class="action-btn validate"
                          v-if="item.validation_statut === 'non_soumis' || item.validation_statut === 'refuse'"
                          @click="soumettreValidation(item.id)" title="Soumettre pour validation">
                          <span v-html="icons.send"></span>
                        </button>
                        <button class="action-btn view-validation"
                          v-if="item.validation_statut === 'en_cours' || item.validation_statut === 'valide'"
                          @click="voirValidation(item.id)" title="Voir la progression">
                          <span v-html="icons.eye"></span>
                        </button>
                      </div>
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>
          </transition>

        </div>
      </div>

    </template>

  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue';
import api from '@/services/api';
import { useRouter, useRoute } from 'vue-router';
import { useAuthStore } from '@/stores/auth';
import '@/../css/components/attributions/attributions.css';

const router     = useRouter();
const route      = useRoute();
const authStore  = useAuthStore();
const isManager  = computed(() => authStore.user?.role === 'Manager');

// ── RRH/RH state ──────────────────────────────────────────────────────────
const attributions  = ref([]);
const volets        = ref([]);
const loading       = ref(true);
const search        = ref('');
const filterVolet   = ref('');
const filterType    = ref('');
const filterStatut  = ref('');
const openEmployees = ref({});

// ── Manager state ──────────────────────────────────────────────────────────
const mgrTab           = ref('equipe');
const equipe           = ref([]);
const loadingEquipe    = ref(true);
const openEquipe       = ref({});
const mgrSearchQ       = ref('');
const mgrSearchResults = ref([]);
const loadingMgrSearch = ref(false);

const cascadeVolet        = ref('');
const cascadeHab          = ref('');
const cascadeHabilitations = ref([]);
const cascadeResults      = ref([]);
const mgrVolets           = ref([]);

// ── Icons ──────────────────────────────────────────────────────────────────
const icons = {
  eye:      `<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"/><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"/></svg>`,
  pdf:      `<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16v2a2 2 0 002 2h12a2 2 0 002-2v-2M7 10l5 5 5-5M12 15V3"/></svg>`,
  send:     `<svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 19l9 2-9-18-9 18 9-2zm0 0v-8"/></svg>`,
  plus:     `<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"/></svg>`,
  search:   `<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"/></svg>`,
  users:    `<svg xmlns="http://www.w3.org/2000/svg" width="15" height="15" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0z"/></svg>`,
  emptyBox: `<svg xmlns="http://www.w3.org/2000/svg" width="40" height="40" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4"/></svg>`,
};

// ── Helpers ────────────────────────────────────────────────────────────────
const formatDate = (d) => d ? new Date(d).toLocaleDateString('fr-FR') : null;

const joursRestants = (item) => {
  if (!item.date_expiration) return null;
  return Math.ceil((new Date(item.date_expiration) - new Date()) / (1000 * 60 * 60 * 24));
};
const statutClass = (item) => {
  const j = joursRestants(item);
  if (j === null) return '';
  if (j < 0) return 'expire';
  if (j <= 30) return 'bientot';
  return 'valide';
};
const statutLabel = (item) => {
  const j = joursRestants(item);
  if (j === null) return '—';
  if (j < 0) return 'Expiré';
  if (j <= 30) return `${j}j restants`;
  return 'Valide';
};
const expirationClass = (item) => {
  const j = joursRestants(item);
  if (j === null) return '';
  if (j < 0) return 'text-red';
  if (j <= 30) return 'text-orange';
  return '';
};

const docGen = (id) => router.push({ name: 'documents.id', params: { id } });

// ── RRH/RH computed ───────────────────────────────────────────────────────
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
  if (filterVolet.value)  list = list.filter(a => a.habilitation?.volet?.id === filterVolet.value);
  if (filterType.value)   list = list.filter(a => a.type === filterType.value);
  if (filterStatut.value) list = list.filter(a => statutClass(a) === filterStatut.value);
  return list;
});

const groupedEmployees = computed(() =>
  Object.values(filtered.value.reduce((acc, item) => {
    const empId = item.employee_id;
    if (!acc[empId]) acc[empId] = { employee: item.employee, habilitations: [] };
    acc[empId].habilitations.push(item);
    return acc;
  }, {}))
);

const totalCount  = computed(() => filtered.value.length);
const valideCount = computed(() => filtered.value.filter(a => statutClass(a) === 'valide').length);
const bientotCount= computed(() => filtered.value.filter(a => statutClass(a) === 'bientot').length);
const expireCount = computed(() => filtered.value.filter(a => statutClass(a) === 'expire').length);

const toggle = (empId) => {
  openEmployees.value[empId] = !openEmployees.value[empId];
};

// ── Manager helpers ────────────────────────────────────────────────────────
const mgrValidCount   = (emp) => emp.employee_habilitations?.filter(eh => statutClass(eh) === 'valide').length ?? 0;
const mgrExpiredCount = (emp) => emp.employee_habilitations?.filter(eh => statutClass(eh) === 'expire').length ?? 0;
const mgrSoonCount    = (emp) => emp.employee_habilitations?.filter(eh => statutClass(eh) === 'bientot').length ?? 0;

const toggleEquipe = (empId) => {
  openEquipe.value[empId] = !openEquipe.value[empId];
};

const switchMgrTab = (tab) => {
  mgrTab.value = tab;
  mgrSearchQ.value = '';
  mgrSearchResults.value = [];
};

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

const fetchEquipe = async () => {
  loadingEquipe.value = true;
  try {
    const { data } = await api.get('/manager/mon-equipe');
    equipe.value = data;
  } finally {
    loadingEquipe.value = false;
  }
};

// ── Validation ─────────────────────────────────────────────────────────────
const soumettreValidation = async (id) => {
  try {
    await api.post(`/validations/initier/${id}`);
    await fetchData();
    alert('Workflow de validation initié. Le premier signataire a été notifié.');
  } catch (e) {
    alert(e.response?.data?.message ?? 'Erreur lors de l\'initiation.');
  }
};

const voirValidation = async (id) => {
  try {
    const { data } = await api.get(`/validations/${id}`);
    const etapes = data.etapes.map(e =>
      `${e.ordre}. ${e.signataire_nom} — ${e.statut}${e.confirmed_at ? ' (' + new Date(e.confirmed_at).toLocaleDateString('fr-FR') + ')' : ''}`
    ).join('\n');
    alert(`Progression de validation :\n\n${etapes}`);
  } catch (e) { console.error(e); }
};

const onCascadeVoletChange = async () => {
  cascadeHab.value          = '';
  cascadeHabilitations.value = [];
  cascadeResults.value      = [];
  if (!cascadeVolet.value) return;
  try {
    const { data } = await api.get('/habilitations/volet/' + cascadeVolet.value);
    cascadeHabilitations.value = data;
  } catch (e) { console.error(e); }
};

const onCascadeHabChange = async () => {
  cascadeResults.value = [];
  if (!cascadeHab.value) return;
  loadingMgrSearch.value = true;
  try {
    const { data } = await api.get('/manager/recherche-habilitation', {
      params: { habilitation_id: cascadeHab.value }
    });
    cascadeResults.value = data.length ? data[0].employes : [];
  } catch (e) { console.error(e); }
  finally { loadingMgrSearch.value = false; }
};

const fetchMgrVolets = async () => {
  const { data } = await api.get('/volets');
  mgrVolets.value = data;
  console.log('Volets pour manager :', data);
};
onMounted(async () => {
  if (isManager.value) {
    await Promise.all([fetchEquipe(), fetchMgrVolets()]);
  } else {
    await fetchData();
    if (route.query.statut) filterStatut.value = route.query.statut;
  }
});
</script>

<style scoped>
.mgr-cascade { display: flex; flex-direction: column; gap: 16px; }
.mgr-cascade-row { display: grid; grid-template-columns: 1fr 1fr; gap: 16px; }
.mgr-cascade-step { display: flex; flex-direction: column; gap: 8px; }
.mgr-step-label {
  display: flex; align-items: center; gap: 8px;
  font-size: 0.82rem; font-weight: 600; color: #374151;
}
.mgr-step-num {
  width: 22px; height: 22px; border-radius: 50%;
  background: #1a4a6b; color: white;
  display: flex; align-items: center; justify-content: center;
  font-size: 0.72rem; font-weight: 700; flex-shrink: 0;
}
.mgr-select { width: 100%; min-width: 0; }
.mgr-select:disabled { background: #f4f6f9; color: #9ca3af; cursor: not-allowed; }
.mgr-result-stats { display: flex; gap: 6px; }

@media (max-width: 600px) {
  .mgr-cascade-row { grid-template-columns: 1fr; }
}
.action-btn.validate { background: #f0fdf4; color: #16a34a; }
.action-btn.validate:hover { background: #dcfce7; }
.action-btn.pdf { background: #e0e7ff; color: #3730a3; }
.action-btn.pdf:hover { background: #c7d2fe; }

.valid-badge { display:inline-block; padding:2px 8px; border-radius:20px; font-size:0.7rem; font-weight:700; }
.valid-badge.en-cours { background:#fffbeb; color:#d97706; }
.valid-badge.valide   { background:#f0fdf4; color:#16a34a; }
.valid-badge.refuse   { background:#fef2f2; color:#dc2626; }
.valid-badge.non-soumis { background:#f4f6f9; color:#6b7280; }

.cards-container { display:flex; flex-direction:column; gap:16px; }
.employee-card { background:#fff; border-radius:12px; box-shadow:0 2px 8px rgba(0,0,0,0.05); overflow:hidden; }
.card-header { display:flex; justify-content:space-between; align-items:center; padding:16px; cursor:pointer; }
.card-header:hover { background:#f8fafc; }
.emp-info { display:flex; gap:12px; align-items:center; }
.card-actions { display:flex; align-items:center; gap:12px; }
.arrow { transition:0.3s; }
.arrow.open { transform:rotate(180deg); }
.card-body { padding:10px; border-top:1px solid #eee; overflow:auto; max-height:400px; }

/* Manager specific */
.mgr-tabs { display:flex; gap:4px; margin-bottom:20px; background:white; border:1px solid #e8ecf0; border-radius:10px; padding:4px; width:fit-content; }
.mgr-tab { display:flex; align-items:center; gap:7px; padding:8px 16px; border-radius:7px; border:none; font-size:0.875rem; font-weight:500; cursor:pointer; color:#6b7280; background:transparent; transition:all 0.15s; }
.mgr-tab.active { background:#1a4a6b; color:white; }
.mgr-tab:hover:not(.active) { background:#f4f6f9; }

.emp-avatar-circle { width:38px; height:38px; min-width:38px; background:linear-gradient(135deg,#1a4a6b,#1a6b8a); color:white; border-radius:9px; display:flex; align-items:center; justify-content:center; font-size:0.8rem; font-weight:800; }

.mgr-emp-stats { display:flex; gap:5px; }
.mgr-stat { font-size:0.7rem; font-weight:600; padding:2px 8px; border-radius:20px; }
.mgr-stat.green  { background:#f0fdf4; color:#16a34a; }
.mgr-stat.red    { background:#fef2f2; color:#dc2626; }
.mgr-stat.orange { background:#fffbeb; color:#d97706; }

.mgr-no-hab { padding:14px 16px; font-size:0.82rem; color:#9ca3af; }

.mgr-search-bar { margin-bottom:20px; }
.mgr-search-hint { display:flex; align-items:center; gap:8px; padding:20px; color:#9ca3af; font-size:0.875rem; }

.mgr-result-header { display:flex; align-items:center; justify-content:space-between; padding:12px 16px; background:#f8fafc; border-bottom:1px solid #e8ecf0; }
.mgr-result-title { font-size:0.875rem; font-weight:700; color:#1a4a6b; }
.mgr-result-list { display:flex; flex-direction:column; }
.mgr-result-row { display:flex; align-items:center; gap:12px; padding:10px 16px; border-bottom:1px solid #f8fafc; }
.mgr-result-row:last-child { border-bottom:none; }
.mgr-result-emp { flex:1; }
.mgr-result-service { font-size:0.75rem; color:#9ca3af; }
</style>