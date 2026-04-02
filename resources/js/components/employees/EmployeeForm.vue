<template>
  <div class="employee-form-page">

    <!-- ── Header ─────────────────────────────────────── -->
    <div class="page-header">
      <div class="header-left">
        <button class="btn-back" @click="router.back()">
          <span v-html="icons.back"></span>
        </button>
        <div>
          <h1 class="page-title">
            {{ isEdit ? 'Modifier le salarié' : 'Ajouter un salarié' }}
          </h1>
          <p class="page-subtitle">
            {{ isEdit ? (form.type === 'sous-traitant' ? `Sous-traitant — ${form.societe}` : `Matricule :
            ${form.matricule}`) : 'Remplir les informations du salarié' }}
          </p>
        </div>
      </div>
    </div>

    <!-- ── Loading ────────────────────────────────────── -->
    <div class="loading-state" v-if="loading">
      <div class="loader"></div>
    </div>

    <template v-else>
      <div class="form-layout">

        <!-- ── Main form ─────────────────────────────── -->
        <div class="form-card">
          <div class="form-section-title">Informations personnelles</div>

          <div class="form-grid">
            <!-- Type -->
            <div class="field field-full">
              <label>Statut d'employé <span class="required">*</span></label>
              <div style="display:flex;gap:12px;margin-top:4px;">
                <label class="radio-option" :class="{ selected: form.type === 'propre' }">
                  <input type="radio" v-model="form.type" value="propre" style="display:none;" />
                  <span v-html="icons.building"></span>
                  Personnel Propre
                </label>
                <label class="radio-option" :class="{ selected: form.type === 'sous-traitant' }">
                  <input type="radio" v-model="form.type" value="sous-traitant" style="display:none;" />
                  <span v-html="icons.truck"></span>
                  Sous-Traitant
                </label>
              </div>
              <span class="error-msg" v-if="errors.type">{{ errors.type }}</span>
            </div>
            <!-- Matricule -->
            <div class="field">
              <label>Matricule </label>
              <input v-model="form.matricule" type="number" :class="{ 'input-error': errors.matricule }"
                :disabled="isEdit || form.type === 'sous-traitant'" />
              <span class="error-msg" v-if="errors.matricule">
                {{ errors.matricule }}
              </span>
            </div>

            <!-- Nom -->
            <div class="field">
              <label>Nom <span class="required">*</span></label>
              <input v-model="form.nom" type="text" placeholder="BENALI" :class="{ 'input-error': errors.nom }" />
              <span class="error-msg" v-if="errors.nom">{{ errors.nom }}</span>
            </div>

            <!-- Prénom -->
            <div class="field">
              <label>Prénom <span class="required">*</span></label>
              <input v-model="form.prenom" type="text" placeholder="Karim" :class="{ 'input-error': errors.prenom }" />
              <span class="error-msg" v-if="errors.prenom">
                {{ errors.prenom }}
              </span>
            </div>

            <!-- Email -->
            <div class="field">
              <label>Email professionnel <span v-if="form.type === 'propre'" class="required">*</span></label>
              <input v-model="form.email_pro" type="email" placeholder="k.benali@holcim.ma"
                :class="{ 'input-error': errors.email_pro }" />
              <span class="error-msg" v-if="errors.email_pro">
                {{ errors.email_pro }}
              </span>
            </div>
          </div>


          <!-- Société -->
          <div class="field field-full" v-if="form.type === 'sous-traitant'">
            <label>Société <span class="required">*</span></label>
            <input v-model="form.societe" type="text" placeholder="Ex: Anwal Electric"
              :class="{ 'input-error': errors.societe }" />
            <span class="error-msg" v-if="errors.societe">{{ errors.societe }}</span>
          </div>
          <div class="form-section-title mt">Affectation</div>

          <div class="form-grid">

            <!-- Service first -->
            <div class="field form-group">
              <label>Service <span class="required">*</span></label>
              <select v-model="form.service_id" @change="onServiceChange" class="form-input"
                :class="{ 'input-error': errors.service_id }">
                <option value="">Sélectionner un service</option>
                <option v-for="svc in services" :key="svc.id" :value="svc.id">
                  {{ svc.nom }}
                </option>
              </select>
              <span class="error-msg" v-if="errors.service_id">{{ errors.service_id }}</span>
            </div>

            <!-- Département auto-filled, read-only -->
            <div class="field form-group">
              <label>Département</label>
              <input type="text" class="form-input readonly" :value="autoFilledDepartement" readonly
                placeholder="Sélectionnez d'abord un service" />
            </div>

          </div>
          <div class="field field-full">
            <label>Poste / Position <span class="required">*</span></label>
            <div class="position-combo">
              <input v-model="form.position" type="text" placeholder="Sélectionner ou saisir un poste..."
                :class="{ 'input-error': errors.position }" @focus="showPositions = true"
                @blur="setTimeout(() => showPositions = false, 150)" autocomplete="off" />
              <ul class="position-dropdown" v-if="showPositions && filteredPositions.length">
                <li v-for="pos in filteredPositions" :key="pos" @mousedown="form.position = pos; showPositions = false"
                  :class="{ active: form.position === pos }">
                  {{ pos }}
                </li>
                <li class="position-new" v-if="form.position && !filteredPositions.includes(form.position)">
                  <span v-html="icons.plus"></span>
                  Ajouter "{{ form.position }}"
                </li>
              </ul>
            </div>
            <span class="error-msg" v-if="errors.position">{{ errors.position }}</span>
          </div>
          <!-- Global error -->
          <div class="global-error" v-if="errors.global">
            {{ errors.global }}
          </div>

          <!-- Actions -->
          <div class="form-actions">
            <button class="btn-cancel" @click="router.back()">
              Annuler
            </button>
            <button class="btn-submit" @click="submit" :disabled="submitting">
              <span v-if="submitting" class="spinner"></span>
              <span v-else v-html="icons.save"></span>
              {{ isEdit ? 'Enregistrer les modifications' : 'Ajouter le salarié' }}
            </button>
          </div>
        </div>

        <!-- ── Side panel — habilitations (edit only) ── -->
        <div class="side-panel" v-if="isEdit">
          <div class="form-card">
            <div class="form-section-title">
              Habilitations
              <span class="hab-count-badge">
                {{ employee?.habilitations?.length ?? 0 }}
              </span>
            </div>

            <div class="hab-empty" v-if="!employee?.habilitations?.length">
              Aucune habilitation attribuée.
            </div>

            <div class="hab-list" v-else>
              <div class="hab-item" v-for="h in employee.habilitations" :key="h.id">
                <div class="hab-info">
                  <div class="hab-name">{{ h.habilitation?.nom }}</div>
                  <div class="hab-volet">{{ h.habilitation?.volet?.nom }}</div>
                  <div class="hab-dates">
                    Obtenu le {{ formatDate(h.date_obtention) }} →
                    Expire le {{ formatDate(h.date_expiration) }}
                  </div>
                </div>
                <span class="statut-badge" :class="h.statut">
                  {{ h.statut }}
                </span>
              </div>
            </div>
          </div>
        </div>

      </div>
    </template>

  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue';
