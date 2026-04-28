<template>
  <div class="referentiel">

    <!-- ── Header ──────────────────────────────────────────────────────── -->
    <div class="page-header">
      <div>
        <h1 class="page-title">Référentiel des Habilitations</h1>
        <p class="page-subtitle">{{ habilitations.length }} habilitation(s) · {{ volets.length }} catégorie(s)</p>
      </div>
      <div class="header-actions" v-if="!isManager">
  <button class="btn-secondary" @click="openVoletModal()">
    <span v-html="icons.folder"></span>
    Nouvelle catégorie
  </button>
  <button class="btn-add" @click="openModal()">
    <span v-html="icons.plus"></span>
    Nouvelle habilitation
  </button>
</div>
    </div>

    <!-- ── Search bar ───────────────────────────────────────────────────── -->
    <div class="ref-search-bar">
      <div class="search-wrapper">
        <span class="search-icon" v-html="icons.search"></span>
        <input v-model="search" type="text" placeholder="Rechercher une habilitation..." class="search-input" />
      </div>
    </div>

    <!-- ── Loading ──────────────────────────────────────────────────────── -->
    <div class="loading-state" v-if="loading">
      <div class="loader"></div>
    </div>

    <!-- ── Two-panel layout ─────────────────────────────────────────────── -->
    <div class="ref-layout" v-else>

      <!-- LEFT: Volets sidebar -->
      <div class="ref-sidebar">
        <div class="sidebar-title">Catégories</div>

        <!-- All -->
        <div class="volet-item" :class="{ active: activeVoletId === null }" @click="activeVoletId = null">
          <span class="volet-item-name">Toutes les catégories</span>
          <span class="volet-item-count">{{ habilitations.length }}</span>
        </div>

        <!-- Each volet -->
        <div v-for="v in volets" :key="v.id" class="volet-item" :class="{ active: activeVoletId === v.id }"
          @click="activeVoletId = v.id" @mouseenter="hoveredVolet = v.id" @mouseleave="hoveredVolet = null">
          <span class="volet-item-name">{{ v.nom }}</span>
          <div class="volet-item-right">
            <span class="volet-item-count">{{ habCountForVolet(v.id) }}</span>
            <div class="volet-actions" v-show="hoveredVolet === v.id && !isManager">
  <button class="volet-btn edit" @click.stop="openVoletModal(v)">
    <span v-html="icons.edit"></span>
  </button>
  <button class="volet-btn delete" @click.stop="confirmDeleteVolet(v)">
    <span v-html="icons.trash"></span>
  </button>
</div>
          </div>
        </div>
      </div>

      <!-- RIGHT: Habilitations -->
      <div class="ref-main">

        <!-- Empty -->
        <div class="empty-state" v-if="filteredGrouped.length === 0">
          <span v-html="icons.shield"></span>
          <p>Aucune habilitation trouvée.</p>
        </div>

        <!-- Grouped by volet -->
        <div :class="['ref-content', { 'panel-open': !!selectedHab }]" v-else>

          <!-- Habilitations groups -->
          <div class="hab-group-container">
            <div v-for="[voletNom, habs] in paginatedGrouped" :key="voletNom" class="hab-group">

              <!-- Fixed Header -->
              <div class="hab-group-header sticky-header">
                <span class="hab-group-title">{{ voletNom }}</span>
                <span class="hab-group-count">{{ habs.length }} habilitation(s)</span>
                <button class="hab-group-add" v-if="!isManager" @click="openModalForVolet(voletNom)">
  <span v-html="icons.plus"></span>
</button>
              </div>

              <!-- Scrollable Table Container -->
              <div class="table-container">
                <table class="data-table">
                  <thead>
                    <tr>
                      <th>Habilitation</th>
                      <th>Formation initiale</th>
                      <th>Recyclage</th>
                      <th>Fréquence</th>
                      <th>Employés</th>
                      <th>Actions</th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr v-for="hab in habs" :key="hab.id"
                      :class="['table-row', { 'row-active': selectedHab?.id === hab.id }]" @click="openPreview(hab)">
                      <td>
                        <div class="hab-name">{{ hab.nom }}</div>
                      </td>
                      <td class="td-muted">
                        {{ hab.duree_formation_initiale }} {{ hab.duree_formation_initiale_unite }}
                      </td>
                      <td class="td-muted">
                        {{ hab.duree_formation_recyclage }} {{ hab.duree_formation_recyclage_unite }}
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
    <button class="action-btn preview" @click="openPreview(hab)" title="Aperçu">
      <span v-html="icons.eye"></span>
    </button>
    <button class="action-btn edit" v-if="!isManager" @click="openModal(hab)" title="Modifier">
      <span v-html="icons.edit"></span>
    </button>
    <button class="action-btn delete" v-if="!isManager" @click="confirmDelete(hab)" title="Supprimer">
      <span v-html="icons.trash"></span>
    </button>
  </div>
