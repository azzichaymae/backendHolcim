<template>
  <div class="document-generation">

    <!-- ── Header ─────────────────────────────────────── -->
    <div class="page-header">
      <div class="page-title-block">
        <!-- Back button — only when form is open -->
        <button v-if="activeType" class="btn-back-doc" @click="goBack">
          <span v-html="icons.chevronLeft"></span>
        </button>
        <div>
          <h1 class="page-title">
            {{ activeType ? (activeType === 'individuelle' ? 'Habilitation Individuelle' : 'Note d\'Habilitation') :
              'Génération de Documents' }}
          </h1>
          <p class="page-subtitle">
            {{ activeType ? 'Remplissez le formulaire et générez le document' : 'Générer les attestations et notes d\'habilitation' }}
          </p>
        </div>
      </div>
      <div class="gen-dropdown" v-if="!activeType" v-click-outside="() => isOpen = false">
        <div class="gen-btn-group">
          <button class="gen-btn-main" @click="isOpen = !isOpen">
            <span v-html="icons.plus"></span>
            Générer un document
          </button>
          <button class="gen-btn-arrow" @click="isOpen = !isOpen">
            <span v-html="icons.chevronDown"></span>
          </button>
        </div>

        <div class="gen-dropdown-menu" v-if="isOpen">
          <div class="gen-dropdown-item" @click="setType('individuelle'); isOpen = false">
            <div class="gen-item-icon indiv" v-html="icons.user"></div>
            <div class="gen-item-text">
              <div class="gen-item-title">Habilitation Individuelle</div>
              <div class="gen-item-sub">Attestation personnelle</div>
            </div>
          </div>
          <div class="gen-dropdown-item" @click="setType('note'); isOpen = false">
            <div class="gen-item-icon note" v-html="icons.list"></div>
            <div class="gen-item-text">
              <div class="gen-item-title">Note d'Habilitation</div>
              <div class="gen-item-sub">Liste des employés habilités</div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <div class="loading-state" v-if="loading">
      <div class="loader"></div>
    </div>

    <!-- ── Form ───────────────────────────────────────── -->
    <div class="form-card" v-if="activeType">
      <!-- ── Individuelle ──────────────────────────────── -->
      <template v-if="activeType === 'individuelle'">
        <div class="form-section-title">
          Sélectionner l'employé et l'habilitation
        </div>

        <div class="form-grid">
          <!-- Département -->
          <div class="field">
            <label>Département <span class="required">*</span></label>
            <select v-model="ind.departement_id" @change="onIndDepartementChange" :disabled="loadingRefs">
              <option value="" disabled>
                {{ loadingRefs ? '⏳ Chargement...' : 'Sélectionner un département' }}
              </option>
              <option v-if="!loadingRefs" v-for="d in departements" :key="d.id" :value="d.id">
                {{ d.nom }}
              </option>
            </select>
            <span class="select-loading-hint" v-if="loadingRefs">
              <span class="mini-spinner"></span>
              Chargement des données...
            </span>
          </div>

          <!-- Service -->
          <div class="field">
            <label>Service <span class="required">*</span></label>
            <select v-model="ind.service_id" @change="onIndServiceChange" :disabled="!ind.departement_id">
              <option value="">Sélectionner un service</option>
              <option v-for="s in indFilteredServices" :key="s.id" :value="s.id">
                {{ s.nom }}
              </option>
            </select>
          </div>

          <!-- Salarié -->
          <div class="field">
            <label>
              Salarié <span class="required">*</span>
              <span class="hint" v-if="!ind.service_id">
                — sélectionnez un service d'abord
              </span>
            </label>
            <select v-model="ind.employee_id" @change="onEmployeeChange" :disabled="!ind.service_id">
              <option value="">Sélectionner un employé</option>
              <option v-for="e in indFilteredEmployees" :key="e.id" :value="e.id">
                {{ e.nom }} {{ e.prenom }} — {{ e.matricule }}
              </option>
            </select>
          </div>

          <!-- Employé habilitation select -->
          <div class="field">
            <label>
              Habilitation <span class="required">*</span>
              <span class="hint" v-if="!ind.employee_id">
                — sélectionnez un employé d'abord
              </span>
            </label>
            <select v-model="ind.employee_habilitation_id" :disabled="!ind.employee_id || loadingHabs">
              <option value="" disabled v-if="loadingHabs">
                ⏳ Chargement...
              </option>
              <option value="" disabled
                v-else-if="!loadingHabs && employeeHabilitations.length === 0 && ind.employee_id">
                ❌ Aucune habilitation trouvée pour cet employé
              </option>
              <option value="" disabled v-else>
                Sélectionner une habilitation
              </option>
              <option v-if="!loadingHabs" v-for="eh in employeeHabilitations" :key="eh.employee_habilitation_id"
                :value="eh.employee_habilitation_id">
                {{ eh.habilitation_nom }} — Obtenu le {{ eh.date_obtention }} ({{ eh.statut }})
              </option>
            </select>
          </div>
        </div>

        <!-- Preview card -->
        <div class="preview-card" v-if="selectedEH">
          <div class="preview-title">Aperçu du document</div>
          <div class="preview-grid">
            <div class="preview-item">
              <span class="preview-label">Salarié</span>
              <span class="preview-value">{{ selectedEH.nom_complet }}</span>
            </div>
            <div class="preview-item">
              <span class="preview-label">Matricule</span>
              <span class="preview-value">{{ selectedEH.matricule }}</span>
            </div>
            <div class="preview-item">
              <span class="preview-label">Habilitation</span>
              <span class="preview-value">{{ selectedEH.habilitation }}</span>
            </div>
            <div class="preview-item">
              <span class="preview-label">Service</span>
              <span class="preview-value">{{ selectedEH.service }}</span>
            </div>
            <div class="preview-item">
              <span class="preview-label">Date obtention</span>
              <span class="preview-value">{{ selectedEH.date_obtention }}</span>
            </div>
            <div class="preview-item">
              <span class="preview-label">Date expiration</span>
              <span class="preview-value">{{ selectedEH.date_expiration }}</span>
            </div>
          </div>
        </div>

        <div class="form-actions">
          <button class="btn-generate" @click="generateIndividuelle()"
            :disabled="!ind.employee_habilitation_id || generating">
            <span v-if="generating" class="spinner"></span>
            <span v-else v-html="icons.download"></span>
            Générer et télécharger
          </button>
        </div>
      </template>

      <!-- ── Note d'habilitation ────────────────────────── -->
      <template v-if="activeType === 'note'">
        <div class="form-section-title">
          Sélectionner l'habilitation
        </div>

        <div class="form-grid">
          <!-- Catégorie filter -->
          <div class="field">
            <label>Catégorie</label>
            <select v-model="note.volet_id" @change="note.habilitation_id = ''">
              <option value="">Toutes les catégories</option>
              <option v-for="v in volets" :key="v.id" :value="v.id">
                {{ v.nom }}
              </option>
            </select>
          </div>

          <!-- Habilitation -->
          <div class="field">
            <label>Habilitation <span class="required">*</span></label>
            <select v-model="note.habilitation_id" @change="fetchEmployeesParHabilitation">
              <option value="">Sélectionner une habilitation</option>
              <optgroup v-for="volet in voletsWithHabilitations" :key="volet.id" :label="volet.nom">
                <option v-for="h in volet.habilitations" :key="h.id" :value="h.id">
                  {{ h.nom }}
                </option>
              </optgroup>
            </select>
          </div>
        </div>

        <!-- Employees preview table -->
        <div class="employees-preview" v-if="note.habilitation_id">
          <div class="preview-title">
            Salariés habilités
            <span class="count-badge">{{ noteEmployees.length }}</span>
          </div>

          <div class="loading-state" v-if="loadingNoteEmployees">
            <div class="loader"></div>
          </div>

          <div class="empty-state" v-else-if="noteEmployees.length === 0">
            <span v-html="icons.users"></span>
            <p>Aucun employé valide pour cette habilitation.</p>
          </div>

          <table class="preview-table" v-else>
            <thead>
              <tr>
                <th>Matricule</th>
                <th>Nom & Prénom</th>
                <th>Fonction</th>
                <th>Service</th>
                <th>Date obtention</th>
                <th>Date expiration</th>
                <th>Statut</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="emp in noteEmployees" :key="emp.employee_habilitation_id">
                <td>
                  <span class="matricule-badge">{{ emp.matricule }}</span>
                </td>
                <td class="td-name">{{ emp.nom_complet }}</td>
                <td class="td-muted">{{ emp.position }}</td>
                <td class="td-muted">{{ emp.service }}</td>
                <td class="td-muted">{{ emp.date_obtention }}</td>
                <td class="td-muted">{{ emp.date_expiration }}</td>
                <td>
                  <span class="statut-badge valide">{{ emp.statut }}</span>
                </td>
              </tr>
            </tbody>
          </table>
        </div>

        <div class="form-actions">
          <button class="btn-generate" @click="generateNote" :disabled="!note.habilitation_id ||
            noteEmployees.length === 0 || generating">
            <span v-if="generating" class="spinner"></span>
            <span v-else v-html="icons.download"></span>
            Générer et télécharger
          </button>
        </div>
      </template>
    </div>

    <!-- ── NEW SEARCH SECTION (added above document table) ── -->
    <div class="search-section-card" v-if="!activeType && !loading">
      <div class="search-row">
        <!-- Nom, matricule ou département... -->
        <div class="search-input-group">
          <label>🔍 RECHERCHE</label>
          <div class="search-input-wrapper">
            <span class="search-icon">
              <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8">
                <circle cx="10" cy="10" r="7"></circle>
                <line x1="21" y1="21" x2="15" y2="15"></line>
              </svg>
            </span>
            <input type="text" v-model="searchQuery" placeholder="Nom, matricule ou département...">
          </div>
        </div>

        <!-- Type de document filter -->
        <div class="filter-group">
          <label>📄 TYPE DE DOCUMENT</label>
          <select class="custom-select" v-model="selectedTypeFilter">
            <option value="all">Tous les types</option>
            <option value="initiale">Habilitation initiale</option>
            <option value="note">Note d'Habilitation</option>
          </select>
        </div>

        <!-- Période filter -->
        <div class="filter-group">
          <label>📅 PÉRIODE</label>
          <select class="custom-select" v-model="selectedDateFilter">
            <option value="all">Toutes les dates</option>
            <option value="recent">30 derniers jours</option>
            <option value="older">Plus ancien</option>
          </select>
        </div>

        <!-- Statut filter -->
        <div class="filter-group">
          <label>⚙️ STATUT</label>
          <select class="custom-select" v-model="selectedStatusFilter">
            <option value="all">Tous les statuts</option>
            <option value="downloaded">Téléchargé</option>
            <option value="generated">Généré</option>
          </select>
        </div>
      </div>

      <div class="results-badge">
        <span class="doc-count">{{ filteredDocs.length }} document{{ filteredDocs.length > 1 ? 's' : '' }} trouvé{{
          filteredDocs.length > 1 ? 's' : '' }}</span>
        <span class="filter-summary" v-if="activeFiltersCount">Filtres actifs</span>
      </div>
    </div>

    <!-- Document Table Card (with search integration) -->
    <div class="doc-table-card" v-if="!activeType && !loading">
      <table class="doc-data-table">
        <thead>
          <th>Document</th>
          <th>Employé</th>
          <th>Date</th>
          <th>Statut</th>
          <th>Actions</th>
        </thead>
        <tbody>
          <tr v-for="doc in paginatedFilteredDocs" :key="doc.id" class="doc-row">
            <!-- Document -->
            <td>
              <div class="doc-cell">
                <div class="doc-icon" :class="doc.type === 'individuelle' ? 'icon-indiv' : 'icon-note'">
                  <span v-html="doc.type === 'individuelle' ? icons.user : icons.file"></span>
                </div>
                <div>
                  <div class="doc-name">{{ doc.habilitation_nom }}</div>
                  <span class="doc-type-badge">
                    {{ doc.employee_habilitation?.type === 'initiale' ? 'Habilitation initiale' : 'Note d\'Habilitation'
                    }}
                  </span>
                </div>
              </div>
            </td>

            <!-- Employé -->
            <td>
              <template v-if="doc.employee_nom">
                <div class="doc-emp-name">{{ doc.employee_nom }} {{ doc.employee_prenom }}</div>
                <div class="doc-emp-mat">Mat. {{ doc.employee_matricule ?? '—' }}</div>
              </template>
              <span v-else class="doc-general">Document général</span>
            </td>

            <!-- Date -->
            <td>
              <div class="doc-date">
                <span v-html="icons.calendar"></span>
                {{ formatDate(doc.created_at) }}
              </div>
              <div class="doc-recent" v-if="isRecent(doc.created_at)">
                <span v-html="icons.clock"></span> Récent
              </div>
            </td>

            <!-- Statut -->
            <td>
              <span class="doc-statut" :class="doc.downloaded ? 'telecharge' : 'genere'">
                {{ doc.downloaded ? 'Téléchargé' : 'Généré' }}
              </span>
            </td>

            <!-- Actions -->
            <td>
              <div class="doc-actions">
                <button class="doc-btn preview" title="Aperçu" @click="previewDocument(doc)">
                  <span v-html="icons.eye"></span>
                </button>
                <button class="doc-btn download" title="Télécharger" @click="downloadDocument(doc)">
                  <span v-html="icons.download"></span>
                </button>
              </div>
            </td>
          </tr>
          <tr v-if="filteredDocs.length === 0">
            <td colspan="5" style="text-align: center; padding: 2rem;">Aucun document correspondant aux critères</td>
          </tr>
        </tbody>
      </table>

      <!-- Pagination for filtered results -->
      <div class="doc-pagination" v-if="filteredTotalPages > 1">
        <button class="page-btn" :disabled="filteredCurrentPage === 1" @click="filteredCurrentPage--">
          <span v-html="icons.chevronLeft"></span>
        </button>
        <button v-for="p in filteredTotalPages" :key="p" class="page-btn" :class="{ active: p === filteredCurrentPage }"
          @click="filteredCurrentPage = p">{{ p }}</button>
        <button class="page-btn" :disabled="filteredCurrentPage === filteredTotalPages" @click="filteredCurrentPage++">
          <span v-html="icons.chevronRight"></span>
        </button>
      </div>
    </div>

  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue';
