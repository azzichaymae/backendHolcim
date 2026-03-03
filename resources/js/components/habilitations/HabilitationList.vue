<template>
  <div class="habilitation-list">

    <!-- ── Header ─────────────────────────────────────── -->
    <div class="page-header">
      <div>
        <h1 class="page-title">Habilitations</h1>
        <p class="page-subtitle">{{ total }} habilitation(s) configurée(s)</p>
      </div>
      <button class="btn-add" @click="openModal()">
        <span v-html="icons.plus"></span>
        Ajouter une habilitation
      </button>
    </div>

    <!-- ── Filters ────────────────────────────────────── -->
    <div class="filters-bar">
      <div class="search-wrapper">
        <span class="search-icon" v-html="icons.search"></span>
        <input
          v-model="search"
          type="text"
          placeholder="Rechercher une habilitation..."
          class="search-input"
        />
      </div>
      <select v-model="filterVolet" class="filter-select">
        <option value="">Tous les volets</option>
        <option v-for="v in volets" :key="v.id" :value="v.id">
          {{ v.nom }}
        </option>
      </select>
    </div>

    <!-- ── Loading ────────────────────────────────────── -->
    <div class="loading-state" v-if="loading">
      <div class="loader"></div>
    </div>

    <!-- ── Empty ──────────────────────────────────────── -->
    <div class="empty-state" v-else-if="filtered.length === 0">
      <span v-html="icons.shield"></span>
      <p>Aucune habilitation trouvée.</p>
    </div>

    <!-- ── Table ──────────────────────────────────────── -->
    <div class="table-card" v-else>
      <table class="data-table">
        <thead>
          <tr>
            <th>Habilitation</th>
            <th>Volet</th>
            <th>Formation initiale</th>
            <th>Recyclage</th>
            <th>Validité</th>
            <th>Standard</th>
            <th>Actions</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="hab in filtered" :key="hab.id" class="table-row">
            <td>
              <div class="hab-name">{{ hab.nom }}</div>
            </td>
            <td>
              <span class="volet-tag">{{ hab.volet?.nom }}</span>
            </td>
            <td class="td-muted">
              {{ hab.duree_formation_initiale }}
              {{ hab.duree_formation_initiale_unite }}
            </td>
            <td class="td-muted">
              {{ hab.duree_formation_recyclage }}
              {{ hab.duree_formation_recyclage_unite }}
            </td>
            <td>
              <span class="validite-badge">
                {{ hab.duree_de_validite }} ans
              </span>
            </td>
            <td>
              <span class="standard-dot" v-if="hab.is_standard"
                    v-html="icons.star" title="Habilitation standard">
              </span>
              <span class="no-standard" v-else>—</span>
            </td>
            <td>
              <div class="actions">
                <button class="action-btn edit"
                  @click="openModal(hab)" title="Modifier">
                  <span v-html="icons.edit"></span>
                </button>
                <button class="action-btn delete"
                  @click="confirmDelete(hab)" title="Supprimer">
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
          padding: 20px;
        "
      >
        <div style="
          background:white;
          border-radius:16px;
          padding:32px;
          width:100%;
          max-width:600px;
          box-shadow:0 20px 60px rgba(0,0,0,0.2);
          max-height:90vh;
          overflow-y:auto;
        ">
          <h3 style="font-size:1.1rem;font-weight:700;color:#1a2e44;margin:0 0 24px 0;">
            {{ editTarget ? 'Modifier l\'habilitation' : 'Ajouter une habilitation' }}
          </h3>

          <!-- Form grid -->
          <div style="display:grid;grid-template-columns:1fr 1fr;gap:16px;">

            <!-- Nom -->
            <div style="grid-column:span 2;" class="modal-field">
              <label>Nom <span style="color:#ef4444">*</span></label>
              <input v-model="form.nom" type="text"
                placeholder="Ex: Porteur de Cadenas"
                :class="{ 'input-error': errors.nom }" />
              <span class="error-msg" v-if="errors.nom">{{ errors.nom }}</span>
            </div>

            <!-- Volet -->
            <div style="grid-column:span 2;" class="modal-field">
              <label>Volet <span style="color:#ef4444">*</span></label>
              <select v-model="form.volet_id"
                :class="{ 'input-error': errors.volet_id }">
                <option value="">Sélectionner un volet</option>
                <option v-for="v in volets" :key="v.id" :value="v.id">
                  {{ v.nom }}
                </option>
              </select>
              <span class="error-msg" v-if="errors.volet_id">
                {{ errors.volet_id }}
              </span>
            </div>

            <!-- Formation initiale durée -->
            <div class="modal-field">
              <label>Durée formation initiale <span style="color:#ef4444">*</span></label>
              <input v-model="form.duree_formation_initiale" type="number" min="1"
                placeholder="2"
                :class="{ 'input-error': errors.duree_formation_initiale }" />
              <span class="error-msg" v-if="errors.duree_formation_initiale">
                {{ errors.duree_formation_initiale }}
              </span>
            </div>

            <!-- Formation initiale unité -->
            <div class="modal-field">
              <label>Unité <span style="color:#ef4444">*</span></label>
              <select v-model="form.duree_formation_initiale_unite">
                <option value="heures">Heures</option>
                <option value="jours">Jours</option>
              </select>
            </div>

            <!-- Recyclage durée -->
            <div class="modal-field">
              <label>Durée recyclage <span style="color:#ef4444">*</span></label>
              <input v-model="form.duree_formation_recyclage" type="number" min="1"
                placeholder="2"
                :class="{ 'input-error': errors.duree_formation_recyclage }" />
              <span class="error-msg" v-if="errors.duree_formation_recyclage">
                {{ errors.duree_formation_recyclage }}
              </span>
            </div>

            <!-- Recyclage unité -->
            <div class="modal-field">
              <label>Unité <span style="color:#ef4444">*</span></label>
              <select v-model="form.duree_formation_recyclage_unite">
                <option value="heures">Heures</option>
                <option value="jours">Jours</option>
              </select>
            </div>

            <!-- Durée validité -->
            <div class="modal-field">
              <label>Durée de validité (années) <span style="color:#ef4444">*</span></label>
              <input v-model="form.duree_de_validite" type="number" min="1"
                placeholder="3"
                :class="{ 'input-error': errors.duree_de_validite }" />
              <span class="error-msg" v-if="errors.duree_de_validite">
                {{ errors.duree_de_validite }}
              </span>
            </div>

            <!-- Is standard -->
            <div class="modal-field" style="display:flex;align-items:center;gap:10px;padding-top:24px;">
              <input type="checkbox" v-model="form.is_standard"
                id="is_standard"
                style="width:16px;height:16px;accent-color:#1a6b8a;cursor:pointer;" />
              <label for="is_standard"
                style="font-size:0.875rem;font-weight:600;color:#374151;cursor:pointer;">
                Habilitation standard du volet
              </label>
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
          <div style="display:flex;gap:10px;justify-content:flex-end;margin-top:24px;
            padding-top:20px;border-top:1px solid #f0f4f8;">
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
                animation:spin 0.7s linear infinite;display:inline-block;
              "></span>
              {{ editTarget ? 'Enregistrer' : 'Ajouter' }}
            </button>
          </div>
        </div>
      </div>
    </Teleport>

    <!-- ── Delete confirm ─────────────────────────────── -->
    <ConfirmModal
      :show="!!deleteTarget"
      title="Supprimer cette habilitation ?"
      confirmLabel="Supprimer"
      :loading="deleting"
      :icon="icons.trash"
      @confirm="deleteHabilitation"
      @cancel="deleteTarget = null"
    >
      Voulez-vous supprimer
      <strong>{{ deleteTarget?.nom }}</strong> ?<br>
      Cette action est irréversible.
    </ConfirmModal>

  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue';