import { useRouter, useRoute } from 'vue-router';
import api from '@/services/api';
import '@/../css/components/employees/employee-form.css';


const router = useRouter();
const route = useRoute();

const isEdit = computed(() => !!route.params.id);
const loading = ref(true);
const submitting = ref(false);
const employee = ref(null);

const departements = ref([]);
const services = ref([]);
const selectedDepartement = ref('');

const showPositions = ref(false);
const existingPositions = ref([]);

const form = reactive({
  matricule: '',
  nom: '',
  prenom: '',
  email_pro: '',
  position: '',
  type: 'propre',   // ← add
  societe: '',
  service_id: '',
});

const errors = reactive({
  matricule: '',
  nom: '',
  prenom: '',
  email_pro: '',
  position: '',
  type: '',   // ← add
  societe: '',
  service_id: '',
  global: '',
});

// ── Icons ─────────────────────────────────────────────
const icons = {
  building: `<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-2 8v-3a1 1 0 011-1h2a1 1 0 011 1v3m-4 0h4"/></svg>`,
  truck: `<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 17a2 2 0 11-4 0 2 2 0 014 0zM19 17a2 2 0 11-4 0 2 2 0 014 0z"/><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16V6a1 1 0 00-1-1H4a1 1 0 00-1 1v10l2 1m8-11h3l3 4v4h-6V6z"/></svg>`,
  back: `<svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7"/></svg>`,
  save: `<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/></svg>`,
};