import api from '@/services/api';
import '@/../css/components/documents/document-generation.css';
import { useRoute } from 'vue-router';

const loading = ref(false);
const loadingRefs = ref(true);
const activeType = ref(null);
const generating = ref(false);
const loadingHabs = ref(false);
const loadingNoteEmployees = ref(false);
const route = useRoute();
const departements = ref([]);
const services = ref([]);
const employees = ref([]);
const habilitations = ref([]);
const volets = ref([]);
const employeeHabilitations = ref([]);
const noteEmployees = ref([]);
const documents = ref([]);

// ── Search & Filter State ──────────────────────────────
const searchQuery = ref('');
const selectedTypeFilter = ref('all');
const selectedDateFilter = ref('all');
const selectedStatusFilter = ref('all');
const filteredCurrentPage = ref(1);
const filterPageSize = 8;

// ── Individuelle form ─────────────────────────────────
const ind = reactive({
  departement_id: '',
  service_id: '',
  employee_id: '',
  employee_habilitation_id: '',
});

// ── Note form ─────────────────────────────────────────
const note = reactive({
  volet_id: '',
  habilitation_id: '',
});

// ── Icons ─────────────────────────────────────────────
const icons = {
  chevronDown: `<svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7"/></svg>`,
  eye: `<svg xmlns="http://www.w3.org/2000/svg" width="15" height="15" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"/><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"/></svg>`,
  refresh: `<svg xmlns="http://www.w3.org/2000/svg" width="15" height="15" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"/></svg>`,
  calendar: `<svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"/></svg>`,
  clock: `<svg xmlns="http://www.w3.org/2000/svg" width="11" height="11" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>`,
  chevronLeft: `<svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7"/></svg>`,
  chevronRight: `<svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7"/></svg>`,
  user: `<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"/></svg>`,
  file: `<svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5"><path d="M13 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V9z"></path><polyline points="13 2 13 9 20 9"></polyline></svg>`,
  list: `<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2m-3 7h3m-3 4h3m-6-4h.01M9 16h.01"/></svg>`,
  check: `<svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M5 13l4 4L19 7"/></svg>`,
  download: `<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4"/></svg>`,
  users: `<svg xmlns="http://www.w3.org/2000/svg" width="40" height="40" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0z"/></svg>`,
};