</td>
                    </tr>
                  </tbody>
                </table>
              </div>
            </div>
          </div>

          <!-- Detail panel -->
          <Transition name="slide-panel">
            <div class="detail-panel" v-if="selectedHab">

              <div class="dp-header">
                <div class="dp-title-block">
                  <span class="dp-volet-chip">{{ selectedHab.volet?.nom }}</span>
                  <h2 class="dp-title">{{ selectedHab.nom }}</h2>
                  <div class="dp-meta-row">
                    <span class="dp-meta-item">
                      <span v-html="icons.calendar"></span>
                      Fréquence : {{ selectedHab.duree_de_validite }} ans
                    </span>
                  </div>
                </div>
                <button class="dp-close" @click="closePreview">
                  <span v-html="icons.x"></span>
                </button>
              </div>

              <div class="dp-duration-grid">
                <div class="dp-dur-card">
                  <div class="dp-dur-icon"><span v-html="icons.clock"></span></div>
                  <div class="dp-dur-label">Formation initiale</div>
                  <div class="dp-dur-value">{{ selectedHab.duree_formation_initiale }} {{
                    selectedHab.duree_formation_initiale_unite }}</div>
                </div>
                <div class="dp-dur-card">
                  <div class="dp-dur-icon recycle"><span v-html="icons.refresh"></span></div>
                  <div class="dp-dur-label">Recyclage</div>
                  <div class="dp-dur-value">{{ selectedHab.duree_formation_recyclage }} {{
                    selectedHab.duree_formation_recyclage_unite }}</div>
                </div>
                <div class="dp-dur-card">
                  <div class="dp-dur-icon valid"><span v-html="icons.calendar"></span></div>
                  <div class="dp-dur-label">Fréquence</div>
                  <div class="dp-dur-value">{{ selectedHab.duree_de_validite }} ans</div>
                </div>
              </div>

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
                  <span class="dp-stat-label">Bientôt</span>
                </div>
                <div class="dp-stat red">
                  <span class="dp-stat-num">{{ previewStats.expires }}</span>
                  <span class="dp-stat-label">Expirés</span>
                </div>
              </div>

              <div class="dp-emp-section">
                <div class="dp-section-title">Employés habilités</div>
                <div class="dp-loading" v-if="previewLoading">
                  <div class="dp-spinner"></div>
                </div>
                <div class="dp-emp-empty" v-else-if="previewEmployees.length === 0">
                  Aucun employé habilité.
                </div>
                <ul class="dp-emp-list" v-else>
                  <li v-for="emp in previewEmployees" :key="emp.id">
                    <div class="dp-emp-clickable" @click="openAttributionModal(emp.employee_habilitation_id)">
                      <div class="dp-emp-avatar">{{ (emp.prenom?.[0] ?? '') + (emp.nom?.[0] ?? '') }}</div>
                      <div class="dp-emp-info">
                        <span class="dp-emp-name">{{ emp.nom_complet }}</span>
                        <span class="dp-emp-mat">
                          {{ emp.matricule ? `Matricule : ${emp.matricule}` : 'Sous-traitant' }}
                        </span>
                      </div>
                      <span :class="['dp-statut', emp.statut]">{{ emp.statut }}</span>
                      <span class="dp-emp-arrow" v-html="icons.chevron"></span>
                    </div>
                  </li>
                </ul>
              </div>

            </div>
          </Transition>
          
        </div><div class="ref-pagination" v-if="totalPages > 1">
            <button class="page-btn" :disabled="currentPage === 1" @click="currentPage--">
              <span v-html="icons.chevronLeft"></span>
            </button>
            <button v-for="p in totalPages" :key="p" class="page-btn" :class="{ active: p === currentPage }"
              @click="currentPage = p">{{ p }}</button>
            <button class="page-btn" :disabled="currentPage === totalPages" @click="currentPage++">
              <span v-html="icons.chevronRight"></span>
            </button>
          </div>
      </div>
    </div>

    <!-- ── Habilitation Modal ────────────────────────────────────────────── -->
    <Teleport to="body">
      <Transition name="adm-fade">
        <div class="adm-backdrop" v-if="showModal" @click.self="closeModal">
          <Transition name="adm-slide">
            <div class="adm-dialog" v-if="showModal">
              <div class="adm-header">
                <div>
                  <h3 style="margin:0;font-size:1rem;font-weight:700;color:#1a2e44">
                    {{ editTarget ? 'Modifier l\'habilitation' : 'Nouvelle habilitation' }}
                  </h3>
                </div>
                <button class="adm-close" @click="closeModal"><span v-html="icons.x"></span></button>
              </div>
              <div style="padding:20px 22px;display:flex;flex-direction:column;gap:14px;">
                <div class="modal-field">
                  <label>Nom <span style="color:#ef4444">*</span></label>
                  <input v-model="form.nom" :class="{ 'input-error': errors.nom }"
                    placeholder="Nom de l'habilitation" />
                  <span class="error-msg" v-if="errors.nom">{{ errors.nom }}</span>
                </div>
                <div class="modal-field">
                  <label>Catégorie <span style="color:#ef4444">*</span></label>
                  <select v-model="form.volet_id" :class="{ 'input-error': errors.volet_id }">
                    <option value="">Sélectionner une catégorie</option>
                    <option v-for="v in volets" :key="v.id" :value="v.id">{{ v.nom }}</option>
                  </select>
                  <span class="error-msg" v-if="errors.volet_id">{{ errors.volet_id }}</span>
                </div>
                <div style="display:grid;grid-template-columns:1fr 1fr;gap:12px">
                  <div class="modal-field">
                    <label>Formation initiale <span style="color:#ef4444">*</span></label>
                    <div style="display:flex;gap:8px">
                      <input v-model="form.duree_formation_initiale" type="number" min="0.5" step="0.5"
                        :class="{ 'input-error': errors.duree_formation_initiale }" style="flex:1" />
                      <select v-model="form.duree_formation_initiale_unite" style="width:90px">
                        <option value="heures">heures</option>
                        <option value="jours">jours</option>
                      </select>
                    </div>
                    <span class="error-msg" v-if="errors.duree_formation_initiale">{{ errors.duree_formation_initiale
                    }}</span>
                  </div>
                  <div class="modal-field">
                    <label>Recyclage <span style="color:#ef4444">*</span></label>
                    <div style="display:flex;gap:8px">
                      <input v-model="form.duree_formation_recyclage" type="number" min="0.5" step="0.5"
                        :class="{ 'input-error': errors.duree_formation_recyclage }" style="flex:1" />
                      <select v-model="form.duree_formation_recyclage_unite" style="width:90px">
                        <option value="heures">heures</option>
                        <option value="jours">jours</option>
                      </select>
                    </div>
                    <span class="error-msg" v-if="errors.duree_formation_recyclage">{{ errors.duree_formation_recyclage
                    }}</span>
                  </div>
                </div>
                <div class="modal-field">
                  <label>Fréquence de recyclage (années) <span style="color:#ef4444">*</span></label>
                  <input v-model="form.duree_de_validite" type="number" min="1"
                    :class="{ 'input-error': errors.duree_de_validite }" placeholder="Ex: 3" />
                  <span class="error-msg" v-if="errors.duree_de_validite">{{ errors.duree_de_validite }}</span>
                </div>
                <div class="modal-field">
                  <label>Texte d'autorisation</label>
                  <input v-model="form.texte_autorisation"
                    placeholder="ex: J'autorise [Employé] à effectuer [ce texte]" />
                  <span class="error-msg" v-if="errors.texte_autorisation">{{ errors.texte_autorisation }}</span>

                </div>
                <span class="error-msg" v-if="errors.global">{{ errors.global }}</span>
              </div>
              <div
                style="display:flex;justify-content:flex-end;gap:10px;padding:14px 22px;border-top:1px solid #f0f4f8">
                <button class="btn-cancel-import" @click="closeModal">Annuler</button>
                <button class="btn-do-import" @click="submit" :disabled="submitting">
                  <span v-if="submitting" class="spinner-sm"></span>
                  {{ editTarget ? 'Enregistrer' : 'Créer' }}
                </button>
              </div>
            </div>
          </Transition>
        </div>
      </Transition>
    </Teleport>

    <!-- ── Volet Modal ───────────────────────────────────────────────────── -->
    <Teleport to="body">
      <Transition name="adm-fade">
        <div class="adm-backdrop" v-if="showVoletModal" @click.self="closeVoletModal">
          <Transition name="adm-slide">
            <div class="adm-dialog" style="max-width:400px" v-if="showVoletModal">
              <div class="adm-header">
                <div>
                  <h3 style="margin:0;font-size:1rem;font-weight:700;color:#1a2e44">
                    {{ editVoletTarget ? 'Modifier la catégorie' : 'Nouvelle catégorie' }}
                  </h3>
                </div>
                <button class="adm-close" @click="closeVoletModal"><span v-html="icons.x"></span></button>
              </div>
              <div style="padding:20px 22px;display:flex;flex-direction:column;gap:14px">
                <div class="modal-field">
                  <label>Nom <span style="color:#ef4444">*</span></label>
                  <input v-model="voletForm.nom" :class="{ 'input-error': voletErrors.nom }"
                    placeholder="Ex: Sécurité Électrique" />
                  <span class="error-msg" v-if="voletErrors.nom">{{ voletErrors.nom }}</span>
                </div>
                <div class="modal-field">
                  <label>Description</label>
                  <input v-model="voletForm.description" placeholder="Description optionnelle" />
                </div>
              </div>
              <div
                style="display:flex;justify-content:flex-end;gap:10px;padding:14px 22px;border-top:1px solid #f0f4f8">
                <button class="btn-cancel-import" @click="closeVoletModal">Annuler</button>
                <button class="btn-do-import" @click="submitVolet" :disabled="submittingVolet">
                  <span v-if="submittingVolet" class="spinner-sm"></span>
                  {{ editVoletTarget ? 'Enregistrer' : 'Créer' }}
                </button>
              </div>
            </div>
          </Transition>
        </div>
      </Transition>
    </Teleport>

    <!-- ── Attribution Detail Modal ─────────────────────────────────────── -->
    <Teleport to="body">
      <Transition name="adm-fade">
        <div class="adm-backdrop" v-if="attrModal.show" @click.self="closeAttributionModal">
          <Transition name="adm-slide">
            <div class="adm-dialog" v-if="attrModal.show">
              <div class="adm-loading" v-if="attrModal.loading">
                <div class="adm-spinner"></div>
                <span>Chargement...</span>
              </div>
              <template v-else-if="attrModal.data">
                <div class="adm-header">
                  <div class="adm-header-left">
                    <div class="adm-avatar">{{ initiales(attrModal.data) }}</div>
                    <div>
                      <div class="adm-emp-name">{{ attrModal.data?.employee?.prenom }} {{ attrModal.data?.employee?.nom
                      }}</div>
                      <div class="adm-emp-meta">{{ attrModal.data?.employee?.matricule }} · {{
                        attrModal.data?.employee?.position }}</div>
                    </div>
                  </div>
                  <button class="adm-close" @click="closeAttributionModal"><span v-html="icons.x"></span></button>
                </div>
                <div class="adm-hab-banner">
                  <div class="adm-hab-volet">{{ attrModal.data.habilitation?.volet?.nom }}</div>
                  <div class="adm-hab-name">{{ attrModal.data.habilitation?.nom }}</div>
                </div>
                <div class="adm-info-grid">
                  <div class="adm-info-item">
                    <span class="adm-info-label">Date d'obtention</span>
                    <span class="adm-info-value">{{ formatDate(attrModal.data.date_obtention) }}</span>
                  </div>
                  <div class="adm-info-item">
                    <span class="adm-info-label">Date d'expiration</span>
                    <span :class="['adm-info-value', expirationClass(attrModal.data)]">{{
                      formatDate(attrModal.data.date_expiration) }}</span>
                  </div>
                  <div class="adm-info-item">
                    <span class="adm-info-label">Type</span>
                    <span :class="['adm-type-badge', attrModal.data.type]">{{ attrModal.data.type }}</span>
                  </div>
                  <div class="adm-info-item">
                    <span class="adm-info-label">Statut</span>
                    <span :class="['adm-statut-badge', attrModal.data.statut]">{{ attrModal.data.statut }}</span>
                  </div>
                  <div class="adm-info-item">
                    <span class="adm-info-label">Organisme</span>
                    <span class="adm-info-value">{{ attrModal.data.organisme_formation || '—' }}</span>
                  </div>
                  <div class="adm-info-item">
                    <span class="adm-info-label">Aptitude médicale</span>
                    <span class="adm-info-value">{{ formatDate(attrModal.data.date_aptitude_medicale) }}</span>
                  </div>
                </div>
              </template>
            </div>
          </Transition>
        </div>
      </Transition>
    </Teleport>

    <!-- ── Delete habilitation confirm ──────────────────────────────────── -->
    <ConfirmModal :show="!!deleteTarget" title="Supprimer cette habilitation ?" confirmLabel="Supprimer"
      :loading="deleting" :icon="icons.trash" @confirm="deleteHabilitation" @cancel="deleteTarget = null">
      Voulez-vous supprimer <strong>{{ deleteTarget?.nom }}</strong> ?<br>
      Cette action est irréversible.
    </ConfirmModal>

    <!-- ── Delete volet confirm ──────────────────────────────────────────── -->
    <ConfirmModal :show="!!deleteVoletTarget" title="Supprimer ce volet ?" confirmLabel="Supprimer"
      :loading="deletingVolet" :icon="icons.trash" @confirm="deleteVolet" @cancel="deleteVoletTarget = null">
      Voulez-vous supprimer le volet <strong>{{ deleteVoletTarget?.nom }}</strong> ?<br>
      Toutes ses habilitations seront également supprimées.
    </ConfirmModal>

  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted, watch } from 'vue';
