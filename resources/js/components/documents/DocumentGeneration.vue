<template>
  <div class="document-generation">

    <!-- ── Header ─────────────────────────────────────── -->
    <div class="page-header">
      <div class="page-title-block">
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
      <div class="gen-dropdown" v-if="!activeType && !isManager " v-click-outside="() => isOpen = false">
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
          </div>

          <div class="field">
            <label>Service <span class="required">*</span></label>
            <select v-model="ind.service_id" @change="onIndServiceChange" :disabled="!ind.departement_id">
              <option value="">Sélectionner un service</option>
              <option v-for="s in indFilteredServices" :key="s.id" :value="s.id">
                {{ s.nom }}
              </option>
            </select>
          </div>

          <div class="field">
            <label>Salarié <span class="required">*</span></label>
            <select v-model="ind.employee_id" @change="onEmployeeChange" :disabled="!ind.service_id">
              <option value="">Sélectionner un employé</option>
              <option v-for="e in indFilteredEmployees" :key="e.id" :value="e.id">
                {{ e.nom }} {{ e.prenom }} — {{ e.matricule }}
              </option>
            </select>
          </div>

          <div class="field">
            <label>Habilitation <span class="required">*</span></label>
            <select v-model="ind.employee_habilitation_id" :disabled="!ind.employee_id || loadingHabs">
              <option value="" disabled v-if="loadingHabs">⏳ Chargement...</option>
              <option value="" disabled v-else-if="employeeHabilitations.length === 0 && ind.employee_id">
                ❌ Aucune habilitation
              </option>
              <option value="" disabled v-else>Sélectionner une habilitation</option>
              <option v-for="eh in employeeHabilitations" :key="eh.employee_habilitation_id"
                :value="eh.employee_habilitation_id">
                {{ eh.habilitation_nom }} — {{ eh.date_obtention }}
              </option>
            </select>
          </div>
        </div>

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
          <button class="btn-generate" @click="generateIndividuelle()" :disabled="!ind.employee_habilitation_id || generating">
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
          <div class="field">
            <label>Catégorie</label>
            <select v-model="note.volet_id" @change="note.habilitation_id = ''">
              <option value="">Toutes les catégories</option>
              <option v-for="v in volets" :key="v.id" :value="v.id">
                {{ v.nom }}
              </option>
            </select>
          </div>

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
                <td><span class="matricule-badge">{{ emp.matricule }}</span></td>
                <td class="td-name">{{ emp.nom_complet }}</td>
                <td class="td-muted">{{ emp.position }}</td>
                <td class="td-muted">{{ emp.service }}</td>
                <td class="td-muted">{{ emp.date_obtention }}</td>
                <td class="td-muted">{{ emp.date_expiration }}</td>
                <td><span class="statut-badge valide">{{ emp.statut }}</span></td>
              </tr>
            </tbody>
          </table>
        </div>

        <div class="form-actions">
          <button class="btn-generate" @click="generateNote" :disabled="!note.habilitation_id || noteEmployees.length === 0 || generating">
            <span v-if="generating" class="spinner"></span>
            <span v-else v-html="icons.download"></span>
            Générer et télécharger
          </button>
        </div>
      </template>
    </div>

    <!-- ── SEARCH SECTION ── -->
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

        <div class="filter-groupDoc">
          <label>📄 TYPE DE DOCUMENT</label>
          <select class="custom-select" v-model="selectedTypeFilter">
            <option value="all">Tous les types</option>
            <option value="initiale">Habilitation initiale</option>
            <option value="recyclage">Habilitation de recyclage</option>
          </select>
        </div>

        <!-- Période filter -->
        <div class="filter-groupDoc">
          <label>📅 PÉRIODE</label>
          <select class="custom-select" v-model="selectedDateFilter">
            <option value="all">Toutes les dates</option>
            <option value="recent">30 derniers jours</option>
            <option value="older">Plus ancien</option>
          </select>
        </div>
      </div>

      
    </div>

    <!-- ── TWO COLUMN LAYOUT like the image ── -->
    <div class="two-column-layout" v-if="!activeType && !loading">
      
      <!-- LEFT COLUMN: Habilitations Individuelles -->
      <div class="doc-columnL">
        <div class="column-header">
          <div class="column-icon indiv-icon" v-html="icons.user"></div>
          <h2 class="column-title">Habilitations Individuelles</h2>
        </div>
         <div class="loading-state" v-if="loading">
        <div class="spinner"></div>
        <span>Chargement des documents...</span>
      </div>
      
        
        <div v-else class="column-content">
          <div v-for="group in paginatedIndividualGroups" :key="group.employee_matricule" class="doc-group">
            <!-- Employee header with initials avatar -->
            <div class="group-header" @click="toggleGroup('ind_' + group.employee_matricule)">
              <div class="group-avatar">
                {{ getInitials(group.employee_nom, group.employee_prenom) }}
              </div>
              <div class="group-info">
                <div class="group-name">{{ group.employee_nom }} {{ group.employee_prenom }}</div>
                <div class="group-meta">Mat. {{ group.employee_matricule }}</div>
              </div>
              <div class="group-count">{{ group.documents.length }} document(s)</div>
              <span class="group-arrow" :class="{ open: openGroups['ind_' + group.employee_matricule] }">▼</span>
            </div>
            
            <!-- Documents under each employee -->
            <div v-if="openGroups['ind_' + group.employee_matricule]" class="group-documents">
              <div v-for="doc in group.documents" :key="doc.id" class="doc-item">
                <div class="doc-info">