const formatDate = (dateStr) => {
  if (!dateStr) return '—';
  const d = new Date(dateStr);
  return d.toLocaleDateString('fr-FR') + ' ' + d.toLocaleTimeString('fr-FR', { hour: '2-digit', minute: '2-digit' });
};

const isRecent = (dateStr) => {
  if (!dateStr) return false;
  const diff = (Date.now() - new Date(dateStr)) / (1000 * 60 * 60 * 24);
  return diff <= 30;
};

// ── FILTERED DOCUMENTS (with search, type, date, status) ──
const filteredDocs = computed(() => {
  let result = [...documents.value];

  // 1. Text search (nom, matricule, département, habilitation nom)
  if (searchQuery.value.trim()) {
    const query = searchQuery.value.trim().toLowerCase();
    result = result.filter(doc => {
      const fullName = (doc.employee_nom && doc.employee_prenom) ? `${doc.employee_nom} ${doc.employee_prenom}`.toLowerCase() : '';
      const matricule = (doc.employee_matricule || '').toLowerCase();
      const dept = (doc.employee_departement || '').toLowerCase();
      const habName = (doc.habilitation_nom || '').toLowerCase();
      return fullName.includes(query) || matricule.includes(query) || dept.includes(query) || habName.includes(query);
    });
  }

  // 2. Type filter (initiale / note)
  if (selectedTypeFilter.value !== 'all') {
    result = result.filter(doc => {
      const habType = doc.employee_habilitation?.type;
      if (selectedTypeFilter.value === 'initiale') return habType === 'initiale';
      if (selectedTypeFilter.value === 'note') return habType === 'note';
      return true;
    });
  }

  // 3. Date filter (recent: 30 days, older: beyond 30 days)
  if (selectedDateFilter.value !== 'all') {
    const now = new Date();
    const thirtyDaysAgo = new Date();
    thirtyDaysAgo.setDate(now.getDate() - 30);
    result = result.filter(doc => {
      const docDate = new Date(doc.created_at);
      if (selectedDateFilter.value === 'recent') return docDate >= thirtyDaysAgo;
      if (selectedDateFilter.value === 'older') return docDate < thirtyDaysAgo;
      return true;
    });
  }

  // 4. Status filter (downloaded / generated)
  if (selectedStatusFilter.value !== 'all') {
    result = result.filter(doc => {
      if (selectedStatusFilter.value === 'downloaded') return doc.downloaded === true;
      if (selectedStatusFilter.value === 'generated') return doc.downloaded === false;
      return true;
    });
  }

  return result;
});

