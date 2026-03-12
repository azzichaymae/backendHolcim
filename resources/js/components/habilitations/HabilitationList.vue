<template>
  <div class="habilitation-list">

    <!-- ── Header ─────────────────────────────────────────────────────── -->
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

    <!-- ── Filters ─────────────────────────────────────────────────────── -->
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

    <!-- ── Loading ─────────────────────────────────────────────────────── -->
    <div class="loading-state" v-if="loading">
      <div class="loader"></div>
    </div>

    <!-- ── Empty ───────────────────────────────────────────────────────── -->
    <div class="empty-state" v-else-if="filtered.length === 0">
      <span v-html="icons.shield"></span>
      <p>Aucune habilitation trouvée.</p>
    </div>

    <!-- ── Main layout: table + slide panel ───────────────────────────── -->
    <div :class="['hl-layout', { 'panel-open': !!selectedHab }]" v-else>

      <!-- Table -->
        <div class="hab-table-card">
        <table class="data-table">
          <thead>
            <tr>
              <th>Habilitation</th>
              <th>Volet</th>
              <th>Validité</th>
              <th>Employés</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            <tr
              v-for="hab in filtered"
              :key="hab.id"
              :class="['table-row', { 'row-active': selectedHab?.id === hab.id }]"
              @click="openPreview(hab)"
            >
              <td>
                <div class="hab-name">{{ hab.nom }}</div>
                <div class="hab-sub" v-if="hab.is_standard">
                  <span class="standard-chip" v-html="icons.star"></span>
                  <span>Standard</span>
                </div>
              </td>
              <td>
                <span class="volet-tag">{{ hab.volet?.nom }}</span>
              </td>
              <td>
                <span class="validite-badge">{{ hab.duree_de_validite }} ans</span>
              </td>
              <td>
                <span class="emp-count-badge">
                  <span v-html="icons.users"></span>
                  {{ hab.employee_count ?? '—' }}
                </span>
              </td>
              <td @click.stop>
                <div class="actions">
                  <button class="action-btn preview"
                    @click="openPreview(hab)" title="Aperçu">
                    <span v-html="icons.eye"></span>
                  </button>
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
      

      <!-- ══ SLIDE-IN DETAIL PANEL ══════════════════════════════════════ -->
      <Transition name="slide-panel">
        <div class="detail-panel" v-if="selectedHab">

          <!-- Panel header -->
          <div class="dp-header">
            <div class="dp-title-block">
              <span class="dp-volet-chip">{{ selectedHab.volet?.nom }}</span>
              <h2 class="dp-title">{{ selectedHab.nom }}</h2>
              <div class="dp-meta-row">
                <span class="dp-meta-item" v-if="selectedHab.is_standard">
                  <span v-html="icons.star"></span> Standard
                </span>
                <span class="dp-meta-item">
                  <span v-html="icons.calendar"></span>
                  Validité : {{ selectedHab.duree_de_validite }} ans
                </span>
              </div>
            </div>
            <button class="dp-close" @click="closePreview" title="Fermer">
              <span v-html="icons.x"></span>
            </button>
          </div>

          <!-- Duration cards -->
          <div class="dp-duration-grid">
            <div class="dp-dur-card">
              <div class="dp-dur-icon" v-html="icons.clock"></div>
              <div class="dp-dur-label">Formation initiale</div>
              <div class="dp-dur-value">
                {{ selectedHab.duree_formation_initiale }}
                {{ selectedHab.duree_formation_initiale_unite }}
              </div>
            </div>
            <div class="dp-dur-card">
              <div class="dp-dur-icon recycle" v-html="icons.refresh"></div>
              <div class="dp-dur-label">Recyclage</div>
              <div class="dp-dur-value">
                {{ selectedHab.duree_formation_recyclage }}
                {{ selectedHab.duree_formation_recyclage_unite }}
              </div>
            </div>
            <div class="dp-dur-card">
              <div class="dp-dur-icon valid" v-html="icons.calendar"></div>
              <div class="dp-dur-label">Validité</div>
              <div class="dp-dur-value">{{ selectedHab.duree_de_validite }} ans</div>
            </div>
          </div>

          <!-- Detail note -->
          <div class="dp-detail" v-if="selectedHab.detail_formation">
            <span v-html="icons.info"></span>
            {{ selectedHab.detail_formation }}
          </div>

          <!-- Stats strip -->
          <div class="dp-stats-strip">
            <div class="dp-stat">
              <span class="dp-stat-num">{{ previewStats.total }}</span>
              <span class="dp-stat-label">Total</span>
            </div>
            <div class="dp-stat green">
              <span class="dp-stat-num">{{ previewStats.valides }}</span>
              <span class="dp-stat-label">Valides</span>
            </div>
            <div class="dp-stat orange">
              <span class="dp-stat-num">{{ previewStats.expirent_bientot }}</span>
              <span class="dp-stat-label">Expirent bientôt</span>
            </div>
            <div class="dp-stat red">
              <span class="dp-stat-num">{{ previewStats.expires }}</span>
              <span class="dp-stat-label">Expirées</span>
            </div>
          </div>

          <!-- Employees table -->
          <div class="dp-emp-section">
            <div class="dp-section-title">Employés habilités</div>

            <div class="dp-loading" v-if="previewLoading">
              <div class="dp-spinner"></div>
            </div>

            <div class="dp-emp-empty" v-else-if="previewEmployees.length === 0">
              Aucun employé ne possède cette habilitation.
            </div>

            <ul class="dp-emp-list" v-else>
              <li
                v-for="emp in previewEmployees"
                :key="emp.employee_habilitation_id"
                class="dp-emp-clickable"
                @click="openAttributionModal(emp.employee_habilitation_id)"
                title="Voir les détails de l'attribution"
              >
                <div class="dp-emp-avatar">{{ emp.nom_complet.trim().split(' ').map(w => w[0]).slice(0,2).join('') }}</div>
                <div class="dp-emp-info">
                  <span class="dp-emp-name">{{ emp.nom_complet }}</span>
                  <span class="dp-emp-mat">
                    {{ emp.matricule ? `Matricule : ${emp.matricule}` : 'Sous-traitant' }}
                  </span>
                </div>
                <span :class="['dp-statut', emp.statut]">{{ emp.statut }}</span>
                <span class="dp-emp-arrow" v-html="icons.chevron"></span>
              </li>
            </ul>
          </div>

        </div>
      </Transition>
    </div>

    <!-- ── Add / Edit Modal ────────────────────────────────────────────── -->
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

          <div style="display:grid;grid-template-columns:1fr 1fr;gap:16px;">

            <div style="grid-column:span 2;" class="modal-field">
              <label>Nom <span style="color:#ef4444">*</span></label>
              <input v-model="form.nom" type="text"
                placeholder="Ex: Porteur de Cadenas"
                :class="{ 'input-error': errors.nom }" />
              <span class="error-msg" v-if="errors.nom">{{ errors.nom }}</span>
            </div>

            <div style="grid-column:span 2;" class="modal-field">
              <label>Volet <span style="color:#ef4444">*</span></label>
              <select v-model="form.volet_id" :class="{ 'input-error': errors.volet_id }">
                <option value="">Sélectionner un volet</option>
                <option v-for="v in volets" :key="v.id" :value="v.id">{{ v.nom }}</option>
              </select>
              <span class="error-msg" v-if="errors.volet_id">{{ errors.volet_id }}</span>
            </div>

            <div class="modal-field">
              <label>Durée formation initiale <span style="color:#ef4444">*</span></label>
              <input v-model="form.duree_formation_initiale" type="number" min="1"
                :class="{ 'input-error': errors.duree_formation_initiale }" />
              <span class="error-msg" v-if="errors.duree_formation_initiale">{{ errors.duree_formation_initiale }}</span>
            </div>
            <div class="modal-field">
              <label>Unité <span style="color:#ef4444">*</span></label>
              <select v-model="form.duree_formation_initiale_unite">
                <option value="heures">Heures</option>
                <option value="jours">Jours</option>
              </select>
            </div>

            <div class="modal-field">
              <label>Durée recyclage <span style="color:#ef4444">*</span></label>
              <input v-model="form.duree_formation_recyclage" type="number" min="1"
                :class="{ 'input-error': errors.duree_formation_recyclage }" />
              <span class="error-msg" v-if="errors.duree_formation_recyclage">{{ errors.duree_formation_recyclage }}</span>
            </div>
            <div class="modal-field">
              <label>Unité <span style="color:#ef4444">*</span></label>
              <select v-model="form.duree_formation_recyclage_unite">
                <option value="heures">Heures</option>
                <option value="jours">Jours</option>
              </select>
            </div>

            <div class="modal-field">
              <label>Durée de validité (années) <span style="color:#ef4444">*</span></label>
              <input v-model="form.duree_de_validite" type="number" min="1"
                :class="{ 'input-error': errors.duree_de_validite }" />
              <span class="error-msg" v-if="errors.duree_de_validite">{{ errors.duree_de_validite }}</span>
            </div>

            <div class="modal-field" style="display:flex;align-items:center;gap:10px;padding-top:24px;">
              <input type="checkbox" v-model="form.is_standard" id="is_standard"
                style="width:16px;height:16px;accent-color:#1a6b8a;cursor:pointer;" />
              <label for="is_standard"
                style="font-size:0.875rem;font-weight:600;color:#374151;cursor:pointer;">
                Habilitation standard du volet
              </label>
            </div>

            <div style="grid-column:span 2;" class="modal-field">
              <label>Détail / description (optionnel)</label>
              <input v-model="form.detail_formation" type="text"
                placeholder="Ex: Travaux électriques BT..." />
            </div>

          </div>

          <div v-if="errors.global" style="
            margin-top:16px;background:#fef2f2;border:1px solid #fecaca;
            color:#dc2626;padding:10px 14px;border-radius:8px;font-size:0.875rem;
          ">{{ errors.global }}</div>

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

    <!-- ══ Attribution Detail Modal ════════════════════════════════════════ -->
    <Teleport to="body">
      <Transition name="adm-fade">
        <div
          v-if="attrModal.show"
          class="adm-backdrop"
          @click.self="closeAttributionModal"
        >
          <Transition name="adm-slide">
            <div class="adm-dialog" v-if="attrModal.show">

              <!-- Modal header -->
              <div class="adm-header">
                <div class="adm-header-left">
                  <div class="adm-avatar">{{ initiales(attrModal.data) }}</div>
                  <div>
                    <div class="adm-emp-name" v-if="!attrModal.loading">
                      {{ attrModal.data?.employee?.prenom }} {{ attrModal.data?.employee?.nom }}
                    </div>
                    <div class="adm-emp-meta" v-if="!attrModal.loading">
                      {{ attrModal.data?.employee?.matricule }}
                      · {{ attrModal.data?.employee?.position }}
                    </div>
                    <div class="adm-skeleton-line wide" v-else></div>
                    <div class="adm-skeleton-line" v-if="attrModal.loading"></div>
                  </div>
                </div>
                <button class="adm-close" @click="closeAttributionModal">
                  <span v-html="icons.x"></span>
                </button>
              </div>

              <!-- Loading state -->
              <div class="adm-loading" v-if="attrModal.loading">
                <div class="adm-spinner"></div>
                <span>Chargement...</span>
              </div>

              <template v-else-if="attrModal.data">
                <!-- Habilitation banner -->
                <div class="adm-hab-banner">
                  <div class="adm-hab-volet">{{ attrModal.data.habilitation?.volet?.nom }}</div>
                  <div class="adm-hab-name">{{ attrModal.data.habilitation?.nom }}</div>
                </div>

                <!-- Info grid -->
                <div class="adm-info-grid">
                  <div class="adm-info-item">
                    <span class="adm-info-label">Date d'obtention</span>
                    <span class="adm-info-value">{{ formatDate(attrModal.data.date_obtention) }}</span>
                  </div>
                  <div class="adm-info-item">
                    <span class="adm-info-label">Date d'expiration</span>
                    <span :class="['adm-info-value', expirationClass(attrModal.data)]">
                      {{ formatDate(attrModal.data.date_expiration) }}
                    </span>
                  </div>
                  <div class="adm-info-item">
                    <span class="adm-info-label">Type</span>
                    <span :class="['adm-type-badge', attrModal.data.type]">
                      {{ attrModal.data.type }}
                    </span>
                  </div>
                  <div class="adm-info-item">
                    <span class="adm-info-label">Statut</span>
                    <span :class="['adm-statut-badge', attrModal.data.statut]">
                      {{ attrModal.data.statut }}
                    </span>
                  </div>
                  <div class="adm-info-item">
                    <span class="adm-info-label">Organisme de formation</span>
                    <span class="adm-info-value">{{ attrModal.data.organisme_formation || '—' }}</span>
                  </div>
                  <div class="adm-info-item">
                    <span class="adm-info-label">Aptitude médicale</span>
                    <span class="adm-info-value">{{ formatDate(attrModal.data.date_aptitude_medicale) }}</span>
                  </div>
                  <div class="adm-info-item">
                    <span class="adm-info-label">Service</span>
                    <span class="adm-info-value">{{ attrModal.data.employee?.service?.nom || '—' }}</span>
                  </div>
                  <div class="adm-info-item">
                    <span class="adm-info-label">Département</span>
                    <span class="adm-info-value">{{ attrModal.data.employee?.departement?.nom || '—' }}</span>
                  </div>
                </div>

                <!-- Alerts section -->
                <div class="adm-section" v-if="attrModal.data.alerts?.length">
                  <div class="adm-section-title">
                    <span v-html="icons.bell"></span>
                    Alertes ({{ attrModal.data.alerts.length }})
                  </div>
                  <div class="adm-alert-list">
                    <div
                      class="adm-alert-item"
                      v-for="alert in attrModal.data.alerts"
                      :key="alert.id"
                    >
                      <span class="adm-alert-dot"></span>
                      <div>
                        <div class="adm-alert-type">{{ alert.alert_type }}</div>
                        <div class="adm-alert-date">
                          {{ formatDate(alert.alert_date) }}
                          · {{ alert.jours_avant_expiration }}j avant expiration
                        </div>
                      </div>
                      <span :class="['adm-alert-statut', alert.statut]">{{ alert.statut }}</span>
                    </div>
                  </div>
                </div>

                <!-- Documents section -->
                <div class="adm-section" v-if="attrModal.data.documents?.length">
                  <div class="adm-section-title">
                    <span v-html="icons.document"></span>
                    Documents ({{ attrModal.data.documents.length }})
                  </div>
                  <div class="adm-doc-list">
                    <div
                      class="adm-doc-item"
                      v-for="doc in attrModal.data.documents"
                      :key="doc.id"
                    >
                      <span v-html="icons.filePdf"></span>
                      <div>
                        <div class="adm-doc-name">{{ doc.type_document }}</div>
                        <div class="adm-doc-date">Généré le {{ formatDate(doc.generated_at) }}</div>
                      </div>
                    </div>
                  </div>
                </div>

              </template>

            </div>
          </Transition>
        </div>
      </Transition>
    </Teleport>

    <!-- ── Delete confirm ──────────────────────────────────────────────── -->
    <ConfirmModal
      :show="!!deleteTarget"
      title="Supprimer cette habilitation ?"
      confirmLabel="Supprimer"
      :loading="deleting"
      :icon="icons.trash"
      @confirm="deleteHabilitation"
      @cancel="deleteTarget = null"
    >
      Voulez-vous supprimer <strong>{{ deleteTarget?.nom }}</strong> ?<br>
      Cette action est irréversible.
    </ConfirmModal>

  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue';