<div class="doc-title">
  {{ doc.habilitation_nom }}
  <span 
    v-if="doc.nom && doc.nom.toLowerCase().includes('recyclage')" 
    class="doc-type doc-recyclage">
    Recyclage
  </span>
  <span 
    v-else 
    class="doc-type doc-initiale">
    Initiale
  </span>
</div>                  <div class="doc-date">
                    <span v-html="icons.calendar"></span>
                    {{ formatDate(doc.created_at) }}
                  </div>
                  <div class="doc-author" v-if="doc.created_by">
                    par {{ doc.created_by }}
                  </div>
                </div>
                <div class="doc-actions">
                  <button class="doc-btn preview" @click="previewDocument(doc)" title="Aperçu">
                    <span v-html="icons.eye"></span>
                  </button>
                  <button class="doc-btn download" @click="downloadDocument(doc)" title="Télécharger">
                    <span v-html="icons.download"></span>
                  </button>
                </div>
              </div>
            </div>
          </div>
          
          <!-- Pagination for individual docs -->
          <div class="column-pagination" v-if="indTotalPages > 1">
            <button class="page-btn" :disabled="indPage === 1" @click="indPage--">‹</button>
            <span class="page-current">{{ indPage }} / {{ indTotalPages }}</span>
            <button class="page-btn" :disabled="indPage === indTotalPages" @click="indPage++">›</button>
          </div>
        </div>
          
      </div>
      
      <!-- RIGHT COLUMN: Notes d'Habilitations -->
      <div class="doc-columnR">
        <div class="column-header">
          <div class="column-icon note-icon" v-html="icons.list"></div>
          <h2 class="column-title">Notes d'Habilitations</h2>
        </div>
        
        <div v-if="filteredNoteDocs.length === 0" class="column-empty">
          <p>Aucune note d'habilitation</p>
        </div>
        
        <div v-else class="column-content">
          <div v-for="group in paginatedNoteGroups" :key="group.habilitation_nom" class="doc-group">
            <!-- Habilitation header -->
            <div class="group-header" @click="toggleGroup('note_' + group.habilitation_nom)">
              <div class="group-icon-note" v-html="icons.file"></div>
              <div class="group-info">
                <div class="group-name">{{ group.habilitation_nom }}</div>
                <div class="group-meta">Document général</div>
              </div>
              <div class="group-count">{{ group.documents.length }} version(s)</div>
              <span class="group-arrow" :class="{ open: openGroups['note_' + group.habilitation_nom] }">▼</span>
            </div>
            
            <!-- Documents under each habilitation -->
            <div v-if="openGroups['note_' + group.habilitation_nom]" class="group-documents">
              <div v-for="doc in group.documents" :key="doc.id" class="doc-item">
                <div class="doc-info">
                  <div class="doc-title">{{ doc.habilitation_nom }}</div>
                  <div class="doc-date">
                    <span v-html="icons.calendar"></span>
                    {{ formatDate(doc.created_at) }}
                  </div>
                  <div class="doc-author" v-if="doc.created_by">
                    par {{ doc.created_by }}
                  </div>
                  <div class="doc-badge">Généré</div>
                </div>
                <div class="doc-actions">
                  <button class="doc-btn preview" @click="previewDocument(doc)" title="Aperçu">
                    <span v-html="icons.eye"></span>
                  </button>
                  <button class="doc-btn download" @click="downloadDocument(doc)" title="Télécharger">
                    <span v-html="icons.download"></span>
                  </button>
                </div>
              </div>
            </div>
          </div>
          
          <!-- Pagination for note docs -->
          <div class="column-pagination" v-if="noteTotalPages > 1">
            <button class="page-btn" :disabled="notePage === 1" @click="notePage--">‹</button>
            <span class="page-current">{{ notePage }} / {{ noteTotalPages }}</span>
            <button class="page-btn" :disabled="notePage === noteTotalPages" @click="notePage++">›</button>
          </div>
        </div>
      </div>
    </div>

  </div>
  <v-overlay :model-value="logoutAlert" class="align-center justify-center">
          <v-progress-circular color="primary" size="24" indeterminate></v-progress-circular>
        </v-overlay>