const filteredTotalPages = computed(() => Math.ceil(filteredDocs.value.length / filterPageSize));
const paginatedFilteredDocs = computed(() => {
  const start = (filteredCurrentPage.value - 1) * filterPageSize;
  const end = start + filterPageSize;
  return filteredDocs.value.slice(start, end);
});

const activeFiltersCount = computed(() => {
  let count = 0;
  if (searchQuery.value) count++;
  if (selectedTypeFilter.value !== 'all') count++;
  if (selectedDateFilter.value !== 'all') count++;
  if (selectedStatusFilter.value !== 'all') count++;
  return count;
});

// Reset filter page when filters change
const resetFilterPage = () => { filteredCurrentPage.value = 1; };


// ── Computed ──────────────────────────────────────────
const indFilteredServices = computed(() =>
  ind.departement_id
    ? services.value.filter(s => s.departement_id == ind.departement_id)
    : []
);

const indFilteredEmployees = computed(() =>
  ind.service_id
    ? employees.value.filter(e => e.service_id == ind.service_id)
    : []
);

const voletsWithHabilitations = computed(() => {
  return volets.value.map(v => ({
    ...v,
    habilitations: habilitations.value.filter(h =>
      !note.volet_id || h.volet_id == note.volet_id
        ? h.volet_id === v.id
        : false
    ),
  })).filter(v => v.habilitations.length > 0);
});

