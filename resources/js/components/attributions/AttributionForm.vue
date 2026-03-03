<template>
  <div class="attribution-form-page">

    <!-- ── Header ─────────────────────────────────────── -->
    <div class="page-header">
      <div class="header-left">
        <button class="btn-back" @click="router.back()">
          <span v-html="icons.back"></span>
        </button>
        <div>
          <h1 class="page-title">Associations Habilitations</h1>
          <p class="page-subtitle">Attribuer une habilitation à un employé</p>
        </div>
      </div>
      <button class="btn-add" @click="openModal()">
        <span v-html="icons.plus"></span>
        Nouvelle association
      </button>
    </div>

    <!-- ── Filters ────────────────────────────────────── -->
    <div class="filters-bar">
      <div class="search-wrapper">
        <span class="search-icon" v-html="icons.search"></span>
        <input
          v-model="filters.search"
          type="text"
          placeholder="Rechercher un employé..."
          class="search-input"
          @input="debouncedFetch"
        />
      </div>

      <select v-model="filters.habilitation_id"
              @change="fetchAttributions" class="filter-select">
        <option value="">Toutes les habilitations</option>
        <option v-for="h in habilitations" :key="h.id" :value="h.id">
          {{ h.nom }}
        </option>
      </select>

      <select v-model="filters.statut"
              @change="fetchAttributions" class="filter-select">
        <option value="">Tous les statuts</option>
        <option value="valide">Valide</option>
        <option value="expirée">Expirée</option>
      </select>
    </div>

    <!-- ── Loading ────────────────────────────────────── -->
    <div class="loading-state" v-if="loading">
      <div class="loader"></div>
    </div>

    <!-- ── Empty ──────────────────────────────────────── -->
    <div class="empty-state" v-else-if="attributions.length === 0">
      <span v-html="icons.link"></span>
      <p>Aucune association trouvée.</p>
    </div>

    <!-- ── Table ──────────────────────────────────────── -->
    <div class="table-card" v-else>
      <table class="data-table">
        <thead>
          <tr>
            <th>Employé</th>
            <th>Habilitation</th>
            <th>Volet</th>
            <th>Type</th>
            <th>Organisme</th>
            <th>Date obtention</th>
            <th>Date expiration</th>
            <th>Statut</th>
            <th>Actions</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="attr in attributions" :key="attr.id" class="table-row">
            <td>
              <div class="employee-cell">
                <div class="avatar">{{ initials(attr.employee) }}</div>
                <div>
                  <div class="emp-name">
                    {{ attr.employee?.nom }} {{ attr.employee?.prenom }}
                  </div>
                  <div class="emp-matricule">
                    {{ attr.employee?.matricule }}
                  </div>
                </div>
              </div>
            </td>
            <td>
              <span class="hab-name">{{ attr.habilitation?.nom }}</span>
            </td>
            <td>
              <span class="volet-tag">{{ attr.habilitation?.volet?.nom }}</span>
            </td>
            <td>
              <span class="type-badge" :class="attr.type">
                {{ attr.type }}
              </span>
            </td>
            <td class="td-muted">{{ attr.organisme_formation }}</td>
            <td class="td-muted">{{ formatDate(attr.date_obtention) }}</td>
            <td>
              <span class="date-exp"
                :class="{ urgent: isUrgent(attr.date_expiration) }">
                {{ formatDate(attr.date_expiration) }}
              </span>
            </td>
            <td>
              <span class="statut-badge" :class="attr.statut">
                {{ attr.statut }}
              </span>
            </td>
            <td>
              <div class="actions">
                <button class="action-btn edit"
                  @click="openModal(attr)" title="Modifier">
                  <span v-html="icons.edit"></span>
                </button>
                <button class="action-btn delete"
                  @click="confirmDelete(attr)" title="Supprimer">
                  <span v-html="icons.trash"></span>
                </button>
              </div>
            </td>
          </tr>
        </tbody>
      </table>
    </div>

    <!-- ── Add / Edit Modal ───────────────────────────── -->
    <Teleport to="body">
      <div
        v-if="showModal"
        @click.self="closeModal"
        style="
          position:fixed;inset:0;
          background:rgba(0,0,0,0.5);
          z-index:9999;
          display:flex;
          align-items:center;
          justify-content:center;
          padding:20px;
        "
      >
        <div style="
          background:white;
          border-radius:16px;
          padding:32px;
          width:100%;
          max-width:580px;
          box-shadow:0 20px 60px rgba(0,0,0,0.2);
          max-height:90vh;
          overflow-y:auto;
        ">
          <h3 style="font-size:1.1rem;font-weight:700;
            color:#1a2e44;margin:0 0 24px 0;">
            {{ editTarget ? 'Modifier l\'association' : 'Nouvelle association' }}
          </h3>

          <div style="display:flex;flex-direction:column;gap:16px;">

            <!-- Département -->