</template>

<script setup>
import { ref, reactive, computed, onMounted, watch } from 'vue';
import api from '@/services/api';
import { useRoute } from 'vue-router';
import { useAuthStore } from '@/stores/auth';
import '@/../css/components/documents/document-generation.css';

const authStore  = useAuthStore();
const isManager  = computed(() => authStore.user?.role === 'Manager');

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
const isOpen = ref(false);
const openGroups = ref({});
const logoutAlert = ref(false);

const searchQuery = ref('');
const selectedTypeFilter = ref('all');
const selectedDateFilter = ref('all');

const ind = reactive({
  departement_id: '',
  service_id: '',
  employee_id: '',
  employee_habilitation_id: '',
});

const note = reactive({
  volet_id: '',
  habilitation_id: '',
});

const indPage = ref(1);
const notePage = ref(1);
const perPage = 5;

const getInitials = (nom, prenom) => {
  if (!nom && !prenom) return '??';
  return ((prenom?.[0] || '') + (nom?.[0] || '')).toUpperCase();
};

const icons = {
  chevronDown: `<svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7"/></svg>`,
  chevronLeft: `<svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7"/></svg>`,
  eye: `<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"/><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"/></svg>`,
  calendar: `<svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"/></svg>`,
  user: `<svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"/></svg>`,
  file: `<svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5"><path d="M13 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V9z"></path><polyline points="13 2 13 9 20 9"></polyline></svg>`,
  list: `<svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2"/></svg>`,
  download: `<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4"/></svg>`,
  users: `<svg xmlns="http://www.w3.org/2000/svg" width="40" height="40" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0z"/></svg>`,
  plus: `<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"/></svg>`,
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

const filteredDocs = computed(() => {
  let result = [...documents.value];
  
  if (searchQuery.value.trim()) {
     const query = searchQuery.value.trim().toLowerCase();
    result = result.filter(doc => {
      const fullName = (doc.employee_nom && doc.employee_prenom) ? `${doc.employee_nom} ${doc.employee_prenom}`.toLowerCase() : '';
      const matricule = (doc.employee_matricule || '').toString().toLowerCase();
      const habName = (doc.habilitation_nom || '').toLowerCase();
      return fullName.includes(query) || matricule.includes(query) || habName.includes(query);
    });
  }

  if (selectedTypeFilter.value !== 'all') {
    if (selectedTypeFilter.value === 'initiale') {
      result = result.filter(doc => !doc.nom || !doc.nom.toLowerCase().includes('recyclage'));
    } else if (selectedTypeFilter.value === 'recyclage') {  
     result = result.filter(doc => doc.nom.toLowerCase().includes('recyclage'));
    }
  }

  if (selectedDateFilter.value !== 'all') {
    result = result.filter(doc => {
      const docDate = new Date(doc.created_at);
      if (selectedDateFilter.value === 'recent') return isRecent(doc.created_at);
      if (selectedDateFilter.value === 'older') return !isRecent(doc.created_at);
      return true;
    });
  }
  
  return result;
});

const filteredIndividualDocs = computed(() => 
  filteredDocs.value.filter(d => d.type === 'individuelle'  )
  
);

const filteredNoteDocs = computed(() => 
  filteredDocs.value.filter(d => d.type === 'note')
);

const activeFiltersCount = computed(() => {
  let count = 0;
  if (searchQuery.value) count++;
  if (selectedTypeFilter.value !== 'all') count++;
  if (selectedDateFilter.value !== 'all') count++;
  return count;
});

watch([searchQuery, selectedTypeFilter, selectedDateFilter], () => {
  indPage.value = 1;
  notePage.value = 1;
});

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

const individualGroups = computed(() => {
  const groups = {};
  filteredIndividualDocs.value.forEach(doc => {
    const key = doc.employee_matricule ?? 'unknown';
    if (!groups[key]) {
      groups[key] = {
        employee_matricule: doc.employee_matricule,
        employee_nom: doc.employee_nom,
        employee_prenom: doc.employee_prenom,
        documents: [],
      };
    }
    groups[key].documents.push(doc);
  });
  return Object.values(groups);
});

const noteGroups = computed(() => {
  const groups = {};
  filteredNoteDocs.value.forEach(doc => {
    const key = doc.habilitation_nom ?? 'unknown';
    if (!groups[key]) {
      groups[key] = {
        habilitation_nom: doc.habilitation_nom,
        documents: [],
      };
    }
    groups[key].documents.push(doc);
  });
  return Object.values(groups);
});

const paginatedIndividualGroups = computed(() =>
  individualGroups.value.slice((indPage.value - 1) * perPage, indPage.value * perPage)
);

const paginatedNoteGroups = computed(() =>
  noteGroups.value.slice((notePage.value - 1) * perPage, notePage.value * perPage)
);

const indTotalPages = computed(() => Math.ceil(individualGroups.value.length / perPage));
const noteTotalPages = computed(() => Math.ceil(noteGroups.value.length / perPage));

const toggleGroup = (key) => {
  openGroups.value[key] = !openGroups.value[key];
};

const setType = (type) => {
  activeType.value = type;
  isOpen.value = false;
};

const goBack = () => {
  activeType.value = null;
};

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

const generateIndividuelle = async (id) => {
  generating.value = true;
  try {
    const response = await api.post(
      '/documents/generate/individuelle',
      { employee_habilitation_id: id || ind.employee_habilitation_id },
      { responseType: 'blob' }
    );
    downloadBlob(response);
    await fetchDocuments();
  } catch (e) {
    console.error(e);
    alert('Erreur lors de la génération du document.');
  } finally {
    generating.value = false;
  }
};

const generateNote = async () => {
  generating.value = true;
  try {
    const response = await api.post(
      '/documents/generate/note',
      { habilitation_id: note.habilitation_id },
      { responseType: 'blob' }
    );
    downloadBlob(response);
    await fetchDocuments();
  } catch (e) {
    console.error(e);
    alert('Erreur lors de la génération du document.');
  } finally {
    generating.value = false;
  }
};

const fetchDocuments = async () => {
  try {
    loading.value = true;
    const { data } = await api.get('/documents/all');
    documents.value = data.filter(doc => {
      if (doc.type === 'individuelle') {
        return (
          doc.employee_nom &&
          doc.employee_prenom
        );
      }
      return true;
    });

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
     logoutAlert.value = true;
    const response = await api.get(`/documents/download/${doc.id}`, {
      responseType: 'blob'
    });
    const blob = new Blob([response.data], { type: 'application/pdf' });
    const url = URL.createObjectURL(blob);
     logoutAlert.value = false;
    window.open(url, '_blank');
  } catch (e) {
    console.error(e);
    alert('Erreur lors de l\'aperçu du document.');
  }
};

const fetchAll = async () => {
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
    await fetchDocuments();
  } catch (e) {
    console.error(e);
  } finally {
    loadingRefs.value = false;
    loading.value = false;
  }
};

onMounted(() => {
  loading.value = true;
  !isManager.value ?  fetchAll() : fetchDocuments();
   if (route.params.id) {
    generateIndividuelle(Number(route.params.id));
  }
});
</script>