const selectedEH = computed(() => {
  if (!ind.employee_habilitation_id) return null;
  return employeeHabilitations.value.find(
    eh => eh.employee_habilitation_id == ind.employee_habilitation_id
  ) ?? null;
});



// ── Cascade handlers — individuelle ───────────────────
const onIndDepartementChange = () => {
  ind.service_id = '';
  ind.employee_id = '';
  ind.employee_habilitation_id = '';
  employeeHabilitations.value = [];
};

const onIndServiceChange = () => {
  ind.employee_id = '';
  ind.employee_habilitation_id = '';
  employeeHabilitations.value = [];
};

const onEmployeeChange = async () => {
  ind.employee_habilitation_id = '';
  employeeHabilitations.value = [];
  if (!ind.employee_id) return;

  loadingHabs.value = true;
  try {
    const { data } = await api.get('/employee-habilitations', {
      params: { employee_id: ind.employee_id }
    });
    employeeHabilitations.value = data.map(eh => ({
      employee_habilitation_id: eh.id,
      habilitation_nom: eh.habilitation?.nom,
      date_obtention: new Date(eh.date_obtention).toLocaleDateString('fr-FR'),
      date_expiration: new Date(eh.date_expiration).toLocaleDateString('fr-FR'),
      statut: eh.statut,
      nom_complet: `${eh.employee?.prenom} ${eh.employee?.nom}`,
      matricule: eh.employee?.matricule,
      habilitation: eh.habilitation?.nom,
      service: eh.employee?.service?.nom,
    }));
  } catch (e) {
    console.error(e);
  } finally {
    loadingHabs.value = false;
  }
};

