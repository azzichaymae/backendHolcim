<template>
  <div class="settings-page">

    <!-- ── Header ─────────────────────────────────────────────────────── -->
    <div class="settings-header">
      <div>
        <h1 class="settings-title">Paramètres</h1>
        <p class="settings-subtitle">Configuration globale de l'application</p>
      </div>
      <div class="header-status" v-if="saveSuccess">
        <span v-html="icons.checkCircle"></span>
        Modifications enregistrées
      </div>
    </div>

    <!-- ── Loading ────────────────────────────────────────────────────── -->
    <div class="settings-loading" v-if="loading">
      <div class="st-spinner"></div>
      <span>Chargement des paramètres...</span>
    </div>

    <template v-else>
      <div class="settings-layout">

        <!-- ── LEFT: nav tabs ─────────────────────────────────────────── -->
        <div class="settings-nav">
          <button
            v-for="tab in tabs"
            :key="tab.key"
            :class="['snav-item', { active: activeTab === tab.key }]"
            @click="activeTab = tab.key"
          >
            <span class="snav-icon" v-html="tab.icon"></span>
            <span class="snav-label">{{ tab.label }}</span>
          </button>
        </div>

        <!-- ── RIGHT: form panels ─────────────────────────────────────── -->
        <div class="settings-content">

          <!-- ══ Tab: Usine ══════════════════════════════════════════════ -->
          <div class="settings-panel" v-if="activeTab === 'usine'">
            <div class="settings-panel-header">
              <span v-html="icons.factory"></span>
              <div>
                <div class="panel-title">Informations de l'usine</div>
                <div class="panel-desc">Données générales utilisées dans les documents PDF</div>
              </div>
            </div>

            <div class="fields-grid">
              <div class="field-group full">
                <label>Nom de la société <span class="req">*</span></label>
                <input v-model="form.societe" type="text" placeholder="Ex: LafargeHolcim Maroc" />
              </div>
              <div class="field-group full">
                <label>Nom du site / usine <span class="req">*</span></label>
                <input v-model="form.site" type="text" />
              </div>
            </div>
          </div>

          <!-- ══ Tab: Direction ══════════════════════════════════════════ -->
          <div class="settings-panel" v-if="activeTab === 'direction'">
            <div class="settings-panel-header">
              <span v-html="icons.person"></span>
              <div>
                <div class="panel-title">Direction</div>
                <div class="panel-desc">Nom et titre du directeur — apparaît dans les documents et les signatures</div>
              </div>
            </div>

            <div class="fields-grid">
              <div class="field-group">
                <label>Nom du directeur <span class="req">*</span></label>
                <input v-model="form.directeur_usine" type="text" placeholder="Ex: Chakib EL OUDGHIRI" />
              </div>
              <div class="field-group">
                <label>Titre du directeur <span class="req">*</span></label>
                <input v-model="form.titre_directeur" type="text" placeholder="Ex: Directeur d'Usine" />
              </div>
            </div>

            <div class="preview-block">
              <div class="preview-label">Aperçu dans les documents</div>
              <div class="preview-text">
                Je soussigné M. <strong>{{ form.directeur_usine || '...' }}</strong>,
                en qualité de {{ form.titre_directeur || '...' }}
                de la {{ form.site || '...' }}, atteste par le présent document que...
              </div>
            </div>
          </div>

          <!-- ══ Tab: Signataires ════════════════════════════════════════ -->
          <div class="settings-panel" v-if="activeTab === 'signataires'">
            <div class="settings-panel-header">
              <span v-html="icons.sign"></span>
              <div>
                <div class="panel-title">Signataires</div>
                <div class="panel-desc">Noms qui apparaissent dans le bloc de signatures des documents</div>
              </div>
            </div>

            <div class="sig-preview">
              <div class="sig-preview-label">Bloc de signatures — Habilitation Individuelle (5 colonnes)</div>
              <div class="sig-boxes">
                <div class="sig-box">
                  <div class="sig-box-role">Intéressé</div>
                  <div class="sig-box-name muted">Employé concerné</div>
                </div>
                <div class="sig-box highlight">
                  <div class="sig-box-role">Resp. Maintenance Électrique</div>
                  <div class="sig-box-name">{{ form.resp_maintenance_elec || '—' }}</div>
                </div>
                <div class="sig-box highlight">
                  <div class="sig-box-role">Resp. Maintenance</div>
                  <div class="sig-box-name">{{ form.resp_maintenance || '—' }}</div>
                </div>
                <div class="sig-box highlight">
                  <div class="sig-box-role">Resp. Santé Sécurité</div>
                  <div class="sig-box-name">{{ form.resp_sante_securite || '—' }}</div>
                </div>
                <div class="sig-box highlight">
                  <div class="sig-box-role">{{ form.titre_directeur || 'Directeur' }}</div>
                  <div class="sig-box-name">{{ form.directeur_usine || '—' }}</div>
                </div>
              </div>
            </div>

            <div class="fields-grid">
              <div class="field-group">
                <label>Responsable Maintenance Électrique <span class="req">*</span></label>
                <input v-model="form.resp_maintenance_elec" type="text" placeholder="Nom complet" />
              </div>
              <div class="field-group">
                <label>Responsable Maintenance <span class="req">*</span></label>
                <input v-model="form.resp_maintenance" type="text" placeholder="Nom complet" />
              </div>
              <div class="field-group full">
                <label>Responsable Santé Sécurité <span class="req">*</span></label>
                <input v-model="form.resp_sante_securite" type="text" placeholder="Nom complet" />
                <div class="field-note">Apparaît aussi dans la Note d'Habilitation</div>
              </div>
            </div>
          </div>

          <!-- ══ Tab: Médecin ════════════════════════════════════════════ -->
          <div class="settings-panel" v-if="activeTab === 'medecin'">
            <div class="settings-panel-header">
              <span v-html="icons.medical"></span>
              <div>
                <div class="panel-title">Médecin du travail</div>
                <div class="panel-desc">Nom du médecin utilisé par défaut dans les documents d'aptitude médicale</div>
              </div>
            </div>

            <div class="fields-grid">
              <div class="field-group full">
                <label>Nom du médecin <span class="req">*</span></label>
                <input v-model="form.medecin" type="text" placeholder="Ex: Abdelhamid BENDAHA" />
              </div>
            </div>

            <div class="preview-block">
              <div class="preview-label">Aperçu dans les documents</div>
              <div class="preview-text">
                Aptitude médicale délivrée par le Docteur
                <strong>{{ form.medecin || '...' }}</strong>,
                Médecin de Travail, en date du <strong>[date aptitude employé]</strong>
              </div>
            </div>
          </div>

          <!-- ── Save button ─────────────────────────────────────────── -->
          <div class="settings-actions">
            <div class="save-error" v-if="saveError">
              <span v-html="icons.warning"></span>
              {{ saveError }}
            </div>
            <button class="btn-save" @click="saveSettings" :disabled="saving">
              <span v-if="saving" class="st-spinner-sm"></span>
              <span v-else v-html="icons.save"></span>
              {{ saving ? 'Enregistrement...' : 'Enregistrer les modifications' }}
            </button>
          </div>

        </div>
      </div>
    </template>

  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue';