import api from '@/services/api';
import ConfirmModal from '@/components/shared/ConfirmModal.vue';
import '@/../css/components/habilitations/habilitation-list.css';
import { useAuthStore } from '@/stores/auth';

const authStore  = useAuthStore();
const isManager  = computed(() => authStore.user?.role === 'Manager');
// ── State ──────────────────────────────────────────────────────────────────
const habilitations = ref([]);
const volets = ref([]);
const loading = ref(true);
const search = ref('');
const activeVoletId = ref(null);
const hoveredVolet = ref(null);

// Habilitation modal
const showModal = ref(false);
const editTarget = ref(null);
const submitting = ref(false);
const deleteTarget = ref(null);
const deleting = ref(false);

// Volet modal
const showVoletModal = ref(false);
const editVoletTarget = ref(null);
const submittingVolet = ref(false);
const deleteVoletTarget = ref(null);
const deletingVolet = ref(false);

// Preview panel
const selectedHab = ref(null);
const previewEmployees = ref([]);
const previewLoading = ref(false);

// Attribution modal
const attrModal = reactive({ show: false, loading: false, data: null });

// ── Icons ──────────────────────────────────────────────────────────────────
const icons = {
  chevronLeft: `<svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7"/></svg>`,
  chevronRight: `<svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7"/></svg>`,
  plus: `<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"/></svg>`,
  search: `<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"/></svg>`,
  edit: `<svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"/></svg>`,
  trash: `<svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"/></svg>`,
  eye: `<svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"/><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"/></svg>`,
  shield: `<svg xmlns="http://www.w3.org/2000/svg" width="48" height="48" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z"/></svg>`,
  x: `<svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/></svg>`,
  clock: `<svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>`,
  refresh: `<svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"/></svg>`,
  calendar: `<svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"/></svg>`,
  info: `<svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>`,
  chevron: `<svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M9 5l7 7-7 7"/></svg>`,
  users: `<svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0z"/></svg>`,
  folder: `<svg xmlns="http://www.w3.org/2000/svg" width="15" height="15" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 7a2 2 0 012-2h4l2 2h8a2 2 0 012 2v8a2 2 0 01-2 2H5a2 2 0 01-2-2V7z"/></svg>`,
};

