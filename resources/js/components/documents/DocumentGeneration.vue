<template>
  <div class="document-generation">

    <!-- ── Header ─────────────────────────────────────── -->
    <div class="page-header">
      <div>
        <h1 class="page-title">Génération de Documents</h1>
        <p class="page-subtitle">
          Générer les attestations et notes d'habilitation
        </p>
      </div>
    </div>

    <!-- ── Document type cards ────────────────────────── -->
    <div class="doc-type-grid">

      <!-- Card 1 — Habilitation Individuelle -->
      <div class="doc-type-card" :class="{ active: activeType === 'individuelle' }" @click="setType('individuelle')">
        <div class="doc-type-icon" v-html="icons.user"></div>
        <div class="doc-type-info">
          <div class="doc-type-title">Habilitation Individuelle</div>
          <div class="doc-type-desc">
            Attestation personnelle pour un employé et une habilitation
          </div>
        </div>
        <div class="doc-type-check" v-if="activeType === 'individuelle'" v-html="icons.check">
        </div>
      </div>

      <!-- Card 2 — Note d'Habilitation -->
      <div class="doc-type-card" :class="{ active: activeType === 'note' }" @click="setType('note')">
        <div class="doc-type-icon" v-html="icons.list"></div>
        <div class="doc-type-info">
          <div class="doc-type-title">Note d'Habilitation</div>
          <div class="doc-type-desc">
            Liste de tous les employés habilités pour une habilitation
          </div>
        </div>
        <div class="doc-type-check" v-if="activeType === 'note'" v-html="icons.check">
        </div>
      </div>

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

              <!-- Loading state -->
              <option value="" disabled v-if="loadingHabs">
                ⏳ Chargement...
              </option>

              <!-- Empty state — employee has no habilitations -->
              <option value="" disabled
                v-else-if="!loadingHabs && employeeHabilitations.length === 0 && ind.employee_id">
                ❌ Aucune habilitation trouvée pour cet employé
              </option>

              <!-- Default placeholder -->
              <option value="" disabled v-else>
                Sélectionner une habilitation
              </option>

              <!-- Options -->
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
          <button class="btn-generate" @click="generateIndividuelle"
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

          <!-- Volet filter -->
          <div class="field">
            <label>Volet</label>
            <select v-model="note.volet_id" @change="note.habilitation_id = ''">
              <option value="">Tous les volets</option>
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

  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue';
import api from '@/services/api';
import '@/../css/components/documents/document-generation.css';

const loadingRefs = ref(true);
const activeType = ref(null);
const generating = ref(false);
const loadingHabs = ref(false);
const loadingNoteEmployees = ref(false);

const departements = ref([]);
const services = ref([]);
const employees = ref([]);
const habilitations = ref([]);
const volets = ref([]);
const employeeHabilitations = ref([]);
const noteEmployees = ref([]);

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
  user: `<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"/></svg>`,
  list: `<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2m-3 7h3m-3 4h3m-6-4h.01M9 16h.01"/></svg>`,
  check: `<svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M5 13l4 4L19 7"/></svg>`,
  download: `<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4"/></svg>`,
  users: `<svg xmlns="http://www.w3.org/2000/svg" width="40" height="40" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0z"/></svg>`,
};

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

// ── Set document type ─────────────────────────────────
const setType = (type) => {
  activeType.value = type;
  // Reset forms
  Object.assign(ind, {
    departement_id: '', service_id: '',
    employee_id: '', employee_habilitation_id: '',
  });
  Object.assign(note, { volet_id: '', habilitation_id: '' });
  employeeHabilitations.value = [];
  noteEmployees.value = [];
};

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
    // Fetch all habilitations for selected employee
    const { data } = await api.get('/employee-habilitations', {
      params: { employee_id: ind.employee_id }
    });
    // Map to dropdown-friendly format
    employeeHabilitations.value = data.map(eh => ({
      employee_habilitation_id: eh.id,
      habilitation_nom: eh.habilitation?.nom,
      date_obtention: new Date(eh.date_obtention)
        .toLocaleDateString('fr-FR'),
      date_expiration: new Date(eh.date_expiration)
        .toLocaleDateString('fr-FR'),
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
const generateIndividuelle = async () => {
  generating.value = true;
  try {
    const response = await api.post(
      '/documents/generate/individuelle',
      { employee_habilitation_id: ind.employee_habilitation_id },
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

  };
};

onMounted(fetchAll);
</script>