import api from '@/services/api';
import ConfirmModal from '@/components/shared/ConfirmModal.vue';
import '@/../css/components/habilitations/habilitation-list.css';

const habilitations = ref([]);
const volets        = ref([]);
const loading       = ref(true);
const submitting    = ref(false);
const deleting      = ref(false);
const showModal     = ref(false);
const editTarget    = ref(null);
const deleteTarget  = ref(null);
const search        = ref('');
const filterVolet   = ref('');

const total = computed(() => habilitations.value.length);

const filtered = computed(() => {
  return habilitations.value.filter(h => {
    const matchSearch = !search.value ||
      h.nom.toLowerCase().includes(search.value.toLowerCase());
    const matchVolet = !filterVolet.value ||
      h.volet_id == filterVolet.value;
    return matchSearch && matchVolet;
  });
});

// ── Icons ─────────────────────────────────────────────
const icons = {
  plus:   `<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"/></svg>`,
  search: `<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"/></svg>`,
  edit:   `<svg xmlns="http://www.w3.org/2000/svg" width="15" height="15" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"/></svg>`,
  trash:  `<svg xmlns="http://www.w3.org/2000/svg" width="15" height="15" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"/></svg>`,
  shield: `<svg xmlns="http://www.w3.org/2000/svg" width="48" height="48" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z"/></svg>`,
  star:   `<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="#f59e0b" viewBox="0 0 24 24"><path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z"/></svg>`,
};

