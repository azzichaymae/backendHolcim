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
      <button class="btn-archived" :class="{ active: showArchived }" @click="showArchived = !showArchived" v-if="!isManager">
        <span v-html="icons.archive"></span>
        {{ showArchived ? 'Voir actifs' : 'Voir archivés' }}
      </button>
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
            <th>Statut</th>
            <th>Service</th>
            <th v-if="showArchived">Date de départ</th>
            <th v-if="!isManager">Actions</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="emp in employees" :key="emp.id" class="table-row"
            :class="{ 'row-clickable': !authStore.isManager && !showArchived }"
            @click="showArchived ? showArchiveHab(emp.id) : goToDetail(emp.id)">
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
            <td data-label="Date de départ" v-if="showArchived">
  {{ emp.deleted_at ? new Date(emp.deleted_at).toISOString().slice(0,10) : '—' }}
</td>

            <td data-label="Actions" @click.stop v-if="!isManager">
              <div class="actions">
                 <router-link v-if="!showArchived && canWrite" :to="`/employees/${emp.id}/edit`" class="action-btn edit" 
                  title="Modifier">
                  <span v-html="icons.edit"></span>
                </router-link>
                <button v-if="showArchived" class="action-btn restore" @click="restoreEmp(emp.id)" title="Restaurer">
                  <span v-html="icons.restore"></span>
                </button>
                <button class="action-btn delete"  @click="!showArchived ? confirmDelete(emp) : forceDelete(emp)" title="Supprimer">
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
      sera archivé et ne sera plus visible dans la liste active.<br>
      Ses habilitations et documents seront conservés.
    </ConfirmModal>


    <!-- ── Import Modal ───────────────────────────────── -->
    <Teleport to="body">
      <div v-if="showImportModal" class="import-backdrop" @click.self="closeImportModal">
        <div class="import-dialog">

          <div class="import-header">
            <div>
              <h3 class="import-title">Importer des salariés</h3>
              <p class="import-subtitle">Fichier Excel (.xlsx, .xls) ou CSV</p>
            </div>
            <button class="import-close" @click="closeImportModal">
              <span v-html="icons.x"></span>
            </button>
          </div>

          <div class="import-template-bar">
            <span v-html="icons.download"></span>
            <span>Télécharger le modèle Excel</span>
            <button class="btn-template" @click="downloadTemplate">Télécharger</button>
          </div>

          <div class="import-dropzone" :class="{ 'drag-over': isDragging, 'has-file': importFile }"
            @dragover.prevent="isDragging = true" @dragleave="isDragging = false" @drop.prevent="onDrop"
            @click="$refs.fileInput.click()">
            <input ref="fileInput" type="file" accept=".xlsx,.xls,.csv" style="display:none" @change="onFileChange" />
            <template v-if="!importFile">
              <span class="dropzone-icon" v-html="icons.uploadLg"></span>
              <p class="dropzone-text">Glisser-déposer ou <span class="dropzone-link">parcourir</span></p>
              <p class="dropzone-hint">xlsx, xls, csv — max 5 MB</p>
            </template>
            <template v-else>
              <span class="dropzone-icon" v-html="icons.fileExcel"></span>
              <p class="dropzone-text">{{ importFile.name }}</p>
              <p class="dropzone-hint">{{ (importFile.size / 1024).toFixed(1) }} KB — Cliquer pour changer</p>
            </template>
          </div>

          <div class="import-result" v-if="importResult">
            <div class="result-stats">
              <div class="result-stat green">
                <span class="result-num">{{ importResult.imported }}</span>
                <span class="result-label">Ajoutés</span>
              </div>
              <div class="result-stat blue">
                <span class="result-num">{{ importResult.updated }}</span>
                <span class="result-label">Mis à jour</span>
              </div>
              <div class="result-stat red">
                <span class="result-num">{{ importResult.errors.length }}</span>
                <span class="result-label">Erreurs</span>
              </div>
            </div>
            <ul class="import-errors" v-if="importResult.errors.length">
              <li v-for="(err, i) in importResult.errors" :key="i">{{ err }}</li>
            </ul>
          </div>

          <div class="import-actions">
            <button class="btn-cancel-import" @click="closeImportModal">Annuler</button>
            <button class="btn-do-import" @click="doImport" :disabled="!importFile || importing">
              <span v-if="importing" class="spinner-sm"></span>
              <span v-else v-html="icons.upload"></span>
              {{ importing ? 'Importation...' : 'Importer' }}
            </button>
          </div>

        </div>
      </div>
    </Teleport>

    <Teleport to="body">
      <div v-if="showArchivedModal" class="archived-habs-backdrop" @click.self="closeArchivedModal">
        <div class="archived-habs-dialog">
          <div style="display: flex; align-items: flex-start; justify-content: space-between;
          ">
            <h3>Historique des habilitations</h3>
            <button class="import-close" @click="closeArchivedModal()"><span v-html="icons.x"></span></button>
          </div>

          <table class="data-table">
            <thead>
              <tr>
                <th>HABILITATION</th>
                <th>TYPE</th>
                <th>DATE D'ATTRIBUTION</th>
                <th>DATE DE RÉVOCATION</th>

              </tr>
            </thead>
            <tbody>
              <!-- État de chargement -->
              <tr v-if="loading">
                <td colspan="4" class="loading-state">
                  <div class="loader"></div>
                </td>
              </tr>

              <!-- État vide -->
              <tr v-else-if="archivedHabs.length === 0">
                <td colspan="4" class="empty-state">Aucune association trouvée</td>
              </tr>

              <!-- Liste des habilitations -->
              <tr v-else v-for="hab in archivedHabs" :key="hab.id">
                <td>{{ hab.habilitation.nom }}</td>
                <td>{{ hab.type === 'initiale' ? 'Initiale' : 'Recyclage' }}</td>
                <td>{{ new Date(hab.date_obtention).toLocaleDateString('fr-FR') }}</td>
                <td>{{ hab.date_expiration ? new Date(hab.date_expiration).toLocaleDateString('fr-FR') : '—' }}</td>
              </tr>
            </tbody>

          </table>
        </div>
      </div>
    </Teleport>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted, watch } from 'vue';