import api from '@/services/api';
import ConfirmModal from '@/components/shared/ConfirmModal.vue';
import '@/../css/components/habilitations/habilitation-list.css';
const habilitations  = ref([]);
const volets         = ref([]);
const loading        = ref(true);
const submitting     = ref(false);
const deleting       = ref(false);
const showModal      = ref(false);
const editTarget     = ref(null);
const deleteTarget   = ref(null);
const search         = ref('');
const filterVolet    = ref('');

// ── Preview state ──────────────────────────────────────────────────────────
const selectedHab      = ref(null);
const previewEmployees = ref([]);
const previewLoading   = ref(false);

const previewStats = computed(() => {
  const emps = previewEmployees.value;
  return {
    total:           emps.length,
    valides:         emps.filter(e => e.statut === 'valide').length,
    expires:         emps.filter(e => e.statut === 'expirée').length,
    expirent_bientot: emps.filter(e => e.statut === 'expire_bientot').length,
  };
});

// ── Computed ───────────────────────────────────────────────────────────────
const total    = computed(() => habilitations.value.length);
const filtered = computed(() =>
  habilitations.value.filter(h => {
    const matchSearch = !search.value ||
      h.nom.toLowerCase().includes(search.value.toLowerCase());
    const matchVolet = !filterVolet.value || h.volet_id == filterVolet.value;
    return matchSearch && matchVolet;
  })
);

