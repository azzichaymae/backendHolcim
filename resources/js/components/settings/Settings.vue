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
            <div class="st-panel-header">
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
                <input v-model="form.site" type="text" placeholder="Ex: cimenterie d'Oujda" />
              </div>
            </div>
          </div>

          <!-- ══ Tab: Direction ══════════════════════════════════════════ -->
          <div class="settings-panel" v-if="activeTab === 'direction'">
            <div class="st-panel-header">
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
              <div class="field-group  ">
                <label>Email du directeur <span class="req">*</span> </label>
                <input v-model="form.email_directeur" type="email" placeholder="Email du directeur" />
              </div>
            </div>

            <div class="preview-block">
              <div class="preview-label">Aperçu dans les documents</div>
              <div class="preview-text">
                Je soussigné M. <strong>{{ form.directeur_usine || '...' }}</strong>,
                en qualité de <strong>{{ form.titre_directeur || '...' }}</strong>
                de la {{ form.site || '...' }}, atteste par le présent document que...
              </div>
            </div>
          </div>

          <!-- ══ Tab: Signataires ════════════════════════════════════════ -->
          <div class="settings-panel" v-if="activeTab === 'signataires'">
            <div class="st-panel-header">
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
                  <div class="sig-box-auto">automatique</div>
                </div>
                <div class="sig-box">
                  <div class="sig-box-role">Resp. Service</div>
                  <div class="sig-box-name muted">Selon le service</div>
                  <div class="sig-box-auto">automatique</div>
                </div>
                <div class="sig-box">
                  <div class="sig-box-role">Resp. Département</div>
                  <div class="sig-box-name muted">Selon le département</div>
                  <div class="sig-box-auto">automatique</div>
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
              <div class="field-group  ">
                <label>Responsable Santé Sécurité <span class="req">*</span></label>
                <input v-model="form.resp_sante_securite" type="text" placeholder="Nom complet" />
               </div>
              <div class="field-group  ">
                <label>Email du responsable Santé Sécurité</label>
                <input v-model="form.email_resp_sante_securite" type="email" placeholder="Email du responsable" />
              </div>
            </div>
          </div>

          <!-- ══ Tab: Médecin ════════════════════════════════════════════ -->
          <div class="settings-panel" v-if="activeTab === 'medecin'">
            <div class="st-panel-header">
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

          <!-- ══ Tab: Départements ══════════════════════════════════════ -->
          <div class="settings-panel" v-if="activeTab === 'departements'">
            <div class="st-panel-header">
              <span v-html="icons.folder"></span>
              <div>
                <div class="panel-title">Départements</div>
                <div class="panel-desc">Gérer les départements et leurs responsables</div>
              </div>
            </div>

            <!-- Add form -->
            <div class="org-add-form">
              <input v-model="newDep.nom" type="text" placeholder="Nom du département" class="org-input" />
              <input v-model="newDep.responsable" type="text" placeholder="Responsable (nom complet)" class="org-input" />
              <input v-model="newDep.responsable_email" type="email" placeholder="Email du responsable" class="org-input" />
              <button class="btn-org-add" @click="addDepartement" :disabled="!newDep.nom.trim()">
                <span v-html="icons.plus"></span> Ajouter
              </button>
            </div>

            <!-- List -->
            <div class="org-loading" v-if="depLoading"><div class="st-spinner"></div></div>
            <div class="org-empty" v-else-if="departements.length === 0">Aucun département configuré.</div>
            <div class="org-list" v-else>
              <div class="org-item" v-for="dep in departements" :key="dep.id">
                <template v-if="editingDep?.id === dep.id">
                  <input v-model="editingDep.nom" class="org-input-inline" placeholder="Nom" />
                  <input v-model="editingDep.responsable" class="org-input-inline" placeholder="Responsable" />
                  <input v-model="editingDep.responsable_email" class="org-input-inline" placeholder="Email du responsable" />
                  <button class="btn-org-action save" @click="saveDepartement" title="Enregistrer">
                    <span v-html="icons.check"></span>
                  </button>
                  <button class="btn-org-action cancel" @click="editingDep = null" title="Annuler">
                    <span v-html="icons.x"></span>
                  </button>
                </template>
                <template v-else>
                  <div class="org-item-info">
                    <span class="org-item-nom">{{ dep.nom }}</span>
                    <span class="org-item-resp">{{ dep.responsable || '— aucun responsable' }}</span>
                  </div>
                  <div class="org-item-meta">
                    <span class="org-count-badge">{{ dep.employees_count ?? 0 }} employé(s)</span>
                  </div>
                  <div class="org-item-actions">
                    <button class="btn-org-action edit" @click="editingDep = { ...dep }" title="Modifier">
                      <span v-html="icons.edit"></span>
                    </button>
                    <button class="btn-org-action delete" @click="deleteDepartement(dep)" title="Supprimer">
                      <span v-html="icons.trash"></span>
                    </button>
                  </div>
                </template>
              </div>
            </div>
          </div>

          <!-- ══ Tab: Services ═══════════════════════════════════════════ -->
          <div class="settings-panel" v-if="activeTab === 'services'">
            <div class="st-panel-header">
              <span v-html="icons.sign"></span>
              <div>
                <div class="panel-title">Services</div>
                <div class="panel-desc">Gérer les services, leur département et leur responsable</div>
              </div>
            </div>

            <!-- Add form -->
            <div class="org-add-form">
              <select v-model="newSvc.departement_id" class="org-input">
                <option value="">— Département —</option>
                <option v-for="dep in departements" :key="dep.id" :value="dep.id">{{ dep.nom }}</option>
              </select>
              <input v-model="newSvc.nom" type="text" placeholder="Nom du service" class="org-input" />
              <input v-model="newSvc.responsable" type="text" placeholder="Responsable (nom complet)" class="org-input" />
              <input v-model="newSvc.responsable_email" type="email" placeholder="Email du responsable" class="org-input" />
              <button class="btn-org-add" @click="addService" :disabled="!newSvc.nom.trim() || !newSvc.departement_id">
                <span v-html="icons.plus"></span> Ajouter
              </button>
            </div>

            <!-- List -->
            <div class="org-loading" v-if="svcLoading"><div class="st-spinner"></div></div>
            <div class="org-empty" v-else-if="services.length === 0">Aucun service configuré.</div>
            <div class="org-list" v-else>
              <div class="org-item" v-for="svc in services" :key="svc.id">
                <template v-if="editingSvc?.id === svc.id">
                  <select v-model="editingSvc.departement_id" class="org-input-inline">
                    <option v-for="dep in departements" :key="dep.id" :value="dep.id">{{ dep.nom }}</option>
                  </select>
                  <input v-model="editingSvc.nom" class="org-input-inline" placeholder="Nom" />
                  <input v-model="editingSvc.responsable" class="org-input-inline" placeholder="Responsable" />
                  <input v-model="editingSvc.responsable_email" class="org-input-inline" placeholder="Email du responsable" />
                  <button class="btn-org-action save" @click="saveService" title="Enregistrer">
                    <span v-html="icons.check"></span>
                  </button>
                  <button class="btn-org-action cancel" @click="editingSvc = null" title="Annuler">
                    <span v-html="icons.x"></span>
                  </button>
                </template>
                <template v-else>
                  <div class="org-item-info">
                    <span class="org-item-nom">{{ svc.nom }}</span>
                    <span class="org-item-resp">{{ svc.responsable || '— aucun responsable' }}</span>
                  </div>
                  <div class="org-item-meta">
                    <span class="org-dep-badge">{{ svc.departement?.nom }}</span>
                    <span class="org-count-badge">{{ svc.employees_count ?? 0 }} employé(s)</span>
                  </div>
                  <div class="org-item-actions">
                    <button class="btn-org-action edit" @click="editingSvc = { ...svc, departement_id: svc.departement_id }" title="Modifier">
                      <span v-html="icons.edit"></span>
                    </button>
                    <button class="btn-org-action delete" @click="deleteService(svc)" title="Supprimer">
                      <span v-html="icons.trash"></span>
                    </button>
                  </div>
                </template>
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
  resp_sante_securite:   '',
  medecin:               '',
});

