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
    <div class="cards-container" v-if="groupedEmployees.length">

      <div v-for="(emp) in groupedEmployees" :key="emp.employee.id" class="employee-card">

        <!-- HEADER -->
        <div class="card-header" @click="toggle(emp.employee.id)">
          <div class="emp-info">
            <!-- <div class="emp-avatar">{{ initiales(emp.employee) }}</div> -->

            <div>
              <div class="emp-name">
                {{ emp.employee.prenom }} {{ emp.employee.nom }}
              </div>
              <div class="emp-mat">
                Matricule: {{ emp.employee.matricule }}
              </div>
            </div>
          </div>

          <div class="card-actions">
            <span class="hab-count">
              {{ emp.habilitations.length }} habilitation(s)
            </span>

            <span :class="['arrow', openEmployees[emp.employee.id] ? 'open' : '']">▼</span>
          </div>
        </div>

        <!-- BODY -->
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
        <span :class="['exp-date', expirationClass(item)]">
          {{ formatDate(item.date_expiration) }}
        </span>
      </td>
      <td><span :class="['type-badge', item.type]">{{ item.type }}</span></td>
      <td><span :class="['statut-badge', statutClass(item)]">{{ statutLabel(item) }}</span></td>

      <!-- Validation status -->
      <td>
        <span v-if="item.validation_statut === 'non_soumis'" class="valid-badge non-soumis">
          Non soumis
        </span>
        <span v-else-if="item.validation_statut === 'en_cours'" class="valid-badge en-cours">
          ⏳ En cours
        </span>
        <span v-else-if="item.validation_statut === 'valide'" class="valid-badge valide">
          ✓ Validé
        </span>
        <span v-else-if="item.validation_statut === 'refuse'" class="valid-badge refuse">
          ✗ Refusé
        </span>
      </td>

      <!-- Actions -->
      <td>
        <div class="actions">
          <!-- PDF -->
          <button class="action-btn pdf" @click="docGen(item.id)" title="Générer PDF">
            <span v-html="icons.pdf"></span>
          </button>
          <!-- Submit for validation — only if not yet submitted -->
          <button
            class="action-btn validate"
            v-if=" (item.validation_statut === 'non_soumis' || item.validation_statut === 'refuse')"
            @click="soumettreValidation(item.id)"
            title="Soumettre pour validation"
          >
            <span v-html="icons.send"></span>
          </button>
          <!-- View validation progress -->
          <button
            class="action-btn view-validation"
            v-if="item.validation_statut === 'en_cours' || item.validation_statut === 'valide'"
            @click="voirValidation(item.id)"
            title="Voir la progression"
          >
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


  </div>
</template>

<script setup>

import { ref, computed, onMounted } from 'vue';
import api from '@/services/api';
import { useRouter, useRoute } from 'vue-router';
import '@/../css/components/attributions/attributions.css';

// ── State ──────────────────────────────────────────────────────────────────
const attributions = ref([]);
const volets = ref([]);
const loading = ref(true);
const router = useRouter();
const route = useRoute();

const search = ref('');
const filterVolet = ref('');
const filterType = ref('');
const filterStatut = ref('');

const openEmployees = ref({});
const toggle = (empId) => {
  openEmployees.value[empId] = !openEmployees.value[empId];
  const emp = groupedEmployees.value.find(e => e.employee.id === empId);
  if (emp) {
    emp.open = openEmployees.value[empId];
  }

 };

// ── Icons ──────────────────────────────────────────────────────────────────
const icons = {
 eye: `<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"/><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"/></svg>`,
  pdf: `<svg xmlns="http://www.w3.org/2000/svg" 
     width="16" height="16" 
     fill="none" viewBox="0 0 24 24" 
     stroke="currentColor">
  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" 
        d="M4 16v2a2 2 0 002 2h12a2 2 0 002-2v-2M7 10l5 5 5-5M12 15V3"/>
</svg>`,
send: `<svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 19l9 2-9-18-9 18 9-2zm0 0v-8"/></svg>`,  plus: `<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"/></svg>`,
  search: `<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"/></svg>`,
  emptyBox: `<svg xmlns="http://www.w3.org/2000/svg" width="40" height="40" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4"/></svg>`,
};


const formatDate = (d) => {
  if (!d) return null;
  return new Date(d).toLocaleDateString('fr-FR');
};

const docGen = (id) => {
  router.push({ name: 'documents.id', params: { id: id } });
};

const joursRestants = (item) => {
  if (!item.date_expiration) return null;
  const diff = new Date(item.date_expiration) - new Date();
  return Math.ceil(diff / (1000 * 60 * 60 * 24));
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

  return list;
});
const groupedEmployees = computed(() => {
  return Object.values(
    filtered.value.reduce((acc, item) => {
      const empId = item.employee_id;

      if (!acc[empId]) {
        acc[empId] = {
          employee: item.employee,
          habilitations: [],
          open: false
        };
      }

      acc[empId].habilitations.push(item);

      return acc;
    }, {})
  );
});

// ── Stats ──────────────────────────────────────────────────────────────────
const totalCount = computed(() => filtered.value.length);
const valideCount = computed(() => filtered.value.filter(a => statutClass(a) === 'valide').length);
const bientotCount = computed(() => filtered.value.filter(a => statutClass(a) === 'bientot').length);
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
    volets.value = voletRes.data;
  } finally {
    loading.value = false;
  }
};

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
    console.log(data);
    // show a simple modal or alert with the steps
    const etapes = data.etapes.map(e =>
      `${e.ordre}. ${e.signataire_nom} — ${e.statut} ${e.confirmed_at ? '(' + new Date(e.confirmed_at).toLocaleDateString('fr-FR') + ')' : ''}`
    ).join('\n');
    alert(`Progression de validation :\n\n${etapes}`);
  } catch (e) {
    console.error(e);
  }
};
onMounted(async () => {
  await fetchData();
  if (route.query.statut) {
    filterStatut.value = route.query.statut;
  }
});</script>

<style scoped>
.action-btn.validate {
  background: #f0fdf4;
  color: #16a34a;
}

.action-btn.pdf {
  background: #e0e7ff;
  color: #3730a3;
}

.action-btn.pdf:hover {
  background: #c7d2fe;
}

.action-btn.validate:hover {
  background: #dcfce7;
}

.valid-badge {
  display: inline-block;
  padding: 2px 8px;
  border-radius: 20px;
  font-size: 0.7rem;
  font-weight: 700;
}

.valid-badge.en-cours {
  background: #fffbeb;
  color: #d97706;
}

.valid-badge.valide {
  background: #f0fdf4;
  color: #16a34a;
}

.valid-badge.refuse {
  background: #fef2f2;
  color: #dc2626;
}

.cards-container {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.employee-card {
  background: #fff;
  border-radius: 12px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
  overflow: hidden;
}

/* HEADER */
.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16px;
  cursor: pointer;
}

.emp-info {
  display: flex;
  gap: 12px;
  align-items: center;
}

.arrow {
  transition: 0.3s;
}

.arrow.open {
  transform: rotate(180deg);
}

/* BODY */
.card-body {
  padding: 10px;
  border-top: 1px solid #eee;
  overflow: auto;
  max-height: 300px;
}

.habilitation-item {
  padding: 12px;
  border-bottom: 1px solid #f1f1f1;
}

.hab-main {
  display: flex;
  justify-content: space-between;
  margin-bottom: 8px;
}

.hab-details {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(120px, 1fr));
  gap: 8px;
  align-items: center;
}

.hub-count {
  font-weight: 600;
  color: #1a2e44;
  font-size: 0.875rem;
}
</style>