// ── Icons ──────────────────────────────────────────────────────────────────
const icons = {
  plus:     `<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"/></svg>`,
  search:   `<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"/></svg>`,
  edit:     `<svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"/></svg>`,
  trash:    `<svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"/></svg>`,
  eye:      `<svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"/><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"/></svg>`,
  shield:   `<svg xmlns="http://www.w3.org/2000/svg" width="48" height="48" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z"/></svg>`,
  star:     `<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="#f59e0b" viewBox="0 0 24 24"><path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z"/></svg>`,
  x:        `<svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/></svg>`,
  clock:    `<svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>`,
  refresh:  `<svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"/></svg>`,
  calendar: `<svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"/></svg>`,
  info:     `<svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>`,
  bell:     `<svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9"/></svg>`,
  document: `<svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"/></svg>`,
  filePdf:  `<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 21h10a2 2 0 002-2V9.414a1 1 0 00-.293-.707l-5.414-5.414A1 1 0 0012.586 3H7a2 2 0 00-2 2v14a2 2 0 002 2z"/></svg>`,
  chevron:  `<svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M9 5l7 7-7 7"/></svg>`,
  users:    `<svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0z"/></svg>`,
};

// ── Form ───────────────────────────────────────────────────────────────────
const defaultForm = () => ({
  nom:                             '',
  volet_id:                        '',
  duree_formation_initiale:        '',
  duree_formation_initiale_unite:  'heures',
  duree_formation_recyclage:       '',
  duree_formation_recyclage_unite: 'heures',
  duree_de_validite:               '',
  detail_formation:                '',
  is_standard:                     false,
});

