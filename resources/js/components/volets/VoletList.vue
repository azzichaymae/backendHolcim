<template>
  <div class="volet-list">

    <!-- ── Header ─────────────────────────────────────── -->
    <div class="page-header">
      <div>
        <h1 class="page-title">Catégories</h1>
        <p class="page-subtitle">{{ volets.length }} catégorie(s) configurée(s)</p>
      </div>
      <button class="btn-add" @click="openModal()">
        <span v-html="icons.plus"></span>
        Ajouter une catégorie
      </button>
    </div>

    <!-- ── Loading ────────────────────────────────────── -->
    <div class="loading-state" v-if="loading">
      <div class="loader"></div>
    </div>

    <!-- ── Empty ──────────────────────────────────────── -->
    <div class="empty-state" v-else-if="volets.length === 0">
      <span v-html="icons.folder"></span>
      <p>Aucune catégorie configurée.</p>
    </div>

    <!-- ── Grid ───────────────────────────────────────── -->
    <div class="volets-grid" v-else>
      <div
        class="volet-card"
        v-for="volet in volets"
        :key="volet.id"
      >
        <div class="volet-card-header">
          <div class="volet-icon" v-html="icons.layers"></div>
          <div class="volet-actions">
            <button class="action-btn edit"
              @click="openModal(volet)" title="Modifier">
              <span v-html="icons.edit"></span>
            </button>
            <button class="action-btn delete"
              @click="confirmDelete(volet)" title="Supprimer">
              <span v-html="icons.trash"></span>
            </button>
          </div>
        </div>

        <div class="volet-name">{{ volet.nom }}</div>

        <div class="volet-stats">
          <div class="volet-stat">
            <span class="stat-number">{{ volet.habilitations_count ?? 0 }}</span>
            <span class="stat-label">Habilitation(s)</span>
          </div>
          <div class="volet-stat" v-if="volet.habilitation_standard">
            <span class="standard-badge">
              <span v-html="icons.star"></span>
              Standard : {{ volet.habilitation_standard.nom }}
            </span>
          </div>
        </div>

      </div>
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
        "
      >
        <div style="
          background:white;
          border-radius:16px;
          padding:32px;
          width:100%;
          max-width:460px;
          box-shadow:0 20px 60px rgba(0,0,0,0.2);
        ">
          <h3 style="font-size:1.1rem;font-weight:700;color:#1a2e44;margin:0 0 24px 0;">
            {{ editTarget ? 'Modifier la catégorie' : 'Ajouter une catégorie' }}
          </h3>

          <div style="display:flex;flex-direction:column;gap:6px;margin-bottom:20px;">
            <label style="font-size:0.85rem;font-weight:600;color:#374151;">
              Nom de la catégorie <span style="color:#ef4444;">*</span>
            </label>
            <input
              v-model="form.nom"
              type="text"
              placeholder="Ex: Sécurité Électrique"
              :style="`
                padding:10px 12px;
                background:#f8fafc;
                border:1.5px solid ${errors.nom ? '#ef4444' : '#e8ecf0'};
                border-radius:8px;
                font-size:0.875rem;
                color:#1a2e44;
                outline:none;
                width:100%;
                box-sizing:border-box;
              `"
              @focus="errors.nom = ''"
            />
            <span style="font-size:0.78rem;color:#ef4444;" v-if="errors.nom">
              {{ errors.nom }}
            </span>
          </div>

          <div style="display:flex;gap:10px;justify-content:flex-end;">
            <button
              @click="closeModal"
              style="
                padding:9px 20px;background:#f4f6f9;color:#374151;
                border:none;border-radius:8px;font-size:0.875rem;
                font-weight:500;cursor:pointer;
              "
            >Annuler</button>
            <button
              @click="submit"
              :disabled="submitting"
              style="
                padding:9px 20px;background:#1a4a6b;color:white;
                border:none;border-radius:8px;font-size:0.875rem;
                font-weight:600;cursor:pointer;
                display:flex;align-items:center;gap:6px;
              "
            >
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
      title="Supprimer cette catégorie ?"
      confirmLabel="Supprimer"
      :loading="deleting"
      :icon="icons.trash"
      @confirm="deleteVolet"
      @cancel="deleteTarget = null"
    >
      Voulez-vous supprimer cette catégorie
      <strong>{{ deleteTarget?.nom }}</strong> ?<br>
      Cette action est irréversible.
    </ConfirmModal>

  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue';
import api from '@/services/api';
import ConfirmModal from '@/components/shared/ConfirmModal.vue';
import '@/../css/components/volets/volet-list.css';


const volets      = ref([]);
const loading     = ref(true);
const submitting  = ref(false);
const deleting    = ref(false);
const showModal   = ref(false);
const editTarget  = ref(null);
const deleteTarget = ref(null);

const form   = reactive({ nom: '' });
const errors = reactive({ nom: '' });

// ── Icons ─────────────────────────────────────────────
const icons = {
  plus:   `<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"/></svg>`,
  edit:   `<svg xmlns="http://www.w3.org/2000/svg" width="15" height="15" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"/></svg>`,
  trash:  `<svg xmlns="http://www.w3.org/2000/svg" width="15" height="15" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"/></svg>`,
  layers: `<svg xmlns="http://www.w3.org/2000/svg" width="22" height="22" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 11V9a2 2 0 012-2m0 0V5a2 2 0 012-2h6a2 2 0 012 2v2M7 7h10"/></svg>`,
  folder: `<svg xmlns="http://www.w3.org/2000/svg" width="48" height="48" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M3 7a2 2 0 012-2h4l2 2h8a2 2 0 012 2v8a2 2 0 01-2 2H5a2 2 0 01-2-2V7z"/></svg>`,
  star:   `<svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" fill="currentColor" viewBox="0 0 24 24"><path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z"/></svg>`,
};

