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
            {{ isEdit ? `Matricule : ${form.matricule}` : 'Remplir les informations du salarié' }}
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

            <!-- Matricule -->
            <div class="field">
              <label>Matricule <span class="required">*</span></label>
              <input v-model="form.matricule" type="number"  placeholder="70347"
                :class="{ 'input-error': errors.matricule }" :disabled="isEdit" />
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
              <label>Email professionnel <span class="required">*</span></label>
              <input v-model="form.email_pro" type="email" placeholder="k.benali@holcim.ma"
                :class="{ 'input-error': errors.email_pro }" />
              <span class="error-msg" v-if="errors.email_pro">
                {{ errors.email_pro }}
              </span>
            </div>

            <!-- Position -->
            <div class="field field-full">
              <label>Poste / Position <span class="required">*</span></label>
              <input v-model="form.position" type="text" placeholder="Opérateur de production"
                :class="{ 'input-error': errors.position }" />
              <span class="error-msg" v-if="errors.position">
                {{ errors.position }}
              </span>
            </div>

          </div>
          <!-- Type -->
          <div class="field field-full">
            <label>Type d'employé <span class="required">*</span></label>
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

          <!-- Société (only for sous-traitant) -->
          <div class="field field-full" v-if="form.type === 'sous-traitant'">
            <label>Société <span class="required">*</span></label>
            <input v-model="form.societe" type="text" placeholder="Ex: Anwal Electric"
              :class="{ 'input-error': errors.societe }" />
            <span class="error-msg" v-if="errors.societe">{{ errors.societe }}</span>
          </div>
          <div class="form-section-title mt">Affectation</div>

          <div class="form-grid">

            <!-- Département -->
            <div class="field">
              <label>Département <span class="required">*</span></label>
              <select v-model="selectedDepartement" @change="onDepartementChange"
                :class="{ 'input-error': errors.service_id }">
                <option value="">Sélectionner un département</option>
                <option v-for="dep in departements" :key="dep.id" :value="dep.id">
                  {{ dep.nom }}
                </option>
              </select>
            </div>

            <!-- Service -->
            <div class="field">
              <label>Service <span class="required">*</span></label>
              <select v-model="form.service_id" :class="{ 'input-error': errors.service_id }"
                :disabled="!selectedDepartement">
                <option value="">Sélectionner un service</option>
                <option v-for="svc in filteredServices" :key="svc.id" :value="svc.id">
                  {{ svc.nom }}
                </option>
              </select>
              <span class="error-msg" v-if="errors.service_id">
                {{ errors.service_id }}
              </span>
            </div>

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
truck:    `<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 17a2 2 0 11-4 0 2 2 0 014 0zM19 17a2 2 0 11-4 0 2 2 0 014 0z"/><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16V6a1 1 0 00-1-1H4a1 1 0 00-1 1v10l2 1m8-11h3l3 4v4h-6V6z"/></svg>`,
  back: `<svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7"/></svg>`,
  save: `<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/></svg>`,
};

// ── Computed ──────────────────────────────────────────
const filteredServices = computed(() =>
  selectedDepartement.value
    ? services.value.filter(s => s.departement_id == selectedDepartement.value)
    : []
);

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

// ── Departement change ────────────────────────────────
const onDepartementChange = () => {
  form.service_id = '';
};

// ── Validate ──────────────────────────────────────────
const clearErrors = () => {
  Object.keys(errors).forEach(k => errors[k] = '');
};

const validate = () => {
  let valid = true;
  if (!form.matricule) { errors.matricule = 'Le matricule est obligatoire.'; valid = false; }
  if (!form.nom) { errors.nom = 'Le nom est obligatoire.'; valid = false; }
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