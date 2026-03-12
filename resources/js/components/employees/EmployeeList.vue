<template>
  <div class="employee-list">

    <!-- ── Header ─────────────────────────────────────── -->
    <div class="page-header">
      <div>
        <h1 class="page-title">Salariés</h1>
        <p class="page-subtitle">{{ total }} salarié(s) trouvé(s)</p>
      </div>
      <div class="header-actions">
        <button class="btn-import" @click="showImportModal = true" v-if="canWrite">
          <span v-html="icons.upload"></span>
          Importer Excel
        </button>
        <router-link to="/employees/create" class="btn-add" v-if="canWrite">
          <span v-html="icons.plus"></span>
          Ajouter un salarié
        </router-link>
      </div>
    </div>

    <!-- ── Filters ────────────────────────────────────── -->
    <div class="filters-bar">
      <div class="search-wrapper">
        <span class="search-icon" v-html="icons.search"></span>
        <input v-model="filters.search" type="text" placeholder="Rechercher par nom, prénom, matricule..."
          class="search-input" @input="debouncedFetch" />
      </div>

      <select v-model="filters.departement_id" @change="onDepartementChange" class="filter-select" v-if="!isManager">
        <option value="">Tous les départements</option>
        <option v-for="dep in departements" :key="dep.id" :value="dep.id">
          {{ dep.nom }}
        </option>
      </select>

      <select v-model="filters.service_id" @change="fetchEmployees" class="filter-select" v-if="!isManager">
        <option value="">Tous les services</option>
        <option v-for="svc in filteredServices" :key="svc.id" :value="svc.id">
          {{ svc.nom }}
        </option>
      </select>

      <button class="btn-reset" @click="resetFilters" v-if="hasFilters">
        <span v-html="icons.x"></span>
        Réinitialiser
      </button>
    </div>

    <!-- ── Loading ────────────────────────────────────── -->
    <div class="loading-state" v-if="loading">
      <div class="loader"></div>
    </div>

    <!-- ── Empty ──────────────────────────────────────── -->
    <div class="empty-state" v-else-if="employees.length === 0">
      <span v-html="icons.users"></span>
      <p>Aucun employé trouvé.</p>
    </div>
    <!-- ── Table ──────────────────────────────────────── -->
    <div class="emp-table-card" v-else>
      <table class="data-table">
        <thead>
          <tr>
            <th>Matricule</th>
            <th>Nom & Prénom</th>
            <th>Poste</th>
            <th>Type</th>
            <th>Service</th>
            <th>Actions</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="emp in employees" :key="emp.id" class="table-row"
            :class="{ 'row-clickable': !authStore.isManager }" @click="goToDetail(emp.id)">
            <td data-label="Matricule">
              <span class="matricule-badge">{{ emp.matricule || 'ST' }}</span>
            </td>
            <td data-label="Nom & Prénom">
              <div class="employee-name">
                <div>
                  <div class="name">{{ emp.nom }} {{ emp.prenom }}</div>
                  <div class="email">{{ emp.email_pro }}</div>
                </div>
              </div>
            </td>
            <td data-label="Poste" class="td-muted">{{ emp.position || '—' }}</td>
            <td data-label="Type">
              <span class="type-badge" :class="emp.type">
                {{ emp.type === 'propre' ? 'Propre' : 'Sous-Traitant' }}
              </span>
              <div class="societe-name" v-if="emp.societe">{{ emp.societe }}</div>
            </td>
            <td data-label="Service" class="td-muted">{{ emp.service?.nom || '—' }}</td>

            <td data-label="Actions" @click.stop>
              <div class="actions">
                <router-link :to="`/employees/${emp.id}/edit`" class="action-btn edit" v-if="canWrite" title="Modifier">
                  <span v-html="icons.edit"></span>
                </router-link>
                <button class="action-btn delete" v-if="canDelete" @click="confirmDelete(emp)" title="Supprimer">
                  <span v-html="icons.trash"></span>
                </button>
              </div>
            </td>
          </tr>
        </tbody>
      </table>
    </div>


    <ConfirmModal :show="!!deleteTarget" title="Supprimer cet employé ?" confirmLabel="Supprimer" :loading="deleting"
      :icon="icons.trash" @confirm="deleteEmployee" @cancel="deleteTarget = null">
      <strong>{{ deleteTarget?.nom }} {{ deleteTarget?.prenom }}</strong>
      — Matricule {{ deleteTarget?.matricule }}<br>
      Cette action est irréversible.
    </ConfirmModal>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue';