// ── Fetch employees for note ──────────────────────────
const fetchEmployeesParHabilitation = async () => {
  if (!note.habilitation_id) return;
  loadingNoteEmployees.value = true;
  noteEmployees.value = [];
  try {
    const { data } = await api.get(
      `/documents/employees-par-habilitation/${note.habilitation_id}`
    );
    noteEmployees.value = data.employees;
  } catch (e) {
    console.error(e);
  } finally {
    loadingNoteEmployees.value = false;
  }
};

// ── Generate individuelle ─────────────────────────────
const generateIndividuelle = async (id) => {
  generating.value = true;
  try {
    const response = await api.post(
      '/documents/generate/individuelle',
      { employee_habilitation_id: id || ind.employee_habilitation_id },
      { responseType: 'blob' }
    );
    downloadBlob(response);
  } catch (e) {
    console.error(e);
    alert('Erreur lors de la génération du document.');
  } finally {
    loading.value = false;
    generating.value = false;
  }
};

// ── Generate note ─────────────────────────────────────
const generateNote = async () => {
  generating.value = true;
  try {
    const response = await api.post(
      '/documents/generate/note',
      { habilitation_id: note.habilitation_id },
      { responseType: 'blob' }
    );
    downloadBlob(response);
  } catch (e) {
    console.error(e);
    alert('Erreur lors de la génération du document.');
  } finally {
    generating.value = false;
  }
};

// ── Download blob helper ──────────────────────────────
const downloadBlob = (response) => {

  const disposition = response.headers['content-disposition'] ?? '';
  const match = disposition.match(/filename="?([^"]+)"?/);
  const filename = match ? match[1] : 'document.pdf';

  const url = window.URL.createObjectURL(new Blob([response.data]));
  const link = document.createElement('a');
  link.href = url;
  link.setAttribute('download', filename);
  document.body.appendChild(link);
  link.click();
  link.remove();
  window.URL.revokeObjectURL(url);
};

// ── Fetch referentials ────────────────────────────────
const fetchAll = async () => {
  fetchDocuments();
  loadingRefs.value = true;
  try {
    const [depRes, svcRes, empRes, habRes, volRes] = await Promise.all([
      api.get('/departements'),
      api.get('/services'),
      api.get('/employees'),
      api.get('/habilitations'),
      api.get('/volets'),
    ]);
    departements.value = depRes.data;
    services.value = svcRes.data;
    employees.value = empRes.data;
    habilitations.value = habRes.data;
    volets.value = volRes.data;
  } finally {
    loadingRefs.value = false;
  }
};

const fetchDocuments = async () => {
  try {
    const { data } = await api.get('/documents/all');
    documents.value = data;
    console.log('Documents fetched:', data);
  } catch (e) {
    console.error(e);
  }
};

const downloadDocument = async (doc) => {
  try {
    const response = await api.get(`/documents/download/${doc.id}`, {
      responseType: 'blob'
    });
    downloadBlob(response);
  } catch (e) {
    console.error(e);
  }
};

const previewDocument = async (doc) => {
  try {
    const response = await api.get(`/documents/download/${doc.id}`, {
      responseType: 'blob'
    });
    const blob = new Blob([response.data], { type: 'application/pdf' });
    const url = URL.createObjectURL(blob);
    window.open(url, '_blank');
  } catch (e) {
    console.error(e);
    alert('Erreur lors de l\'aperçu du document.');
  }
};

const isOpen = ref(false);
const setType = (type) => {
  activeType.value = type;
  isOpen.value = false;
};

const goBack = () => {
  activeType.value = null;
};
onMounted(() => {
  fetchAll();
  if (route.params.id) {
    loading.value = true;
    generateIndividuelle(Number(route.params.id));
  }
});
</script>

<style scoped>
.page-title-block {
  display: flex;
  align-items: center;
  gap: 12px;
}

.btn-back-doc {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 34px;
  height: 34px;
  min-width: 34px;
  background: white;
  border: 1px solid #e8ecf0;
  border-radius: 8px;
  cursor: pointer;
  color: #374151;
  transition: background 0.15s;
}

