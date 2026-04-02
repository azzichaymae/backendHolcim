<template>
  <div class="val-page">

    <!-- Header -->
    <div class="val-topbar">
      <div class="val-topbar-inner">
        <div class="val-brand">
          <span class="val-brand-icon" v-html="icons.shield"></span>
          <div>
            <div class="val-brand-name">Portail Habilitations</div>
            <div class="val-brand-sub">Refus de validation de signature</div>
          </div>
        </div>
      </div>
    </div>

    <!-- Content -->
    <div class="val-body">

      <!-- Loading -->
      <div class="val-loading" v-if="loading">
        <div class="val-spinner"></div>
        <p>Chargement...</p>
      </div>

      <!-- Error -->
      <div class="val-card" v-else-if="error">
        <div class="val-alert error">
          <span v-html="icons.xCircle"></span>
          {{ error }}
        </div>
      </div>

      <!-- Already processed -->
      <div class="val-card" v-else-if="alreadyDone">
        <div class="val-success-icon">
          <span v-html="icons.xCircle"></span>
        </div>
        <h2 class="val-done-title">Déjà traité</h2>
        <p class="val-done-sub">Cette validation a déjà été traitée.</p>
      </div>

      <!-- Refuse form -->
      <div v-else-if="!refused">
        <div class="val-greeting">
          <h2>Bonjour <strong>{{ validation?.signataire_nom }}</strong>,</h2>
          <p>Vous êtes sur le point de refuser l'habilitation suivante :</p>
        </div>

        <div class="val-card">
          <div class="val-info-card">
            <div class="val-info-row">
              <span class="val-info-label">Employé</span>
              <span class="val-info-value">{{ eh?.employee?.prenom }} {{ eh?.employee?.nom }}</span>
            </div>
            <div class="val-info-row">
              <span class="val-info-label">Matricule</span>
              <span class="val-info-value">{{ eh?.employee?.matricule ?? 'Sous-traitant' }}</span>
            </div>
            <div class="val-info-row">
              <span class="val-info-label">Habilitation</span>
              <span class="val-info-value strong">{{ eh?.habilitation?.nom }}</span>
            </div>
            <div class="val-info-row">
              <span class="val-info-label">Date d'obtention</span>
              <span class="val-info-value">{{ formatDate(eh?.date_obtention) }}</span>
            </div>
            <div class="val-info-row">
              <span class="val-info-label">Date d'expiration</span>
              <span class="val-info-value">{{ formatDate(eh?.date_expiration) }}</span>
            </div>
          </div>

          <div class="val-alert refuse-warn">
            <span v-html="icons.xCircle"></span>
            En refusant, cette habilitation ne sera pas validée. Veuillez indiquer le motif du refus.
          </div>

          <textarea
            v-model="motif"
            class="val-textarea"
            :class="{ 'val-textarea-error': motifError }"
            placeholder="Motif du refus (obligatoire)..."
            rows="4"
          ></textarea>
          <span class="val-field-error" v-if="motifError">Le motif est obligatoire.</span>

          <button class="val-btn refuse" @click="refuser" :disabled="submitting">
            <span v-if="submitting" class="val-btn-spinner"></span>
            <span v-else v-html="icons.xCircle"></span>
            {{ submitting ? 'Traitement...' : 'Confirmer le refus' }}
          </button>

          <p class="val-secure-note">Ce lien est à usage unique et sécurisé. Ne le partagez pas.</p>
        </div>
      </div>

      <!-- Refused success state -->
      <div class="val-card val-refused-card" v-if="refused">
        <div class="val-success-icon refused">
          <span v-html="icons.xCircle"></span>
        </div>
        <h2 class="val-done-title">Refus enregistré</h2>
        <p class="val-done-sub">Votre refus a bien été enregistré. Les responsables RH ont été notifiés.</p>
      </div>

    </div>

    <!-- Footer -->
    <div class="val-footer">
      <p>Portail Habilitations — Email automatique, ne pas répondre.</p>
    </div>

  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import { useRoute } from 'vue-router';
import api from '@/services/api';
import '@/../css/components/validation/validation.css';

const route      = useRoute();
const loading    = ref(true);
const submitting = ref(false);
const refused    = ref(false);
const alreadyDone = ref(false);
const error      = ref(null);
const motif      = ref('');
const motifError = ref(false);
const validation = ref(null);
const eh         = ref(null);

const icons = {
  shield:      `<svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z"/></svg>`,
  checkCircle: `<svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>`,
  xCircle:     `<svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2m7-2a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>`,
};

const formatDate = (d) => d ? new Date(d).toLocaleDateString('fr-FR') : '—';

const fetchValidation = async () => {
  try {
    const token = route.params.token;
    const { data } = await api.get(`/validations/info/${token}`);
    validation.value = data.validation;
    eh.value = data.eh;
    if (data.validation.statut !== 'en_attente') alreadyDone.value = true;
  } catch (e) {
    error.value = e.response?.status === 404
      ? 'Ce lien de validation est invalide ou a expiré.'
      : 'Une erreur est survenue. Veuillez réessayer.';
  } finally {
    loading.value = false;
  }
};

const refuser = async () => {
  motifError.value = false;
  if (!motif.value.trim()) { motifError.value = true; return; }
  submitting.value = true;
  try {
    await api.get(`/validations/refuser/${route.params.token}?raison=${encodeURIComponent(motif.value)}`);
    refused.value = true;
    validation.value = null;
    eh.value = null;
  } catch (e) {
    error.value = e.response?.data?.message ?? 'Erreur lors du refus.';
  } finally {
    submitting.value = false;
  }
};

onMounted(fetchValidation);
</script>