import { useRouter } from 'vue-router';
import { useAuthStore } from '@/stores/auth';
import api from '@/services/api';
import '@/../css/components/employees/employee-list.css';
import ConfirmModal from '@/components/shared/ConfirmModal.vue';
import { fa } from 'vuetify/locale';

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
const showArchived = ref(false);

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

// ── Import state ─────────────────────────────────────
const showImportModal = ref(false);
const importFile = ref(null);
const importing = ref(false);
const importResult = ref(null);
const isDragging = ref(false);

// ── Icons ─────────────────────────────────────────────
const icons = {
  restore: `<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" 
     viewBox="0 0 24 24" fill="none" stroke="currentColor" 
     stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
  <path d="M21 12a9 9 0 1 1-3-6.7M21 3v6h-6"/>
</svg>
`,
  archive: `<svg xmlns="http://www.w3.org/2000/svg" width="15" height="15" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 8h14M5 8a2 2 0 110-4h14a2 2 0 110 4M5 8v10a2 2 0 002 2h10a2 2 0 002-2V8m-9 4h4"/></svg>`,
  plus: `<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"/></svg>`,
  upload: `<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-8l-4-4m0 0L8 8m4-4v12"/></svg>`,
  search: `<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"/></svg>`,
  edit: `<svg xmlns="http://www.w3.org/2000/svg" width="15" height="15" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"/></svg>`,
  trash: `<svg xmlns="http://www.w3.org/2000/svg" width="15" height="15" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"/></svg>`,
  users: `<svg xmlns="http://www.w3.org/2000/svg" width="48" height="48" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0z"/></svg>`,
  x: `<svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/></svg>`,
  download: `<svg xmlns="http://www.w3.org/2000/svg" width="15" height="15" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4"/></svg>`,
  uploadLg: `<svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-8l-4-4m0 0L8 8m4-4v12"/></svg>`,
  fileExcel: `<svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"/></svg>`,
};

// ── Fetch ─────────────────────────────────────────────
const fetchEmployees = async () => {
  loading.value = true;
  const endpoint = showArchived.value ? '/employees/archived' : '/employees';

  try {
    const params = {};
    if (filters.search) params.search = filters.search;
    if (filters.service_id) params.service_id = filters.service_id;
    if (filters.departement_id) params.departement_id = filters.departement_id;

    const { data } = await api.get(endpoint, { params });
     employees.value = data;
    total.value = data.length;
  } catch (e) {
    console.error(e);
  } finally {
    loading.value = false;
  }
};


watch(showArchived, fetchEmployees);

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