const form   = reactive(defaultForm());
const errors = reactive({
  nom: '', volet_id: '',
  duree_formation_initiale: '',
  duree_formation_recyclage: '',
  duree_de_validite: '',
  global: '',
});

// ── Preview ────────────────────────────────────────────────────────────────
const openPreview = async (hab) => {
  // Toggle off if same row clicked again
  if (selectedHab.value?.id === hab.id) {
    closePreview();
    return;
  }
  selectedHab.value      = hab;
  previewEmployees.value = [];
  previewLoading.value   = true;

  try {
    const { data } = await api.get(`/documents/employees-par-habilitation/${hab.id}`);
    previewEmployees.value = data.employees ?? [];
  } catch {
    previewEmployees.value = [];
  } finally {
    previewLoading.value = false;
  }
};

const closePreview = () => {
  selectedHab.value      = null;
  previewEmployees.value = [];
};

// ── Attribution Detail Modal ───────────────────────────────────────────────
const attrModal = reactive({
  show:    false,
  loading: false,
  data:    null,
});

const openAttributionModal = async (employeeHabilitationId) => {
  attrModal.show    = true;
  attrModal.loading = true;
  attrModal.data    = null;
  try {
    const { data } = await api.get(`/employee-habilitations/${employeeHabilitationId}`);
    attrModal.data = data;
  } catch (e) {
    console.error(e);
    attrModal.show = false;
  } finally {
    attrModal.loading = false;
  }
};