<div class="modal-field">
  <label>Département <span style="color:#ef4444">*</span></label>
  <select v-model="form.departement_id"
    @change="onDepartementChange"
    :disabled="!!editTarget">
    <option value="">Sélectionner un département</option>
    <option v-for="d in departements" :key="d.id" :value="d.id">
      {{ d.nom }}
    </option>
  </select>
</div>

<!-- Service -->
<div class="modal-field">
  <label>Service <span style="color:#ef4444">*</span></label>
  <select v-model="form.service_id"
    @change="onServiceChange"
    :disabled="!form.departement_id || !!editTarget">
    <option value="">Sélectionner un service</option>
    <option v-for="s in filteredServices" :key="s.id" :value="s.id">
      {{ s.nom }}
    </option>
  </select>
</div>

<!-- Employé -->
<div class="modal-field">
  <label>Employé <span style="color:#ef4444">*</span></label>
  <select v-model="form.employee_id"
    :class="{ 'input-error': errors.employee_id }"
    :disabled="!form.service_id || !!editTarget">
    <option value="">Sélectionner un employé</option>
    <option v-for="e in filteredEmployees" :key="e.id" :value="e.id">
      {{ e.nom }} {{ e.prenom }} — {{ e.matricule }}
    </option>
  </select>
  <span class="error-msg" v-if="errors.employee_id">
    {{ errors.employee_id }}
  </span>