const forceDelete = async (emp) => {
  if (!confirm("Êtes-vous sûr de vouloir supprimer définitivement cet employé ? Cette action est irréversible.")) return;
  deleting.value = true;
  try {
    await api.delete(`/employees/${emp.id}/force`);
    employees.value = employees.value.filter(e => e.id !== emp.id);
    total.value--;
  } catch (err) {
    alert("Erreur lors de la suppression.");
  } finally {
    deleting.value = false;
  }
};

// ── Import ────────────────────────────────────────────
const closeImportModal = () => {
  showImportModal.value = false;
  importFile.value = null;
  importResult.value = null;
  isDragging.value = false;
};

const onFileChange = (e) => {
  const file = e.target.files[0];
  if (file) { importFile.value = file; importResult.value = null; }
};

const onDrop = (e) => {
  isDragging.value = false;
  const file = e.dataTransfer.files[0];
  if (file) { importFile.value = file; importResult.value = null; }
};

const doImport = async () => {
  if (!importFile.value) return;
  importing.value = true;
  importResult.value = null;
  try {
    const formData = new FormData();
    formData.append('file', importFile.value);
    const { data } = await api.post('/employees/import', formData, {
      headers: { 'Content-Type': 'multipart/form-data' },
    });
    importResult.value = data;
    if (data.imported > 0 || data.updated > 0) await fetchEmployees();
  } catch (e) {
    importResult.value = {
      imported: 0, updated: 0,
      errors: [e.response?.data?.message ?? "Erreur lors de l'importation."],
    };
  } finally {
    importing.value = false;
  }
};

const downloadTemplate = () => {
  const csv = [
    'matricule,nom,prenom,email_pro,position,type,societe,service',
    '12345,BENALI,Karim,k.benali@holcim.ma,Opérateur,propre,,Production',
    ',SMITH,John,j.smith@contractor.ma,Technicien,sous-traitant,Anwal Electric,Maintenance',
  ].join('\n');
  const blob = new Blob([csv], { type: 'text/csv' });
  const url = URL.createObjectURL(blob);
  const a = document.createElement('a');
  a.href = url; a.download = 'modele_import_salaries.csv';
  a.click(); URL.revokeObjectURL(url);
};

//Archived habs
const showArchivedModal = ref(false);
const archivedHabs = ref([]);
const showArchiveHab = async (id) => {

  showArchivedModal.value = true;
  loading.value = true
  const { data } = await api.get(`/employee-habilitations/${id}/history`);
  archivedHabs.value = data;
  loading.value = false
};

const closeArchivedModal = () => {
   showArchivedModal.value = false;
  archivedHabs.value = [];

};

const restoreEmp = async (id) => {
  if (!confirm("Êtes-vous sûr de vouloir restaurer cet employé ?")) return;
  try {
    await api.patch(`/employees/${id}/restore`);
    await fetchEmployees();
    alert("Employé restauré avec succès.");
  } catch (e) {
    alert("Erreur lors de la restauration.");
  }
};

onMounted(async () => {
  await fetchReferentials();
  await fetchEmployees();
});
</script>
<style scoped>
.archived-habs-dialog {
  background: white;
  border-radius: 8px;
  padding: 24px;
  width: 90%;
  max-width: 1200px;
  max-height: 80vh;
  overflow-y: auto;
}

.archived-habs-dialog h3 {
  margin-bottom: 20px;
  font-size: 1.25rem;
  font-weight: 600;
}

.data-table {
  width: 100%;
  border-collapse: collapse;
  margin-bottom: 20px;
}

.data-table thead tr {
  background-color: #f3f4f6;
  border-bottom: 2px solid #e5e7eb;
}

.data-table th {
  text-align: left;
  padding: 12px 16px;
  font-weight: 600;
  font-size: 0.875rem;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  color: #6b7280;
}

.data-table td {
  padding: 12px 16px;
  border-bottom: 1px solid #e5e7eb;
}

.status-valid {
  color: #10b981;
  font-weight: 500;
}

.status-expiring {
  color: #f59e0b;
  font-weight: 500;
}

.status-expired {
  color: #ef4444;
  font-weight: 500;
}

.status-revoked {
  color: #6b7280;
  font-weight: 500;
}

.btn-close-archived {
  background-color: #3b82f6;
  color: white;
  border: none;
  padding: 10px 20px;
  border-radius: 6px;
  cursor: pointer;
  font-size: 0.875rem;
  font-weight: 500;
}

.btn-close-archived:hover {
  background-color: #2563eb;
}

.archived-habs-backdrop {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background-color: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
}
</style>