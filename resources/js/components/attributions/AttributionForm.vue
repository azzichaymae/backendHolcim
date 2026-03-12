<template>
  <div class="attribution-form">

    <!-- ── Header ──────────────────────────────────────────────────────── -->
    <div class="af-page-header">
      <button class="btn-back" @click="$router.push({ name: 'attributions' })">
        <span v-html="icons.arrowLeft"></span>
        Retour à la liste
      </button>
      <div class="header-titles">
        <h1 class="af-page-title">Nouvelle association</h1>
        <p class="af-page-subtitle">Associer une habilitation à un groupe d'employés</p>
      </div>
    </div>

    <!-- ── Steps bar ───────────────────────────────────────────────────── -->
    <div class="af-steps-bar">
      <div v-for="(step, i) in steps" :key="i"
        :class="['af-step', { active: currentStep === i, done: currentStep > i }]">
        <div class="af-step-circle">
          <span v-if="currentStep > i" v-html="icons.check"></span>
          <span v-else>{{ i + 1 }}</span>
        </div>
        <div class="af-step-label">{{ step }}</div>
        <div class="af-step-line" v-if="i < steps.length - 1"></div>
      </div>
    </div>

    <!-- ══ STEP 0 — Volet + Habilitation (split panel) ══════════════════ -->
    <div class="af-step-card" v-if="currentStep === 0">

      <div class="split-panel">

        <!-- ── LEFT: Volets ──────────────────────────────────────────── -->
        <div class="panel-left">
          <div class="panel-header">
            <div class="panel-title">
              <span v-html="icons.voletIcon"></span>
              Volet
            </div>
            <span class="panel-count">{{ volets.length }}</span>
          </div>

          <div class="panel-search">
            <span class="ps-icon" v-html="icons.search"></span>
            <input
              v-model="voletSearch"
              type="text"
              placeholder="Filtrer les volets..."
              class="ps-input"
            />
          </div>

          <div class="panel-loading" v-if="loadingVolets">
            <div class="af-spinner"></div>
          </div>

          <div class="volet-scroll" v-else>
            <button
              v-for="volet in filteredVolets"
              :key="volet.id"
              :class="['volet-row', { selected: form.volet_id === volet.id }]"
              @click="selectVolet(volet)"
            >
              <div class="vr-dot" :style="{ background: voletColor(volet.id) }"></div>
              <div class="vr-name">{{ volet.nom }}</div>
              <span class="vr-arrow" v-html="icons.chevronRight"></span>
            </button>
            <div class="panel-empty" v-if="filteredVolets.length === 0">
              Aucun volet trouvé
            </div>
          </div>
        </div>

        <!-- ── RIGHT: Habilitations ──────────────────────────────────── -->
        <div class="panel-right">

          <div class="right-placeholder" v-if="!form.volet_id">
            <span class="placeholder-icon" v-html="icons.selectPrompt"></span>
            <p>Sélectionnez un volet<br>pour voir ses habilitations</p>
          </div>

          <template v-else>
            <div class="panel-header">
              <div class="panel-title">
                <span class="volet-chip"
                  :style="{ background: voletColor(form.volet_id) + '18', color: voletColor(form.volet_id), borderColor: voletColor(form.volet_id) + '40' }">
                  {{ selectedVolet?.nom }}
                </span>
              </div>
              <span class="panel-count">{{ habilitations.length }}</span>
            </div>

            <div class="panel-loading" v-if="loadingHabilitations">
              <div class="af-spinner"></div>
            </div>

            <div class="hab-scroll" v-else-if="habilitations.length > 0">
              <button
                v-for="hab in habilitations"
                :key="hab.id"
                :class="['hab-row', { selected: form.habilitation_id === hab.id }]"
                @click="selectHabilitation(hab)"
              >
                <div class="hr-body">
                  <div class="hr-name">{{ hab.nom }}</div>
                  <div class="hr-tags">
                    <span class="hr-tag">{{ hab.duree_de_validite }} an(s)</span>
                    <span class="hr-tag">Init. {{ hab.duree_formation_initiale }} {{ hab.duree_formation_initiale_unite }}</span>
                    <span class="hr-tag">Rec. {{ hab.duree_formation_recyclage }} {{ hab.duree_formation_recyclage_unite }}</span>
                  </div>
                  <div class="hr-detail" v-if="hab.detail_formation">{{ hab.detail_formation }}</div>
                </div>
                <div class="hr-check" v-if="form.habilitation_id === hab.id" v-html="icons.check"></div>
              </button>
            </div>

            <div class="panel-empty right" v-else-if="!loadingHabilitations">
              Aucune habilitation pour ce volet.
            </div>

            <!-- Organisme — slides in once a habilitation is picked -->
            <div class="organisme-box" v-if="form.habilitation_id">
              <label class="org-label">
                <span v-html="icons.building"></span>
                Organisme de formation
                <span class="org-note">— commun à tous les employés</span>
              </label>
              <input
                v-model="form.organisme_formation"
                type="text"
                class="org-input"
                placeholder="Ex: OFPPT, Centre Holcim..."
                required
              />
            </div>
          </template>

        </div>
      </div>

      <div class="af-step-actions">
        <button class="btn-primary" :disabled="!form.habilitation_id || !form.organisme_formation" @click="currentStep = 1">
          Suivant <span v-html="icons.arrowRight"></span>
        </button>
      </div>
    </div>

    <!-- ══ STEP 1 — Employés ════════════════════════════════════════════ -->
    <div class="af-step-card" v-if="currentStep === 1">
      <h2 class="af-step-title">Ajouter des employés</h2>
      <p class="af-step-hint">
        <span class="bc-chip">{{ selectedVolet?.nom }}</span>
        <span class="bc-sep" v-html="icons.chevronRight"></span>
        <span class="bc-chip active">{{ selectedHabilitation?.nom }}</span>
        <span class="bc-validity">· Validité {{ selectedHabilitation?.duree_de_validite }} an(s)</span>
      </p>

      <!-- Matricule search -->
      <div class="matricule-search">
        <div :class="['mat-wrap', { 'is-error': matriculeError, 'is-success': matriculeFound }]">
          <label class="mat-label">Rechercher par matricule</label>
          <div class="mat-row">
            <input
              v-model="matriculeInput"
              type="text"
              placeholder="Ex: EMP001"
              class="mat-input"
              @keydown.enter.prevent="searchByMatricule"
              @input="matriculeError = ''; matriculeFound = null"
              :disabled="searchingMatricule"
            />
            <button class="btn-mat-search" @click="searchByMatricule"
              :disabled="!matriculeInput.trim() || searchingMatricule">
              <span v-if="searchingMatricule" class="af-spinner-sm"></span>
              <span v-else v-html="icons.search"></span>
            </button>
          </div>
          <div class="mat-error" v-if="matriculeError">{{ matriculeError }}</div>
        </div>

        <!-- Found employee card -->
        <div class="found-card" v-if="matriculeFound">
          <div class="found-top">
            <div class="found-avatar">{{ initiales(matriculeFound) }}</div>
            <div class="found-info">
              <div class="found-name">{{ matriculeFound.prenom }} {{ matriculeFound.nom }}</div>
              <div class="found-meta">{{ matriculeFound.matricule }} · {{ matriculeFound.position }} · {{ matriculeFound.departement?.nom }}</div>
            </div>
          </div>
          <div class="found-fields">
            <div class="ff-group">
              <label>Date d'obtention <span class="req">*</span></label>
              <input type="date" v-model="matriculeFound._date_obtention" :max="today" />
            </div>
            <div class="ff-group">
              <label>Aptitude médicale</label>
              <input type="date" v-model="matriculeFound._date_aptitude_medicale" />
            </div>
            <div class="ff-group">
              <label>Type</label>
              <select v-model="matriculeFound._type">
                <option value="initiale">Initiale</option>
                <option value="recyclage">Recyclage</option>
              </select>
            </div>
            <button class="btn-add-emp" @click="addEmployee"
              :disabled="!matriculeFound._date_obtention">
              <span v-html="icons.plus"></span> Ajouter
            </button>
          </div>
        </div>
      </div>

      <!-- Employee list -->
      <div class="emp-list" v-if="form.employees.length > 0">
        <div class="emp-list-header">
          {{ form.employees.length }} employé(s) ajouté(s)
        </div>
        <div class="emp-row" v-for="(emp, idx) in form.employees" :key="emp.id">
          <div class="er-identity">
            <div class="er-avatar">{{ initiales(emp) }}</div>
            <div>
              <div class="er-name">{{ emp.prenom }} {{ emp.nom }}</div>
              <div class="er-mat">{{ emp.matricule }}</div>
            </div>
          </div>
          <div class="er-fields">
            <div class="ff-group">
              <label>Date d'obtention</label>
              <input type="date" v-model="emp._date_obtention" :max="today" />
            </div>
            <div class="ff-group">
              <label>Aptitude médicale</label>
              <input type="date" v-model="emp._date_aptitude_medicale" />
            </div>
            <div class="ff-group">
              <label>Type</label>
              <select v-model="emp._type">
                <option value="initiale">Initiale</option>
                <option value="recyclage">Recyclage</option>
              </select>
            </div>
          </div>
          <button class="btn-remove" @click="removeEmployee(idx)">
            <span v-html="icons.trash"></span>
          </button>
        </div>
      </div>

      <div class="emp-empty" v-else>
        Aucun employé ajouté. Recherchez par matricule ci-dessus.
      </div>

      <div class="af-step-actions">
        <button class="btn-secondary" @click="currentStep = 0">
          <span v-html="icons.arrowLeft"></span> Retour
        </button>
        <button class="btn-primary" :disabled="form.employees.length === 0" @click="currentStep = 2">
          Suivant <span v-html="icons.arrowRight"></span>
        </button>
      </div>
    </div>

    <!-- ══ STEP 2 — Confirmation ════════════════════════════════════════ -->
    <div class="af-step-card" v-if="currentStep === 2">
      <h2 class="af-step-title">Confirmation</h2>
      <p class="af-step-hint">Vérifiez avant de valider</p>

      <div class="confirm-summary">
        <div class="cs-item">
          <span class="cs-label">Volet</span>
          <span class="cs-value">{{ selectedVolet?.nom }}</span>
        </div>
        <div class="cs-item">
          <span class="cs-label">Habilitation</span>
          <span class="cs-value">{{ selectedHabilitation?.nom }}</span>
        </div>
        <div class="cs-item">
          <span class="cs-label">Validité</span>
          <span class="cs-value">{{ selectedHabilitation?.duree_de_validite }} an(s)</span>
        </div>
        <div class="cs-item">
          <span class="cs-label">Organisme</span>
          <span class="cs-value">{{ form.organisme_formation || '—' }}</span>
        </div>
        <div class="cs-item">
          <span class="cs-label">Employés</span>
          <span class="cs-value cs-badge">{{ form.employees.length }}</span>
        </div>
      </div>

      <div class="confirm-table">
        <table>
          <thead>
            <tr>
              <th>Employé</th>
              <th>Matricule</th>
              <th>Date d'obtention</th>
              <th>Date d'expiration</th>
              <th>Aptitude médicale</th>
              <th>Type</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="emp in form.employees" :key="emp.id">
              <td>
                <div class="ct-emp">
                  <div class="ct-avatar">{{ initiales(emp) }}</div>
                  {{ emp.prenom }} {{ emp.nom }}
                </div>
              </td>
              <td class="ct-mono">{{ emp.matricule }}</td>
              <td>{{ formatDate(emp._date_obtention) }}</td>
              <td class="ct-exp">{{ calcExpiration(emp._date_obtention) }}</td>
              <td>{{ formatDate(emp._date_aptitude_medicale) }}</td>
              <td><span :class="['ct-type', emp._type]">{{ emp._type }}</span></td>
            </tr>
          </tbody>
        </table>
      </div>

      <div class="submit-error" v-if="submitError">
        <span v-html="icons.warning"></span> {{ submitError }}
      </div>
      <div class="submit-success" v-if="submitSuccess">
        <span v-html="icons.checkCircle"></span> {{ submitSuccess }}
      </div>

      <div class="af-step-actions">
        <button class="btn-secondary" @click="currentStep = 1" :disabled="submitting">
          <span v-html="icons.arrowLeft"></span> Retour
        </button>
        <button class="btn-submit" @click="submitAll" :disabled="submitting || !!submitSuccess">
          <span v-if="submitting" class="af-spinner-sm white"></span>
          <span v-else v-html="icons.check"></span>
          {{ submitting ? 'Enregistrement...' : 'Valider les associations' }}
        </button>
      </div>
    </div>

  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted, watch } from 'vue';