// ── Fetch ─────────────────────────────────────────────
const fetchVolets = async () => {
  loading.value = true;
  try {
    const { data } = await api.get('/volets');
    volets.value = data;
  } catch (e) {
    console.error(e);
  } finally {
    loading.value = false;
  }
};

// ── Modal ─────────────────────────────────────────────
const openModal = (volet = null) => {
  editTarget.value = volet;
  form.nom         = volet?.nom ?? '';
  errors.nom       = '';
  showModal.value  = true;
};

const closeModal = () => {
  showModal.value = false;
  editTarget.value = null;
  form.nom = '';
  errors.nom = '';
};

// ── Submit ────────────────────────────────────────────
const submit = async () => {
  errors.nom = '';
  if (!form.nom.trim()) {
    errors.nom = 'Le nom du volet est obligatoire.';
    return;
  }

  submitting.value = true;
  try {
    if (editTarget.value) {
      const { data } = await api.put(`/volets/${editTarget.value.id}`, form);
      const idx = volets.value.findIndex(v => v.id === editTarget.value.id);
      if (idx !== -1) volets.value[idx] = { ...volets.value[idx], ...data };
    } else {
      const { data } = await api.post('/volets', form);
      volets.value.push(data);
    }
    closeModal();
  } catch (err) {
    const data = err.response?.data;
    errors.nom = data?.errors?.nom?.[0] ?? data?.message ?? 'Une erreur est survenue.';
  } finally {
    submitting.value = false;
  }
};

// ── Delete ────────────────────────────────────────────
const confirmDelete = (volet) => {
  deleteTarget.value = volet;
};

const deleteVolet = async () => {
  deleting.value = true;
  try {
    await api.delete(`/volets/${deleteTarget.value.id}`);
    volets.value   = volets.value.filter(v => v.id !== deleteTarget.value.id);
    deleteTarget.value = null;
  } catch (err) {
    alert(err.response?.data?.message ?? 'Impossible de supprimer ce volet.');
    deleteTarget.value = null;
  } finally {
    deleting.value = false;
  }
};

onMounted(fetchVolets);
</script>