import { useRouter } from 'vue-router';
import { useAuthStore } from '@/stores/auth';
import api from '@/services/api';
import '@/../css/components/employees/employee-list.css';
import ConfirmModal from '@/components/shared/ConfirmModal.vue';

const router = useRouter();
const auth = useAuthStore();

const employees = ref([]);
const departements = ref([]);
const services = ref([]);
const loading = ref(true);
const deleting = ref(false);
const deleteTarget = ref(null);
const total = ref(0);

const isManager = computed(() => auth.user?.role === 'Manager');
const canWrite = computed(() => ['RRH', 'RH'].includes(auth.user?.role));
const canDelete = computed(() => auth.user?.role === 'RRH');

const filters = reactive({
  search: '',
  departement_id: '',
  service_id: '',
});

const hasFilters = computed(() =>
  filters.search || filters.departement_id || filters.service_id
);

const filteredServices = computed(() =>
  filters.departement_id
    ? services.value.filter(s => s.departement_id == filters.departement_id)
    : services.value
);

// ── Icons ─────────────────────────────────────────────
const icons = {
  plus: `<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"/></svg>`,
  upload: `<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-8l-4-4m0 0L8 8m4-4v12"/></svg>`,
  search: `<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"/></svg>`,
  edit: `<svg xmlns="http://www.w3.org/2000/svg" width="15" height="15" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"/></svg>`,
  trash: `<svg xmlns="http://www.w3.org/2000/svg" width="15" height="15" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"/></svg>`,
  users: `<svg xmlns="http://www.w3.org/2000/svg" width="48" height="48" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0z"/></svg>`,
  x: `<svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/></svg>`,
};

// ── Fetch ─────────────────────────────────────────────
const fetchEmployees = async () => {
  loading.value = true;
  try {
    const params = {};
    if (filters.search) params.search = filters.search;
    if (filters.service_id) params.service_id = filters.service_id;
    if (filters.departement_id) params.departement_id = filters.departement_id;

    const { data } = await api.get('/employees', { params });
    employees.value = data;
    total.value = data.length;
  } catch (e) {
    console.error(e);
  } finally {
    loading.value = false;
  }
};

const fetchReferentials = async () => {
  if (isManager.value) return;
  const [depRes, svcRes] = await Promise.all([
    api.get('/departements'),
    api.get('/services'),
  ]);
  departements.value = depRes.data;
  services.value = svcRes.data;
};

// ── Debounce search ───────────────────────────────────
let debounceTimer = null;
const debouncedFetch = () => {
  clearTimeout(debounceTimer);
  debounceTimer = setTimeout(fetchEmployees, 350);
};

// ── Filter helpers ────────────────────────────────────
const onDepartementChange = () => {
  filters.service_id = '';
  fetchEmployees();
};

const resetFilters = () => {
  filters.search = '';
  filters.departement_id = '';
  filters.service_id = '';
  fetchEmployees();
};

// ── Navigation ────────────────────────────────────────
const authStore = useAuthStore();

const goToDetail = (id) => {
  if (authStore.isManager) return;
  router.push(`/employees/${id}/edit`);
};


// ── Delete ────────────────────────────────────────────
const confirmDelete = (emp) => {
  deleteTarget.value = emp;
};

const deleteEmployee = async () => {
  if (!deleteTarget.value) return;
  deleting.value = true;
  try {
    await api.delete(`/employees/${deleteTarget.value.id}`);
    employees.value = employees.value.filter(e => e.id !== deleteTarget.value.id);
    total.value--;
    deleteTarget.value = null;
  } catch (err) {
    if (err.response?.status === 409) {
      alert(err.response.data.message);
    }
  } finally {
    deleting.value = false;
  }
};

onMounted(async () => {
  await fetchReferentials();
  await fetchEmployees();
});
</script>