import { useRouter } from 'vue-router';
import api from '@/services/api';
import '@/../css/components/attributions/attribution-form.css';

const router = useRouter();

const steps       = ['Habilitation', 'Employés', 'Confirmation'];
const currentStep = ref(0);

const volets               = ref([]);
const habilitations        = ref([]);
const loadingVolets        = ref(true);
const loadingHabilitations = ref(false);
const voletSearch          = ref('');

const matriculeInput      = ref('');
const matriculeFound      = ref(null);
const matriculeError      = ref('');
const searchingMatricule  = ref(false);

const submitting          = ref(false);
const submitError         = ref('');
const submitSuccess       = ref('');

const form = reactive({
  volet_id:            null,
  habilitation_id:     null,
  organisme_formation: '',
  employees:           [],
});

// Deterministic color per volet id
const palette    = ['#1a6b8a','#16a34a','#d97706','#7c3aed','#db2777','#0891b2','#65a30d','#dc2626'];
const voletColor = (id) => palette[(id - 1) % palette.length] ?? palette[0];

const selectedVolet        = computed(() => volets.value.find(v => v.id === form.volet_id));
const selectedHabilitation = computed(() => habilitations.value.find(h => h.id === form.habilitation_id));
const filteredVolets       = computed(() => {
  if (!voletSearch.value) return volets.value;
  const s = voletSearch.value.toLowerCase();
  return volets.value.filter(v => v.nom.toLowerCase().includes(s));
});
const today = computed(() => new Date().toISOString().split('T')[0]);