.btn-back-doc:hover {
  background: #f0f7ff;
  color: #1a6b8a;
  border-color: #1a6b8a;
}

.gen-dropdown {
  position: relative;
  display: inline-flex;
}

.gen-btn-group {
  display: flex;
  align-items: stretch;
  border-radius: 10px;
  overflow: hidden;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
}

.gen-btn-main {
  display: flex;
  align-items: center;
  gap: 7px;
  padding: 9px 16px;
  background: #1a4a6b;
  color: white;
  border: none;
  font-size: 0.875rem;
  font-weight: 600;
  cursor: pointer;
  transition: background 0.15s;
}

.gen-btn-main:hover {
  background: #1a5a80;
}

.gen-btn-arrow {
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 0 10px;
  background: #1a5a80;
  color: white;
  border: none;
  border-left: 1px solid rgba(255, 255, 255, 0.2);
  cursor: pointer;
  transition: background 0.15s;
}

.gen-btn-arrow:hover {
  background: #1a6b8a;
}

.gen-dropdown-menu {
  position: absolute;
  top: calc(100% + 8px);
  right: 0;
  background: white;
  border: 1px solid #e8ecf0;
  border-radius: 12px;
  padding: 6px;
  min-width: 240px;
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.12);
  z-index: 100;
}

.gen-dropdown-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 10px 12px;
  border-radius: 8px;
  cursor: pointer;
  transition: background 0.12s;
}

.gen-dropdown-item:hover {
  background: #f8fafc;
}

.gen-item-icon {
  width: 36px;
  height: 36px;
  min-width: 36px;
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.gen-item-icon.indiv {
  background: #eff6ff;
  color: #1a6b8a;
}

.gen-item-icon.note {
  background: #f5f3ff;
  color: #7c3aed;
}

.gen-item-title {
  font-size: 0.875rem;
  font-weight: 600;
  color: #1a2e44;
}

.gen-item-sub {
  font-size: 0.75rem;
  color: #9ca3af;
  margin-top: 2px;
}

.search-section-card {
  background: white;
  border-radius: 20px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.04);
  margin-bottom: 24px;
  padding: 20px 24px;
  transition: all 0.2s;
}

.search-row {
  display: flex;
  flex-wrap: wrap;
  align-items: flex-end;
  gap: 16px;
  margin-bottom: 20px;
}

.search-input-group {
  flex: 2;
  min-width: 240px;
}

.search-input-group label {
  display: block;
  font-size: 0.75rem;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.5px;
  color: #5b6e8c;
  margin-bottom: 6px;
}

.search-input-wrapper {
  display: flex;
  align-items: center;
  background: #f8fafd;
  border: 1px solid #e2e8f0;
  border-radius: 14px;
  padding: 0 12px;
  transition: all 0.2s;
}

.search-input-wrapper:focus-within {
  border-color: #3b82f6;
  box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.15);
  background: white;
}

.search-icon {
  color: #94a3b8;
  margin-right: 8px;
  display: flex;
  align-items: center;
}

.search-input-wrapper input {
  width: 100%;
  padding: 12px 0;
  border: none;
  background: transparent;
  font-size: 0.95rem;
  font-weight: 500;
  outline: none;
  font-family: 'Inter', sans-serif;
}

.search-input-wrapper input::placeholder {
  color: #b9c3d4;
  font-weight: 400;
}

.filter-group {
  flex: 1;
  min-width: 160px;
}

.filter-group label {
  display: block;
  font-size: 0.75rem;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.5px;
  color: #5b6e8c;
  margin-bottom: 6px;
}

.custom-select {
  width: 100%;
  padding: 12px 12px;
  background: #f8fafd;
  border: 1px solid #e2e8f0;
  border-radius: 14px;
  font-size: 0.9rem;
  font-weight: 500;
  color: #1e293b;
  font-family: 'Inter', sans-serif;
  cursor: pointer;
  outline: none;
  transition: all 0.2s;
}

.custom-select:focus {
  border-color: #3b82f6;
  box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.15);
}

.results-badge {
  display: flex;
  align-items: center;
  gap: 8px;
  border-top: 1px solid #edf2f7;
  padding-top: 18px;
  margin-top: 8px;
}

.doc-count {
  background: #eef2ff;
  color: #1e40af;
  font-size: 0.85rem;
  font-weight: 600;
  padding: 5px 12px;
  border-radius: 40px;
}

.filter-summary {
  font-size: 0.85rem;
  color: #475569;
}