const closeAttributionModal = () => {
  attrModal.show = false;
  attrModal.data = null;
};

// ── Helpers ────────────────────────────────────────────────────────────────
const formatDate = (d) =>
  d ? new Date(d).toLocaleDateString('fr-FR') : '—';

const initiales = (data) => {
  if (!data?.employee) return '?';
  return (data.employee.prenom?.[0] ?? '') + (data.employee.nom?.[0] ?? '');
};

const expirationClass = (data) => {
  if (!data?.statut) return '';
  if (data.statut === 'expirée' || data.statut === 'expiree') return 'text-red';
  if (data.statut === 'expire_bientot') return 'text-orange';
  return 'text-green';
};

// ── Fetch ──────────────────────────────────────────────────────────────────
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

// ── Modal ──────────────────────────────────────────────────────────────────
const openModal = (hab = null) => {
  editTarget.value = hab;
  Object.keys(errors).forEach(k => errors[k] = '');
  if (hab) {
    form.nom                             = hab.nom;
    form.volet_id                        = hab.volet_id;
    form.duree_formation_initiale        = hab.duree_formation_initiale;
    form.duree_formation_initiale_unite  = hab.duree_formation_initiale_unite;
    form.duree_formation_recyclage       = hab.duree_formation_recyclage;
    form.duree_formation_recyclage_unite = hab.duree_formation_recyclage_unite;
    form.duree_de_validite               = hab.duree_de_validite;
    form.detail_formation                = hab.detail_formation ?? '';
    form.is_standard                     = !!hab.is_standard;
  } else {
    Object.assign(form, defaultForm());
  }
  showModal.value = true;
};