// ── Computed ───────────────────────────────────────────────────────────────
const filtered = computed(() => {
  let list = habilitations.value;
  if (search.value) {
    const s = search.value.toLowerCase();
    list = list.filter(h => h.nom.toLowerCase().includes(s));
  }
  if (activeVoletId.value) {
    list = list.filter(h => h.volet_id == activeVoletId.value);
  }
  return list;
});

const filteredGrouped = computed(() => {
  const groups = {};
  filtered.value.forEach(hab => {
    const nom = hab.volet?.nom ?? 'Sans volet';
    if (!groups[nom]) groups[nom] = [];
    groups[nom].push(hab);
  });
  return Object.entries(groups).sort(([a], [b]) => a.localeCompare(b));
});

const habCountForVolet = (voletId) =>
  habilitations.value.filter(h => h.volet_id == voletId).length;

const previewStats = computed(() => {
  const emps = previewEmployees.value;
  return {
    total: emps.length,
    valides: emps.filter(e => e.statut === 'valide').length,
    expires: emps.filter(e => e.statut === 'expirée').length,
    expirent_bientot: emps.filter(e => e.statut === 'expire_bientot').length,
  };
});

// ── Fetch ──────────────────────────────────────────────────────────────────
const fetchAll = async () => {
  loading.value = true;
  try {
    const [habRes, volRes] = await Promise.all([
      api.get('/habilitations'),
      api.get('/volets'),
    ]);
    habilitations.value = habRes.data;
    volets.value = volRes.data;
  } finally {
    loading.value = false;
  }
};