/* Document table styles (already present in your CSS, but ensure they match) */
.doc-table-card {
  background: white;
  border-radius: 24px;
  box-shadow: 0 8px 20px rgba(0, 0, 0, 0.03);
  overflow-x: auto;
  padding: 4px 0;
}

.doc-data-table {
  width: 100%;
  border-collapse: collapse;
  font-size: 0.85rem;
  min-width: 800px;
}


.custom-dropdown {
  padding: 5px;
  border-radius: 12px;
  min-width: 280px;
}

/* Card style */
.dropdown-card {
  display: flex;
  align-items: center;
  gap: 5px;
  padding: 2px;
  border-radius: 12px;
  cursor: pointer;
  transition: all 0.2s ease;
}


/* Hover effect */
.dropdown-card:hover {
  background-color: #e9eef5;
}

/* Icon box */
.icon-box {
  width: 20px;
  height: 20px;
  background-color: #dbe6f4;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
}

/* Text */
.text-content .title {
  font-weight: 400;
  font-size: 12px;
  color: #2c3e50;
}

.text-content .subtitle {
  font-size: 13px;
  color: #7f8c8d;
}

.doc-data-table th {
  text-align: left;
  padding: 1rem 1rem 0.75rem 1.5rem;
  font-weight: 600;
  color: #4a5b7a;
  border-bottom: 1px solid #eef2ff;
  font-size: 0.75rem;
  letter-spacing: 0.3px;
}

.doc-data-table td {
  padding: 1rem 1rem 1rem 1.5rem;
  border-bottom: 1px solid #f1f4f9;
  vertical-align: middle;
}

.doc-row:hover {
  background-color: #fafcff;
}

.doc-cell {
  display: flex;
  align-items: center;
  gap: 12px;
}

.doc-icon {
  width: 40px;
  height: 40px;
  border-radius: 14px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.icon-indiv {
  background: #eef2ff;
  color: #2563eb;
}

.icon-note {
  background: #f1f5f9;
  color: #475569;
}

.doc-name {
  font-weight: 700;
  color: #0f172a;
  margin-bottom: 4px;
  font-size: 0.9rem;
}

.doc-type-badge {
  font-size: 0.7rem;
  background: #f1f5f9;
  padding: 2px 10px;
  border-radius: 50px;
  color: #334155;
  font-weight: 500;
}

.doc-emp-name {
  font-weight: 600;
  color: #0f172a;
}

.doc-emp-mat {
  font-size: 0.7rem;
  color: #62748c;
  margin-top: 4px;
}

.doc-general {
  background: #fef9e3;
  color: #b45309;
  font-size: 0.7rem;
  font-weight: 600;
  padding: 4px 10px;
  border-radius: 30px;
}

.doc-date {
  display: flex;
  align-items: center;
  gap: 6px;
  color: #2c3e66;
  font-weight: 500;
}

.doc-recent {
  margin-top: 6px;
  display: flex;
  align-items: center;
  gap: 4px;
  font-size: 0.7rem;
  color: #10b981;
  background: #eefaf5;
  width: fit-content;
  padding: 2px 10px;
  border-radius: 30px;
  font-weight: 500;
}

.doc-statut {
  font-size: 0.75rem;
  font-weight: 600;
  padding: 5px 12px;
  border-radius: 40px;
  display: inline-block;
}

.telecharge {
  background: #e0f2fe;
  color: #0284c7;
}

.genere {
  background: #f1f5f9;
  color: #475569;
}

.doc-actions {
  display: flex;
  gap: 12px;
}

.doc-btn {
  background: transparent;
  border: none;
  cursor: pointer;
  padding: 6px;
  border-radius: 10px;
  transition: all 0.2s;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  color: #5f7f9e;
}

.doc-btn:hover {
  background: #f1f5f9;
  color: #1e40af;
}

.doc-pagination {
  display: flex;
  justify-content: flex-end;
  gap: 8px;
  padding: 1rem 1.5rem 1.2rem;
  border-top: 1px solid #edf2f7;
  margin-top: 6px;
}

.page-btn {
  background: white;
  border: 1px solid #e2e8f0;
  border-radius: 10px;
  padding: 6px 12px;
  font-size: 0.8rem;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s;
  color: #334155;
}

.page-btn.active {
  background: #2563eb;
  border-color: #2563eb;
  color: white;
}

.page-btn:disabled {
  opacity: 0.4;
  cursor: not-allowed;
}
</style>