const icons = {
  check:        `<svg xmlns="http://www.w3.org/2000/svg" width="15" height="15" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M5 13l4 4L19 7"/></svg>`,
  checkCircle:  `<svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>`,
  arrowRight:   `<svg xmlns="http://www.w3.org/2000/svg" width="15" height="15" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7"/></svg>`,
  arrowLeft:    `<svg xmlns="http://www.w3.org/2000/svg" width="15" height="15" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7"/></svg>`,
  chevronRight: `<svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M9 5l7 7-7 7"/></svg>`,
  search:       `<svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"/></svg>`,
  plus:         `<svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"/></svg>`,
  trash:        `<svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"/></svg>`,
  voletIcon:    `<svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 11V9a2 2 0 012-2m0 0V5a2 2 0 012-2h6a2 2 0 012 2v2M7 7h10"/></svg>`,
  building:     `<svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4"/></svg>`,
  warning:      `<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"/></svg>`,
  selectPrompt: `<svg xmlns="http://www.w3.org/2000/svg" width="38" height="38" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2m-6 9l2 2 4-4"/></svg>`,
};

const initiales   = (emp) => `${emp?.prenom?.[0] ?? ''}${emp?.nom?.[0] ?? ''}`.toUpperCase();
const formatDate  = (d)   => d ? new Date(d).toLocaleDateString('fr-FR') : '—';
const calcExpiration = (d) => {
  if (!d || !selectedHabilitation.value) return '—';
  const dt = new Date(d);
  dt.setFullYear(dt.getFullYear() + selectedHabilitation.value.duree_de_validite);
  return dt.toLocaleDateString('fr-FR');
};