// ── Computed ──────────────────────────────────────────
const fetchPositions = async () => {
  if (!form.service_id) { existingPositions.value = []; return; }
  try {
    const { data } = await api.get('/employees', {
      params: { service_id: form.service_id }
    });
    // Extract unique non-null positions
    const positions = [...new Set(
      data.map(e => e.position).filter(Boolean)
    )].sort();
    existingPositions.value = positions;
  } catch (e) {
    console.error(e);
  }
};

const filteredPositions = computed(() => {
  if (!form.position) return existingPositions.value;
  const q = form.position.toLowerCase();
  return existingPositions.value.filter(p => p.toLowerCase().includes(q));
});
const onServiceChange = () => {
   form.position = ''; 
   const svc = services.value.find(s => s.id === form.service_id);
  selectedDepartement.value = svc ? svc.departement_id : '';
  fetchPositions();
  autoFilledDepartement();
 
};
const autoFilledDepartement = computed(() => {
  if (!form.service_id) return '';
  const svc = services.value.find(s => s.id == form.service_id);
  return svc?.departement?.nom ?? '';
});

// ── Fetch referentials ────────────────────────────────
const fetchReferentials = async () => {
  const [depRes, svcRes] = await Promise.all([
    api.get('/departements'),
    api.get('/services'),
  ]);
  departements.value = depRes.data;
  services.value = svcRes.data;
};

// ── Fetch employee (edit mode) ────────────────────────
const fetchEmployee = async () => {
  const { data } = await api.get(`/employees/${route.params.id}`);
  employee.value = data;

  // Fill form
  form.matricule = data.matricule;
  form.nom = data.nom;
  form.prenom = data.prenom;
  form.email_pro = data.email_pro;
  form.position = data.position;
  form.service_id = data.service_id;
  form.type = data.type ?? 'propre';
  form.societe = data.societe ?? '';
  // Pre-select departement for cascading
  selectedDepartement.value = data.service?.departement_id ?? '';
};


// ── Validate ──────────────────────────────────────────
const clearErrors = () => {
  Object.keys(errors).forEach(k => errors[k] = '');
};

const validate = () => {
  let valid = true;
  if (form.type !== 'sous-traitant' && !form.matricule) {
    errors.matricule = 'Le matricule est obligatoire.';
    valid = false;
  } if (!form.nom) { errors.nom = 'Le nom est obligatoire.'; valid = false; }
  if (!form.prenom) { errors.prenom = 'Le prénom est obligatoire.'; valid = false; }
  if (!form.email_pro) { errors.email_pro = 'L\'email est obligatoire.'; valid = false; }
  if (!form.position) { errors.position = 'Le poste est obligatoire.'; valid = false; }
  if (!form.service_id) { errors.service_id = 'Le service est obligatoire.'; valid = false; }
  if (!form.type) { errors.type = 'Le type est obligatoire.'; valid = false; }
  if (form.type === 'sous-traitant' && !form.societe) { errors.societe = 'La société est obligatoire pour un sous-traitant.'; valid = false; }
  return valid;
};

// ── Submit ────────────────────────────────────────────
const submit = async () => {
  clearErrors();

  if (!validate()) return;

  submitting.value = true;
  try {
    if (isEdit.value) {
      await api.put(`/employees/${route.params.id}`, form);
    } else {
      await api.post('/employees', form);
    }
    router.push({ name: 'employees' });
  } catch (err) {
    const data = err.response?.data;
    if (data?.errors) {
      Object.keys(data.errors).forEach(key => {
        if (errors[key] !== undefined) {
          errors[key] = data.errors[key][0];
        }
      });
    } else {
      errors.global = data?.message ?? 'Une erreur est survenue.';
    }
  } finally {
    submitting.value = false;
  }
};

// ── Helpers ───────────────────────────────────────────
const formatDate = (d) => d ? new Date(d).toLocaleDateString('fr-FR') : '—';

// ── Init ──────────────────────────────────────────────
onMounted(async () => {
  await fetchReferentials();
  if (isEdit.value) await fetchEmployee();
  loading.value = false;
});
</script>