const closeModal = () => { showModal.value = false; editTarget.value = null; };

// ── Validate & Submit ──────────────────────────────────────────────────────
const validate = () => {
  let valid = true;
  Object.keys(errors).forEach(k => errors[k] = '');
  if (!form.nom)                     { errors.nom = 'Le nom est obligatoire.'; valid = false; }
  if (!form.volet_id)                { errors.volet_id = 'Le volet est obligatoire.'; valid = false; }
  if (!form.duree_formation_initiale){ errors.duree_formation_initiale = 'Obligatoire.'; valid = false; }
  if (!form.duree_formation_recyclage){ errors.duree_formation_recyclage = 'Obligatoire.'; valid = false; }
  if (!form.duree_de_validite)       { errors.duree_de_validite = 'Obligatoire.'; valid = false; }
  return valid;
};

const submit = async () => {
  if (!validate()) return;
  submitting.value = true;
  try {
    if (editTarget.value) {
      const { data } = await api.put(`/habilitations/${editTarget.value.id}`, form);
      const idx = habilitations.value.findIndex(h => h.id === editTarget.value.id);
      if (idx !== -1) habilitations.value[idx] = data;
      // Refresh preview if currently viewing this hab
      if (selectedHab.value?.id === editTarget.value.id) selectedHab.value = data;
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

// ── Delete ─────────────────────────────────────────────────────────────────
const confirmDelete    = (hab) => { deleteTarget.value = hab; };
const deleteHabilitation = async () => {
  deleting.value = true;
  try {
    await api.delete(`/habilitations/${deleteTarget.value.id}`);
    if (selectedHab.value?.id === deleteTarget.value.id) closePreview();
    habilitations.value = habilitations.value.filter(h => h.id !== deleteTarget.value.id);
    deleteTarget.value  = null;
  } catch (err) {
    alert(err.response?.data?.message ?? 'Impossible de supprimer.');
    deleteTarget.value = null;
  } finally {
    deleting.value = false;
  }
};

onMounted(fetchAll);
</script>