</div>

            <!-- Habilitation -->
            <div class="modal-field">
              <label>Habilitation <span style="color:#ef4444">*</span></label>
              <select v-model="form.habilitation_id"
                :class="{ 'input-error': errors.habilitation_id }"
                :disabled="!!editTarget">
                <option value="">Sélectionner une habilitation</option>
                <optgroup v-for="volet in voletsWithHabilitations"
                  :key="volet.id" :label="volet.nom">
                  <option v-for="h in volet.habilitations"
                    :key="h.id" :value="h.id">
                    {{ h.nom }}
                  </option>
                </optgroup>
              </select>
              <span class="error-msg" v-if="errors.habilitation_id">
                {{ errors.habilitation_id }}
              </span>
            </div>

            <!-- Type -->
            <div class="modal-field">
              <label>Type de formation <span style="color:#ef4444">*</span></label>
              <div style="display:flex;gap:12px;">
                <label class="radio-option"
                  :class="{ selected: form.type === 'initiale' }">
                  <input type="radio" v-model="form.type" value="initiale" />
                  Initiale
                </label>
                <label class="radio-option"
                  :class="{ selected: form.type === 'recyclage' }">
                  <input type="radio" v-model="form.type" value="recyclage" />
                  Recyclage
                </label>
              </div>
              <span class="error-msg" v-if="errors.type">{{ errors.type }}</span>
            </div>

            <!-- Date obtention -->
            <div class="modal-field">
              <label>Date d'obtention <span style="color:#ef4444">*</span></label>
              <input v-model="form.date_obtention" type="date"
                :class="{ 'input-error': errors.date_obtention }" />
              <span class="error-msg" v-if="errors.date_obtention">
                {{ errors.date_obtention }}
              </span>
            </div>

            <!-- Organisme de formation -->
            <div class="modal-field">
              <label>
                Organisme de formation <span style="color:#ef4444">*</span>
              </label>
              <input v-model="form.organisme_formation" type="text"
                placeholder="Ex: Hassane JAMAL EDDINE"
                :class="{ 'input-error': errors.organisme_formation }" />
              <span class="error-msg" v-if="errors.organisme_formation">
                {{ errors.organisme_formation }}
              </span>
            </div>

            <!-- Date aptitude médicale -->
            <div class="modal-field">
              <label>
                Date aptitude médicale <span style="color:#ef4444">*</span>
              </label>
              <input v-model="form.date_aptitude_medicale" type="date"
                :class="{ 'input-error': errors.date_aptitude_medicale }" />
              <span class="error-msg" v-if="errors.date_aptitude_medicale">
                {{ errors.date_aptitude_medicale }}
              </span>
            </div>

            <!-- Auto-calc preview -->
            <div v-if="expirationPreview" style="
              background:#f0fdf4;border:1px solid #bbf7d0;
              border-radius:8px;padding:12px 14px;
              font-size:0.875rem;color:#15803d;
              display:flex;align-items:center;gap:8px;
            ">
              <span v-html="icons.calendar"></span>
              Date d'expiration calculée :
              <strong>{{ expirationPreview }}</strong>
            </div>

          </div>

          <!-- Global error -->
          <div v-if="errors.global" style="
            margin-top:16px;
            background:#fef2f2;border:1px solid #fecaca;
            color:#dc2626;padding:10px 14px;
            border-radius:8px;font-size:0.875rem;
          ">{{ errors.global }}</div>

          <!-- Actions -->
          <div style="
            display:flex;gap:10px;justify-content:flex-end;
            margin-top:24px;padding-top:20px;
            border-top:1px solid #f0f4f8;
          ">
            <button @click="closeModal" style="
              padding:9px 20px;background:#f4f6f9;color:#374151;
              border:none;border-radius:8px;font-size:0.875rem;
              font-weight:500;cursor:pointer;
            ">Annuler</button>
            <button @click="submit" :disabled="submitting" style="
              padding:9px 20px;background:#1a4a6b;color:white;
              border:none;border-radius:8px;font-size:0.875rem;
              font-weight:600;cursor:pointer;
              display:flex;align-items:center;gap:6px;
            ">
              <span v-if="submitting" style="
                width:14px;height:14px;
                border:2px solid rgba(255,255,255,0.3);
                border-top-color:white;border-radius:50%;
                animation:spin 0.7s linear infinite;
                display:inline-block;
              "></span>
              {{ editTarget ? 'Enregistrer' : 'Associer' }}
            </button>
          </div>
        </div>
      </div>
    </Teleport>

    <!-- ── Delete confirm ─────────────────────────────── -->
    <ConfirmModal
      :show="!!deleteTarget"
      title="Supprimer cette association ?"
      confirmLabel="Supprimer"
      :loading="deleting"
      :icon="icons.trash"
      @confirm="deleteAttribution"
      @cancel="deleteTarget = null"
    >
      Supprimer l'association de
      <strong>{{ deleteTarget?.employee?.nom }}
        {{ deleteTarget?.employee?.prenom }}</strong>
      avec <strong>{{ deleteTarget?.habilitation?.nom }}</strong> ?<br>
      Les alertes et documents liés seront supprimés.
    </ConfirmModal>

  </div>
</template>

<script setup>
import { ref, reactive, computed, watch, onMounted } from 'vue';
import { useRouter } from 'vue-router';
import api from '@/services/api';
import ConfirmModal from '@/components/shared/ConfirmModal.vue';
import '@/../css/components/attributions/attribution-form.css';

const router = useRouter();
const departements = ref([]);
const services     = ref([]);
const attributions  = ref([]);
const employees     = ref([]);
const habilitations = ref([]);
const volets        = ref([]);
const loading       = ref(true);
const submitting    = ref(false);
const deleting      = ref(false);
const showModal     = ref(false);
const editTarget    = ref(null);
const deleteTarget  = ref(null);