// ── Preview ────────────────────────────────────────────────────────────────
const openPreview = async (hab) => {
  if (selectedHab.value?.id === hab.id) { closePreview(); return; }
  selectedHab.value = hab;
  previewEmployees.value = [];
  previewLoading.value = true;
  try {
    const { data } = await api.get(`/documents/employees-par-habilitation/${hab.id}`);
     previewEmployees.value = data.employees ?? [];
  } catch {
    previewEmployees.value = [];
  } finally {
    previewLoading.value = false;
  }
};
const closePreview = () => { selectedHab.value = null; previewEmployees.value = []; };

// ── Attribution modal ──────────────────────────────────────────────────────
const openAttributionModal = async (id) => {
  attrModal.show = true; attrModal.loading = true; attrModal.data = null;
  try {
    const { data } = await api.get(`/employee-habilitations/${id}`);
    attrModal.data = data;
  } catch { attrModal.show = false; }
  finally { attrModal.loading = false; }
};
const closeAttributionModal = () => { attrModal.show = false; attrModal.data = null; };

// ── Helpers ────────────────────────────────────────────────────────────────
const formatDate = (d) => d ? new Date(d).toLocaleDateString('fr-FR') : '—';
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

// ── Habilitation Modal ─────────────────────────────────────────────────────
const defaultForm = () => ({
  nom: '', volet_id: '',
  duree_formation_initiale: '', duree_formation_initiale_unite: 'heures',
  duree_formation_recyclage: '', duree_formation_recyclage_unite: 'heures',
  duree_de_validite: '', texte_autorisation: '',
});
const form = reactive(defaultForm());
const errors = reactive({ nom: '', volet_id: '', duree_formation_initiale: '', duree_formation_recyclage: '', duree_de_validite: '', texte_autorisation: '', global: '' });