import api from '@/services/api';
import '@/../css/components/settings/settings.css';

// ── State ──────────────────────────────────────────────────────────────────
const loading     = ref(true);
const saving      = ref(false);
const saveSuccess = ref(false);
const saveError   = ref('');
const activeTab   = ref('usine');

const form = reactive({
  societe:               '',
  site:                  '',
  directeur_usine:       '',
  titre_directeur:       '',
  resp_maintenance_elec: '',
  resp_maintenance:      '',
  resp_sante_securite:   '',
  medecin:               '',
});

// ── Tabs ───────────────────────────────────────────────────────────────────
const tabs = [
  { key: 'usine',       label: 'Usine',       icon: `<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4"/></svg>` },
  { key: 'direction',   label: 'Direction',   icon: `<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"/></svg>` },
  { key: 'signataires', label: 'Signataires', icon: `<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0z"/></svg>` },
  { key: 'medecin',     label: 'Médecin',     icon: `<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z"/></svg>` },
];

// ── Icons ──────────────────────────────────────────────────────────────────
const icons = {
  checkCircle: `<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>`,
  warning:     `<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"/></svg>`,
  save:        `<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7H5a2 2 0 00-2 2v9a2 2 0 002 2h14a2 2 0 002-2V9a2 2 0 00-2-2h-3m-1 4l-3 3m0 0l-3-3m3 3V4"/></svg>`,
  factory:     `<svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4"/></svg>`,
  person:      `<svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"/></svg>`,
  sign:        `<svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0z"/></svg>`,
  medical:     `<svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z"/></svg>`,
};

// ── Load settings ──────────────────────────────────────────────────────────
const loadSettings = async () => {
  loading.value = true;
  try {
    const { data } = await api.get('/parametres');
    Object.assign(form, {
      societe:               data.societe               ,
      site:                  data.site                  ,
      directeur_usine:       data.directeur_usine       ?? '',
      titre_directeur:       data.titre_directeur       ?? '',
      resp_maintenance_elec: data.resp_maintenance_elec ?? '',
      resp_maintenance:      data.resp_maintenance      ?? '',
      resp_sante_securite:   data.resp_sante_securite   ?? '',
      medecin:               data.medecin               ?? '',
    });
  } catch {
    saveError.value = 'Impossible de charger les paramètres.';
  } finally {
    loading.value = false;
  }
};

// ── Save settings ──────────────────────────────────────────────────────────
const saveSettings = async () => {
  saving.value      = true;
  saveError.value   = '';
  saveSuccess.value = false;

  try {
    await api.put('/settings', { ...form });
    saveSuccess.value = true;
    setTimeout(() => { saveSuccess.value = false; }, 3500);
  } catch (e) {
    const errors = e.response?.data?.errors;
    if (errors) {
      saveError.value = Object.values(errors).flat().join(' · ');
    } else {
      saveError.value = 'Erreur lors de l\'enregistrement.';
    }
  } finally {
    saving.value = false;
  }
};

onMounted(loadSettings);
</script>