const selectVolet = (volet) => {
  form.volet_id        = volet.id;
  form.habilitation_id = null;
  habilitations.value  = [];
};
const selectHabilitation = (hab) => { form.habilitation_id = hab.id; };

const searchByMatricule = async () => {
  const mat = parseInt(matriculeInput.value);
  if (!mat) return;
  matriculeError.value    = '';
  matriculeFound.value    = null;
  searchingMatricule.value = true;
  try {
    const { data } = await api.get('/employees', { params: { search: mat } });
    const emp = data.find(e => e.matricule === mat);
    if (!emp) { matriculeError.value = `Aucun employé trouvé avec le matricule "${mat}"`; return; }
    if (form.employees.some(e => e.id === emp.id)) { matriculeError.value = 'Déjà dans la liste.'; return; }
    matriculeFound.value = { ...emp, _date_obtention: '', _date_aptitude_medicale: '', _type: 'initiale' };
    matriculeInput.value = '';
  } catch { matriculeError.value = 'Erreur lors de la recherche.'; }
  finally  { searchingMatricule.value = false; }
};

const addEmployee    = () => { if (!matriculeFound.value?._date_obtention) return; form.employees.push({ ...matriculeFound.value }); matriculeFound.value = null; };
const removeEmployee = (idx) => form.employees.splice(idx, 1);

const submitAll = async () => {
  submitting.value = true; submitError.value = ''; submitSuccess.value = '';
  const results = { ok: 0, errors: [] };
  for (const emp of form.employees) {
    try {
      await api.post('/employee-habilitations', {
        employee_id:            emp.id,
        habilitation_id:        form.habilitation_id,
        date_obtention:         emp._date_obtention,
        date_aptitude_medicale: emp._date_aptitude_medicale,
        organisme_formation:    form.organisme_formation    ,
        type:                   emp._type,
      });
      results.ok++;
    } catch (e) { results.errors.push(`${emp.prenom} ${emp.nom} : ${e.response?.data?.message ?? 'Erreur'}`); }
  }
  submitting.value = false;
  if (!results.errors.length) {
    submitSuccess.value = `${results.ok} association(s) créée(s) avec succès.`;
    setTimeout(() => router.push({ name: 'attributions' }), 2000);
  } else if (results.ok > 0) {
    submitError.value = `${results.ok} créée(s), erreurs : ${results.errors.join(' | ')}`;
  } else {
    submitError.value = results.errors.join(' | ');
  }
};

const fetchVolets = async () => {
  loadingVolets.value = true;
  try { const { data } = await api.get('/volets'); volets.value = data; }
  finally { loadingVolets.value = false; }
};
const fetchHabilitations = async (id) => {
  loadingHabilitations.value = true;
  try { const { data } = await api.get('/habilitations', { params: { volet_id: id } }); habilitations.value = data; }
  finally { loadingHabilitations.value = false; }
};

watch(() => form.volet_id, (id) => { if (id) fetchHabilitations(id); });
onMounted(fetchVolets);
</script>