const openModal = (hab = null) => {
  editTarget.value = hab;
  Object.keys(errors).forEach(k => errors[k] = '');
  if (hab) {
    form.nom = hab.nom;
    form.volet_id = hab.volet_id;
    form.duree_formation_initiale = hab.duree_formation_initiale;
    form.duree_formation_initiale_unite = hab.duree_formation_initiale_unite;
    form.duree_formation_recyclage = hab.duree_formation_recyclage;
    form.duree_formation_recyclage_unite = hab.duree_formation_recyclage_unite;
    form.duree_de_validite = hab.duree_de_validite;
    form.texte_autorisation = hab.texte_autorisation
      ;
  } else {
    Object.assign(form, defaultForm());
    if (activeVoletId.value) form.volet_id = activeVoletId.value;
  }
  showModal.value = true;
};

const openModalForVolet = (voletNom) => {
  const volet = volets.value.find(v => v.nom === voletNom);
  openModal();
  if (volet) form.volet_id = volet.id;
};

const closeModal = () => { showModal.value = false; editTarget.value = null; };

const validate = () => {
  let valid = true;
  Object.keys(errors).forEach(k => errors[k] = '');
  if (!form.nom) { errors.nom = 'Obligatoire.'; valid = false; }
  if (!form.volet_id) { errors.volet_id = 'Obligatoire.'; valid = false; }
  if (!form.duree_formation_initiale) { errors.duree_formation_initiale = 'Obligatoire.'; valid = false; }
  if (!form.duree_formation_recyclage) { errors.duree_formation_recyclage = 'Obligatoire.'; valid = false; }
  if (!form.duree_de_validite) { errors.duree_de_validite = 'Obligatoire.'; valid = false; }
  if (!form.texte_autorisation) { errors.texte_autorisation = 'Obligatoire.'; valid = false; }

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
      if (selectedHab.value?.id === editTarget.value.id) selectedHab.value = data;
    } else {
      const { data } = await api.post('/habilitations', form);
      habilitations.value.push(data);
    }
    closeModal();
  } catch (err) {
    const d = err.response?.data;
    if (d?.errors) Object.keys(d.errors).forEach(k => { if (errors[k] !== undefined) errors[k] = d.errors[k][0]; });
    else errors.global = d?.message ?? 'Une erreur est survenue.';
  } finally {
    submitting.value = false;
  }
};