const filters = reactive({
  search:         '',
  habilitation_id:'',
  statut:         '',
});

// ── Icons ─────────────────────────────────────────────
const icons = {
  plus:     `<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"/></svg>`,
  search:   `<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"/></svg>`,
  edit:     `<svg xmlns="http://www.w3.org/2000/svg" width="15" height="15" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"/></svg>`,
  trash:    `<svg xmlns="http://www.w3.org/2000/svg" width="15" height="15" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"/></svg>`,
  link:     `<svg xmlns="http://www.w3.org/2000/svg" width="48" height="48" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M13.828 10.172a4 4 0 00-5.656 0l-4 4a4 4 0 105.656 5.656l1.102-1.101m-.758-4.899a4 4 0 005.656 0l4-4a4 4 0 00-5.656-5.656l-1.1 1.1"/></svg>`,
  back:     `<svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7"/></svg>`,
  calendar: `<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"/></svg>`,
};

// ── Default form ──────────────────────────────────────
const defaultForm = () => ({
  departement_id:         '',   // ← add
  service_id:             '',   // ← add
  employee_id:            '',
  habilitation_id:        '',
  type:                   'initiale',
  date_obtention:         '',
  organisme_formation:    '',
  date_aptitude_medicale: '',
});
const filteredServices = computed(() =>
  form.departement_id
    ? services.value.filter(s => s.departement_id == form.departement_id)
    : []
);

const filteredEmployees = computed(() =>
  form.service_id
    ? employees.value.filter(e => e.service_id == form.service_id)
    : []
);
const onDepartementChange = () => {
  form.service_id  = '';
  form.employee_id = '';
};

const onServiceChange = () => {
  form.employee_id = '';
};
const form   = reactive(defaultForm());
const errors = reactive({
  employee_id: '', habilitation_id: '', type: '',
  date_obtention: '', organisme_formation: '',
  date_aptitude_medicale: '', global: '',
});

// ── Volets grouped for select optgroup ────────────────
const voletsWithHabilitations = computed(() => {
  return volets.value.map(v => ({
    ...v,
    habilitations: habilitations.value.filter(h => h.volet_id === v.id),
  })).filter(v => v.habilitations.length > 0);
});

// ── Expiration preview ────────────────────────────────
const expirationPreview = computed(() => {
  if (!form.habilitation_id || !form.date_obtention) return null;
  const hab = habilitations.value.find(
    h => h.id == form.habilitation_id
  );
  if (!hab) return null;
  const date = new Date(form.date_obtention);
  date.setFullYear(date.getFullYear() + hab.duree_de_validite);
  return date.toLocaleDateString('fr-FR');
});

// ── Fetch ─────────────────────────────────────────────
const fetchAttributions = async () => {
  loading.value = true;
  try {
    const params = {};
    if (filters.habilitation_id) params.habilitation_id = filters.habilitation_id;
    if (filters.statut)          params.statut          = filters.statut;
    if (filters.search)          params.search          = filters.search;
    const { data } = await api.get('/employee-habilitations', { params });
    attributions.value = data;
  } catch (e) {
    console.error(e);
  } finally {
    loading.value = false;
  }
};

const fetchReferentials = async () => {
  const [empRes, habRes, volRes, depRes, svcRes] = await Promise.all([
    api.get('/employees'),
    api.get('/habilitations'),
    api.get('/volets'),
    api.get('/departements'),
    api.get('/services'),
  ]);
  employees.value     = empRes.data;
  habilitations.value = habRes.data;
  volets.value        = volRes.data;
  departements.value  = depRes.data;
  services.value      = svcRes.data;
};
// ── Debounce search ───────────────────────────────────
let debounceTimer = null;
const debouncedFetch = () => {
  clearTimeout(debounceTimer);
  debounceTimer = setTimeout(fetchAttributions, 350);
};