// ── Tabs ───────────────────────────────────────────────────────────────────
const tabs = [
  { key: 'usine',       label: 'Usine',       icon: `<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4"/></svg>` },
  { key: 'direction',   label: 'Direction',   icon: `<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"/></svg>` },
  { key: 'signataires', label: 'Signataires', icon: `<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0z"/></svg>` },
  { key: 'departements', label: 'Départements', icon: `<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 7v10a2 2 0 002 2h14a2 2 0 002-2V9a2 2 0 00-2-2h-6l-2-2H5a2 2 0 00-2 2z"/></svg>` },
  { key: 'services',     label: 'Services',     icon: `<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0z"/></svg>` },
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
  plus:        `<svg xmlns="http://www.w3.org/2000/svg" width="15" height="15" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"/></svg>`,
  trash:       `<svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"/></svg>`,
  edit:        `<svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"/></svg>`,
  check:       `<svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/></svg>`,
  x:           `<svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/></svg>`,
  folder:      `<svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 7v10a2 2 0 002 2h14a2 2 0 002-2V9a2 2 0 00-2-2h-6l-2-2H5a2 2 0 00-2 2z"/></svg>`,
  medical:     `<svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z"/></svg>`,
};

// ── Load settings ──────────────────────────────────────────────────────────
const loadSettings = async () => {
  loading.value = true;
  try {
    const { data } = await api.get('/parametres');
    Object.assign(form, {
      societe:               data.societe               ?? '',
      site:                  data.site                  ?? '',
      directeur_usine:       data.directeur_usine       ?? '',
      titre_directeur:       data.titre_directeur       ?? '',
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
    await api.put('/parametres', { ...form });
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

// ── Départements ──────────────────────────────────────────────────────────
const departements = ref([]);
const depLoading   = ref(false);
const editingDep   = ref(null);
const newDep       = reactive({ nom: '', responsable: '' });

const loadDepartements = async () => {
  depLoading.value = true;
  try {
    const { data } = await api.get('/departements');
    departements.value = data;
  } finally { depLoading.value = false; }
};

const addDepartement = async () => {
  if (!newDep.nom.trim()) return;
  try {
    const { data } = await api.post('/departements', { nom: newDep.nom.trim(), responsable: newDep.responsable.trim(), responsable_email: newDep.responsable_email?.trim() });
    departements.value.push(data);
    newDep.nom = ''; newDep.responsable = ''; newDep.responsable_email = '';
  } catch (e) { alert(e.response?.data?.message ?? 'Erreur'); }
};

const saveDepartement = async () => {
  try {
    const { data } = await api.put(`/departements/${editingDep.value.id}`, {
      nom: editingDep.value.nom,
      responsable: editingDep.value.responsable,
      responsable_email: editingDep.value.responsable_email,
    });
    const idx = departements.value.findIndex(d => d.id === data.id);
    if (idx !== -1) departements.value[idx] = data;
    editingDep.value = null;
  } catch (e) { alert(e.response?.data?.message ?? 'Erreur'); }
};

const deleteDepartement = async (dep) => {
  if (!confirm(`Supprimer le département "${dep.nom}" ?`)) return;
  try {
    await api.delete(`/departements/${dep.id}`);
    departements.value = departements.value.filter(d => d.id !== dep.id);
  } catch (e) { alert(e.response?.data?.message ?? 'Erreur'); }
};

// ── Services ───────────────────────────────────────────────────────────────
const services    = ref([]);
const svcLoading  = ref(false);
const editingSvc  = ref(null);
const newSvc      = reactive({ nom: '', responsable: '', departement_id: '' ,responsable_email: '' });

const loadServices = async () => {
  svcLoading.value = true;
  try {
    const { data } = await api.get('/services');
    services.value = data;
    console.log('Services chargés :', data);
  } finally { svcLoading.value = false; }
};

const addService = async () => {
  if (!newSvc.nom.trim() || !newSvc.departement_id) return;
  try {
    const { data } = await api.post('/services', {
      nom: newSvc.nom.trim(),
      responsable: newSvc.responsable.trim(),
      departement_id: newSvc.departement_id,
      responsable_email: newSvc.responsable_email?.trim(),
    });
    services.value.push(data);
    newSvc.nom = ''; newSvc.responsable = ''; newSvc.departement_id = '';
  } catch (e) { alert(e.response?.data?.message ?? 'Erreur'); }
};

const saveService = async () => {
  try {
    const { data } = await api.put(`/services/${editingSvc.value.id}`, {
      nom: editingSvc.value.nom,
      responsable: editingSvc.value.responsable,
      departement_id: editingSvc.value.departement_id,
      responsable_email: editingSvc.value.responsable_email,
    });
    const idx = services.value.findIndex(s => s.id === data.id);
    if (idx !== -1) services.value[idx] = data;
    editingSvc.value = null;
  } catch (e) { alert(e.response?.data?.message ?? 'Erreur'); }
};

const deleteService = async (svc) => {
  if (!confirm(`Supprimer le service "${svc.nom}" ?`)) return;
  try {
    await api.delete(`/services/${svc.id}`);
    services.value = services.value.filter(s => s.id !== svc.id);
  } catch (e) { alert(e.response?.data?.message ?? 'Erreur'); }
};

onMounted(async () => {
  await loadSettings();
  await Promise.all([loadDepartements(), loadServices()]);
});


</script>