const confirmDelete = (hab) => { deleteTarget.value = hab; };
const deleteHabilitation = async () => {
  deleting.value = true;
  try {
    await api.delete(`/habilitations/${deleteTarget.value.id}`);
    if (selectedHab.value?.id === deleteTarget.value.id) closePreview();
    habilitations.value = habilitations.value.filter(h => h.id !== deleteTarget.value.id);
    deleteTarget.value = null;
  } catch (err) {
    alert(err.response?.data?.message ?? 'Impossible de supprimer.');
    deleteTarget.value = null;
  } finally {
    deleting.value = false;
  }
};

// ── Volet Modal ────────────────────────────────────────────────────────────
const voletForm = reactive({ nom: '', description: '' });
const voletErrors = reactive({ nom: '' });

const openVoletModal = (volet = null) => {
  editVoletTarget.value = volet;
  voletErrors.nom = '';
  voletForm.nom = volet?.nom ?? '';
  voletForm.description = volet?.description ?? '';
  showVoletModal.value = true;
};
const closeVoletModal = () => { showVoletModal.value = false; editVoletTarget.value = null; };

const submitVolet = async () => {
  voletErrors.nom = '';
  if (!voletForm.nom) { voletErrors.nom = 'Obligatoire.'; return; }
  submittingVolet.value = true;
  try {
    if (editVoletTarget.value) {
      const { data } = await api.put(`/volets/${editVoletTarget.value.id}`, voletForm);
      const idx = volets.value.findIndex(v => v.id === editVoletTarget.value.id);
      if (idx !== -1) volets.value[idx] = data;
    } else {
      const { data } = await api.post('/volets', voletForm);
      volets.value.push(data);
    }
    closeVoletModal();
  } catch (err) {
    voletErrors.nom = err.response?.data?.errors?.nom?.[0] ?? 'Erreur.';
  } finally {
    submittingVolet.value = false;
  }
};

const confirmDeleteVolet = (volet) => { deleteVoletTarget.value = volet; };
const deleteVolet = async () => {
  deletingVolet.value = true;
  try {
    await api.delete(`/volets/${deleteVoletTarget.value.id}`);
    volets.value = volets.value.filter(v => v.id !== deleteVoletTarget.value.id);
    habilitations.value = habilitations.value.filter(h => h.volet_id !== deleteVoletTarget.value.id);
    if (activeVoletId.value === deleteVoletTarget.value.id) activeVoletId.value = null;
    deleteVoletTarget.value = null;
  } catch (err) {
    alert(err.response?.data?.message ?? 'Impossible de supprimer.');
    deleteVoletTarget.value = null;
  } finally {
    deletingVolet.value = false;
  }
};
const currentPage = ref(1);
const perPage = 3;

const paginatedGrouped = computed(() => {
  const start = (currentPage.value - 1) * perPage;
  return filteredGrouped.value.slice(start, start + perPage);
});

const totalPages = computed(() => Math.ceil(filteredGrouped.value.length / perPage));

watch([search, activeVoletId], () => { currentPage.value = 1; });

onMounted(fetchAll);
</script>

 