// ── Modal ─────────────────────────────────────────────
const openModal = (attr = null) => {
  editTarget.value = attr;
  Object.keys(errors).forEach(k => errors[k] = '');

  if (attr) {
    // Pre-fill cascading from employee's service
    const emp = employees.value.find(e => e.id === attr.employee_id);
    const svc = services.value.find(s => s.id === emp?.service_id);

    Object.assign(form, {
      departement_id:         svc?.departement_id ?? '',
      service_id:             emp?.service_id ?? '',
      employee_id:            attr.employee_id,
      habilitation_id:        attr.habilitation_id,
      type:                   attr.type,
      date_obtention:         attr.date_obtention?.substring(0, 10),
      organisme_formation:    attr.organisme_formation,
      date_aptitude_medicale: attr.date_aptitude_medicale?.substring(0, 10),
    });
  } else {
    Object.assign(form, defaultForm());
  }
  showModal.value = true;
};
const closeModal = () => {
  showModal.value  = false;
  editTarget.value = null;
};

// ── Validate ──────────────────────────────────────────
const validate = () => {
  let valid = true;
  Object.keys(errors).forEach(k => errors[k] = '');

  if (!form.employee_id)
    { errors.employee_id = 'L\'employé est obligatoire.'; valid = false; }
  if (!form.habilitation_id)
    { errors.habilitation_id = 'L\'habilitation est obligatoire.'; valid = false; }
  if (!form.type)
    { errors.type = 'Le type est obligatoire.'; valid = false; }
  if (!form.date_obtention)
    { errors.date_obtention = 'La date est obligatoire.'; valid = false; }
  if (!form.organisme_formation)
    { errors.organisme_formation = 'L\'organisme est obligatoire.'; valid = false; }
  if (!form.date_aptitude_medicale)
    { errors.date_aptitude_medicale = 'La date est obligatoire.'; valid = false; }

  return valid;
};

// ── Submit ────────────────────────────────────────────
const submit = async () => {
  if (!validate()) return;
  submitting.value = true;
  try {
    if (editTarget.value) {
      const { data } = await api.put(
        `/employee-habilitations/${editTarget.value.id}`, form
      );
      const idx = attributions.value.findIndex(
        a => a.id === editTarget.value.id
      );
      if (idx !== -1) attributions.value[idx] = data;
    } else {
      const { data } = await api.post('/employee-habilitations', form);
      attributions.value.unshift(data);
    }
    closeModal();
  } catch (err) {
    const data = err.response?.data;
    if (data?.errors) {
      Object.keys(data.errors).forEach(k => {
        if (errors[k] !== undefined) errors[k] = data.errors[k][0];
      });
    } else {
      errors.global = data?.message ?? 'Une erreur est survenue.';
    }
  } finally {
    submitting.value = false;
  }
};

// ── Delete ────────────────────────────────────────────
const confirmDelete = (attr) => { deleteTarget.value = attr; };

const deleteAttribution = async () => {
  deleting.value = true;
  try {
    await api.delete(`/employee-habilitations/${deleteTarget.value.id}`);
    attributions.value = attributions.value.filter(
      a => a.id !== deleteTarget.value.id
    );
    deleteTarget.value = null;
  } catch (err) {
    alert(err.response?.data?.message ?? 'Impossible de supprimer.');
    deleteTarget.value = null;
  } finally {
    deleting.value = false;
  }
};

// ── Helpers ───────────────────────────────────────────
const initials = (emp) =>
  ((emp?.prenom?.charAt(0) ?? '') + (emp?.nom?.charAt(0) ?? '')).toUpperCase();

const formatDate = (d) =>
  d ? new Date(d).toLocaleDateString('fr-FR') : '—';

const isUrgent = (dateStr) => {
  if (!dateStr) return false;
  const diff = new Date(dateStr) - new Date();
  return diff < 30 * 24 * 60 * 60 * 1000;
};

onMounted(async () => {
  await fetchReferentials();
  await fetchAttributions();
});
</script>