// ── Default form ──────────────────────────────────────
const defaultForm = () => ({
  nom:                            '',
  volet_id:                       '',
  duree_formation_initiale:       '',
  duree_formation_initiale_unite: 'heures',
  duree_formation_recyclage:      '',
  duree_formation_recyclage_unite:'heures',
  duree_de_validite:              '',
  is_standard:                    false,
});

const form   = reactive(defaultForm());
const errors = reactive({
  nom: '', volet_id: '',
  duree_formation_initiale: '',
  duree_formation_recyclage: '',
  duree_de_validite: '',
  global: '',
});

// ── Fetch ─────────────────────────────────────────────
const fetchAll = async () => {
  loading.value = true;
  try {
    const [habRes, volRes] = await Promise.all([
      api.get('/habilitations'),
      api.get('/volets'),
    ]);
    habilitations.value = habRes.data;
    volets.value        = volRes.data;
  } catch (e) {
    console.error(e);
  } finally {
    loading.value = false;
  }
};

// ── Modal ─────────────────────────────────────────────
const openModal = (hab = null) => {
  editTarget.value = hab;
  Object.keys(errors).forEach(k => errors[k] = '');

  if (hab) {
    Object.assign(form, {
      nom:                            hab.nom,
      volet_id:                       hab.volet_id,
      duree_formation_initiale:       hab.duree_formation_initiale,
      duree_formation_initiale_unite: hab.duree_formation_initiale_unite,
      duree_formation_recyclage:      hab.duree_formation_recyclage,
      duree_formation_recyclage_unite:hab.duree_formation_recyclage_unite,
      duree_de_validite:              hab.duree_de_validite,
      is_standard:                    !!hab.is_standard,
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

  if (!form.nom)
    { errors.nom = 'Le nom est obligatoire.'; valid = false; }
  if (!form.volet_id)
    { errors.volet_id = 'Le volet est obligatoire.'; valid = false; }
  if (!form.duree_formation_initiale)
    { errors.duree_formation_initiale = 'Obligatoire.'; valid = false; }
  if (!form.duree_formation_recyclage)
    { errors.duree_formation_recyclage = 'Obligatoire.'; valid = false; }
  if (!form.duree_de_validite)
    { errors.duree_de_validite = 'Obligatoire.'; valid = false; }

  return valid;
};

// ── Submit ────────────────────────────────────────────
const submit = async () => {
  if (!validate()) return;
  submitting.value = true;
  try {
    if (editTarget.value) {
      const { data } = await api.put(
        `/habilitations/${editTarget.value.id}`, form
      );
      const idx = habilitations.value.findIndex(
        h => h.id === editTarget.value.id
      );
      if (idx !== -1) habilitations.value[idx] = data;
    } else {
      const { data } = await api.post('/habilitations', form);
      habilitations.value.push(data);
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
const confirmDelete = (hab) => { deleteTarget.value = hab; };

const deleteHabilitation = async () => {
  deleting.value = true;
  try {
    await api.delete(`/habilitations/${deleteTarget.value.id}`);
    habilitations.value = habilitations.value.filter(
      h => h.id !== deleteTarget.value.id
    );
    deleteTarget.value = null;
  } catch (err) {
    alert(err.response?.data?.message ?? 'Impossible de supprimer.');
    deleteTarget.value = null;
  } finally {
    deleting.value = false;
  }
};

onMounted(fetchAll);
</script>